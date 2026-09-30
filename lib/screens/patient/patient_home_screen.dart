import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../api_service.dart';
import 'videos_library_screen.dart';
import 'reminders_screen.dart';
// Nayi add_caretaker_screen ko import karna mat bhoolna
import 'add_caretaker_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // Theme Colors
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _red = const Color(0xFF8B2F27);

  String _userName = 'User';
  String? _profileImage;
  String _currentTime = '';
  String _currentDate = '';
  String _greeting = 'Good Morning';
  bool _showAllFeatures = false;
  Timer? _timer;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedUserData();
    _syncEmergencyContactToLocal();
    _updateTimeAndGreeting();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _updateTimeAndGreeting();
      }
    });
  }

  Future<void> _loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('savedUsername') ?? prefs.getString('full_name');
    final savedPic = prefs.getString('profile_image') ?? prefs.getString('savedProfileImage');

    if (mounted) {
      setState(() {
        if (savedName != null && savedName.isNotEmpty) {
          _userName = savedName;
        }
        if (savedPic != null && savedPic.trim().isNotEmpty) {
          _profileImage = savedPic.trim();
        }
      });
    }
  }

  Future<void> _syncEmergencyContactToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? prefs.getString('userId');
      final token = prefs.getString('token');

      if (userId == null) return;

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

        final dynamic fetchedContact = data['emergency_contact'] ??
            data['user']?['emergency_contact'] ??
            data['profile']?['emergency_contact'];

        if (fetchedContact != null) {
          final String contactStr = fetchedContact.toString().trim();
          if (contactStr.isNotEmpty) {
            await prefs.setString('savedEmergencyContact', contactStr);
            await prefs.setString('emergency_contact', contactStr);
          }
        }

        final dynamic fetchedImage = data['profile_image'] ??
            data['user']?['profile_image'] ??
            data['profile']?['profile_image'] ??
            data['avatar'];

        if (fetchedImage != null) {
          final String imgStr = fetchedImage.toString().trim();
          if (imgStr.isNotEmpty) {
            await prefs.setString('profile_image', imgStr);
            if (mounted) {
              setState(() {
                _profileImage = imgStr;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Emergency contact & profile sync error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && args.isNotEmpty) {
      _userName = args;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTimeAndGreeting() {
    final now = DateTime.now();
    int hours = now.hour;
    int minutes = now.minute;
    String ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours == 0 ? 12 : hours;
    String mins = minutes.toString().padLeft(2, '0');

    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    String month = months[now.month - 1];

    String greetingStr;
    if (now.hour < 12) {
      greetingStr = 'Good Morning';
    } else if (now.hour < 17) {
      greetingStr = 'Good Afternoon';
    } else {
      greetingStr = 'Good Evening';
    }

    setState(() {
      _currentTime = '$hours:$mins $ampm';
      _currentDate = '$month ${now.day}';
      _greeting = greetingStr;
    });
  }

  Widget _displayImageWidget(String? img) {
    if (img == null || img.trim().isEmpty) {
      return _fallbackAvatar();
    }

    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last;
        cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

        while (cleanBase64.length % 4 != 0) {
          cleanBase64 += '=';
        }

        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          width: 82,
          height: 82,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Home Image Load Error: $error");
            return _fallbackAvatar();
          },
        );
      } else if (img.startsWith('http://') || img.startsWith('https://')) {
        return Image.network(
          img,
          fit: BoxFit.cover,
          width: 82,
          height: 82,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        );
      } else {
        final file = File(img);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 82,
            height: 82,
            errorBuilder: (_, __, ___) => _fallbackAvatar(),
          );
        }
      }
    } catch (e) {
      debugPrint("Home image render error: $e");
    }

    return _fallbackAvatar();
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/edit_profile');
        _loadSavedUserData();
      },
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: _displayImageWidget(_profileImage),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: const Color(0xFFE5EDE7),
      child: Icon(
        Icons.person,
        size: 42,
        color: _green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F6F0),
          image: DecorationImage(
            image: AssetImage('assets/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 260),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_currentDate\n$_currentTime',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                            ),
                          ),
                          Row(
                            children: [
                              _buildAddCaretakerButton(), // <-- Naya Button
                              const SizedBox(width: 8),
                              _buildSettingsButton(),
                              const SizedBox(width: 8),
                              _buildLangButton(),
                            ],
                          )
                        ],
                      ),
                    ),

                    // Greeting Section with Profile Photo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProfileAvatar(),
                          const SizedBox(width: 18),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 34,
                                  height: 1.25,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$_greeting,\n',
                                    style: TextStyle(color: _ink),
                                  ),
                                  TextSpan(
                                    text: '$_userName 🌻',
                                    style: TextStyle(
                                      color: _inkSoft,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Action Cards
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildActionCard('Activity', 'assets/activity.jpeg', () {
                            Navigator.pushNamed(context, '/activity');
                          }),
                          const SizedBox(height: 16),
                          _buildActionCard('Videos', 'assets/videos.jpeg', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VideosLibraryScreen()),
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildActionCard('Family', 'assets/family.jpeg', () {
                            Navigator.pushNamed(context, '/family');
                          }),
                        ],
                      ),
                    ),

                    // Toggle Features Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllFeatures = !_showAllFeatures;
                          });
                          if (_showAllFeatures) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _showAllFeatures ? 'Hide features' : 'Show all features',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    // Dynamic Animated Mini Grid (Reminders & Appointments)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _showAllFeatures
                          ? Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildGridCard('Reminders', 'assets/reminder.png', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RemindersScreen()),
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridCard('Appointments', 'assets/appointment.png', () {
                                Navigator.pushNamed(context, '/caregivers_schedule');
                              }),
                            ),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Fixed Emergency SOS Button at Bottom
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final directContact = prefs.getString('savedEmergencyContact') ??
                        prefs.getString('emergency_contact');
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/emergency', arguments: directContact);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _red.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_in_talk, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency — Call Now',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Alerts family instantly with your location',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW ADD CARETAKER BUTTON ---
  Widget _buildAddCaretakerButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddCaretakerScreen()),
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Icon(Icons.person_add, size: 18, color: _green),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/patient_settings', arguments: _userName);
        _loadSavedUserData();
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Icon(Icons.settings_outlined, size: 18, color: _green),
      ),
    );
  }

  Widget _buildLangButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Language selection coming soon!')),
        );
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Icon(Icons.language, size: 15, color: _green),
            const SizedBox(width: 6),
            const Text('EN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF3F6B4F))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 12))],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.15), BlendMode.darken),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _buildGridCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ),
    );
  }
}