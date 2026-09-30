import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';
import '../auth/login_screen.dart';
import 'edit_doctor_profile_screen.dart';

class DoctorSettingsTab extends StatefulWidget {
  const DoctorSettingsTab({super.key});

  @override
  State<DoctorSettingsTab> createState() => _DoctorSettingsTabState();
}

class _DoctorSettingsTabState extends State<DoctorSettingsTab> {
  final Color _primaryDark = const Color(0xFF233621);
  String _doctorName = 'Doctor';
  String? _profileImage;
  int _caretakerId = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _caretakerId = prefs.getInt('userId') ?? 0;

    // Pehle local preferences se load karo taaki fast dikhe
    setState(() {
      _doctorName = prefs.getString('savedUsername') ?? prefs.getString('full_name') ?? 'Doctor';
      _profileImage = prefs.getString('profile_image');
    });

    // Fir server se latest data fetch karke sync karo
    if (_caretakerId > 0) {
      final data = await ApiService.getUserProfile(_caretakerId);
      if (!data.containsKey('error') && mounted) {
        var profile = data['profile'] ?? data;
        setState(() {
          if (profile['full_name'] != null) {
            _doctorName = profile['full_name'];
            prefs.setString('savedUsername', _doctorName);
          }
          if (profile['profile_image'] != null && profile['profile_image'].toString().trim().isNotEmpty) {
            _profileImage = profile['profile_image'];
            prefs.setString('profile_image', _profileImage!);
          }
        });
      }
    }
  }

  Widget _displayImageWidget(String? img) {
    if (img == null || img.trim().isEmpty) {
      return Icon(Icons.person, size: 50, color: _primaryDark);
    }
    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        while (cleanBase64.length % 4 != 0) cleanBase64 += '=';
        return Image.memory(base64Decode(cleanBase64), fit: BoxFit.cover, width: 100, height: 100);
      } else if (img.startsWith('http')) {
        return Image.network(img, fit: BoxFit.cover, width: 100, height: 100);
      } else {
        final file = File(img);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover, width: 100, height: 100);
        }
      }
    } catch (e) {
      debugPrint("Image load error: $e");
    }
    return Icon(Icons.person, size: 50, color: _primaryDark);
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryDark.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(child: _displayImageWidget(_profileImage)),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text(_doctorName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark))),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDoctorProfileScreen()));
              _loadDoctorProfile(); // Wapas aate hi photo/name refresh ho jayega
            },
            child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _logout(context),
          )
        ],
      ),
    );
  }
}