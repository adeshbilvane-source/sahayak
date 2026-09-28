import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../api_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String _contactName = "";
  String _contactNumber = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDynamicUserContact();
  }

  // Current logged-in user ka emergency contact dynamically load karna
  Future<void> _loadDynamicUserContact() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Current logged-in user ka local cache check karein
    String? localNumber = prefs.getString('savedEmergencyContact') ??
        prefs.getString('emergency_contact') ??
        prefs.getString('emergencyContact');
    String? localName = prefs.getString('savedUsername') ?? prefs.getString('full_name');

    if (localNumber != null && localNumber.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _contactNumber = localNumber.trim();
          _contactName = (localName != null && localName.trim().isNotEmpty)
              ? localName.trim()
              : "Family Contact";
          _isLoading = false;
        });
      }
      return;
    }

    // 2. Agar phone memory me nahi hai, toh currently logged-in userId ke database se fetch karein
    final userId = prefs.getInt('userId') ?? prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId != null) {
      try {
        final url = Uri.parse('${ApiService.baseUrl}/user/$userId');
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);

          final dynamic dynamicNumber = data['emergency_contact'] ??
              data['user']?['emergency_contact'] ??
              data['profile']?['emergency_contact'];

          final dynamic dynamicName = data['full_name'] ??
              data['user']?['full_name'] ??
              data['profile']?['full_name'];

          if (dynamicNumber != null && dynamicNumber.toString().trim().isNotEmpty) {
            final validNum = dynamicNumber.toString().trim();
            final validName = dynamicName?.toString().trim() ?? "Family Contact";

            // Local cache karein taaki user agli baar offline bhi dial kar sake
            await prefs.setString('savedEmergencyContact', validNum);
            await prefs.setString('emergency_contact', validNum);

            if (mounted) {
              setState(() {
                _contactNumber = validNum;
                _contactName = validName;
                _isLoading = false;
              });
            }
            return;
          }
        }
      } catch (e) {
        debugPrint("Error fetching dynamic user contact: $e");
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Dial function jo dynamically mile number par dialer open karega
  Future<void> _makeCall(String number) async {
    if (number.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No emergency contact number available for this account.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cleanDigits = number.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri dialUri = Uri(scheme: 'tel', path: cleanDigits);

    try {
      final launched = await launchUrl(
        dialUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(dialUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dialer error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCanvas = Color(0xFFF6F8F5);
    const Color greenPrimary = Color(0xFF2C5E3B);
    const Color inkColor = Color(0xFF1E2822);

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2EDE4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: greenPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Emergency SOS',
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: inkColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'YOUR EMERGENCY CONTACT',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6E7E73),
                ),
              ),
              const SizedBox(height: 14),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: greenPrimary),
                  ),
                )
              else if (_contactNumber.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'No emergency contact registered for this account.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE8D3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF2470B8), size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contactName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: inkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _contactNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: inkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _makeCall(_contactNumber),
                        icon: const Icon(Icons.call, size: 18, color: Colors.white),
                        label: const Text(
                          'Call',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFEA8C2B), width: 4),
                  ),
                ),
                child: const Text(
                  'Tap the call button to connect with your registered emergency contact instantly.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A531C),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}