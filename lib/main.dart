import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:alarm/alarm.dart'; // Alarm package import

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/patient_login_screen.dart';
import 'screens/auth/patient_register_screen.dart';
import 'screens/auth/doctor_login_screen.dart';

// Doctor Screen
import 'screens/doctor/doctor_main_screen.dart';

// Patient Screens
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/emergency_screen.dart';
import 'screens/patient/patient_settings_screen.dart';
import 'screens/patient/edit_profile_screen.dart';
import 'screens/patient/activity_screen.dart';
import 'screens/patient/family_emergency_screen.dart';
import 'screens/patient/caregivers_schedule_screen.dart';

// Games Screens
import 'screens/patient/games/button_sorting.dart';
import 'screens/patient/games/identify_picture.dart';
import 'screens/patient/games/memory_match.dart';
import 'screens/patient/games/jigsaw_puzzle.dart';

// GLOBAL NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ALARM PACKAGE INITIALIZATION
  await Alarm.init();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String userRole = (prefs.getString('userRole') ?? '').toLowerCase();

  String initialRoute = '/login';

  if (isLoggedIn) {
    if (userRole == 'doctor' || userRole == 'caretaker') {
      initialRoute = '/doctor_home';
    } else {
      initialRoute = '/patient_home';
    }
  }

  runApp(NeuroNestApp(initialRoute: initialRoute));
}

class NeuroNestApp extends StatefulWidget {
  final String initialRoute;
  const NeuroNestApp({super.key, required this.initialRoute});

  @override
  State<NeuroNestApp> createState() => _NeuroNestAppState();
}

class _NeuroNestAppState extends State<NeuroNestApp> {
  @override
  void initState() {
    super.initState();
    // GLOBAL ALARM LISTENER
    Alarm.ringStream.stream.listen((alarmSettings) {
      _showGlobalAlarmPopup(alarmSettings);
    });
  }

  Future<void> _showGlobalAlarmPopup(AlarmSettings alarmSettings) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sahayak_reminders_list');
    Map<String, dynamic>? remData;

    if (raw != null) {
      for (var item in jsonDecode(raw)) {
        if (item['alarmId'] == alarmSettings.id) {
          remData = item;
          break;
        }
      }
    }

    final isWater = remData?['type'] == 'water';
    final isMed = remData?['type'] == 'medicine';

    // FIX 1: Naye Alarm package me title aise nikalte hain
    final title = remData?['title'] ?? alarmSettings.notificationSettings.title;
    final displayTime = '${remData?['displayTime'] ?? ''} ${remData?['period'] ?? ''}';

    final Color green = const Color(0xFF3F6B4F);
    final Color marigold = const Color(0xFFD98A2B);
    final Color blue = const Color(0xFF3E7FB8);
    final Color inkSoft = const Color(0xFF5B6A61);

    void handleSnooze(int minutes) {
      Alarm.stop(alarmSettings.id);
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));

      // FIX 2: Naye format ke hisaab se AlarmSettings
      final snoozedAlarm = AlarmSettings(
        id: alarmSettings.id,
        dateTime: snoozeTime,
        assetAudioPath: alarmSettings.assetAudioPath,
        volumeSettings: alarmSettings.volumeSettings,
        notificationSettings: alarmSettings.notificationSettings,
      );

      Alarm.set(alarmSettings: snoozedAlarm);
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isWater ? blue : marigold),
                  alignment: Alignment.center,
                  child: Text(isWater ? '💧' : (isMed ? '💊' : '⏰'), style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('🔔 Scheduled at $displayTime', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: marigold)),
                const SizedBox(height: 10),
                Text(
                  isWater
                      ? 'Please pause what you are doing and drink a glass of fresh water to stay hydrated.'
                      : (isMed
                      ? 'Please pause what you are doing right now and take your medicine: $title.'
                      : 'Your reminder for "$title" is active. Please complete this task.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: inkSoft),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      Alarm.stop(alarmSettings.id);
                      Navigator.pop(context);
                    },
                    child: Text(isWater ? '✅ I Drank Water' : '✅ I Have Completed This', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('⏰ OR REMIND ME LATER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: inkSoft)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _snoozeBtn('+5m', () => handleSnooze(5), blue, inkSoft),
                    _snoozeBtn('+10m', () => handleSnooze(10), blue, inkSoft),
                    _snoozeBtn('+15m', () => handleSnooze(15), blue, inkSoft),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _snoozeBtn(String label, VoidCallback onTap, Color highlight, Color normal) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: normal)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahayak',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3F6B4F),
        scaffoldBackgroundColor: const Color(0xFFF3F6F0),
        fontFamily: 'Nunito',
      ),
      initialRoute: widget.initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/patient_home': (context) => const PatientHomeScreen(),
        '/doctor_home': (context) => const DoctorMainScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/patient_login': (context) => const PatientLoginScreen(),
        '/register': (context) => const PatientRegisterScreen(),
        '/patient_settings': (context) => const PatientSettingsScreen(),
        '/doctor_login': (context) => const DoctorAuthScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/activity': (context) => const ActivityScreen(),
        '/game_button_sort': (context) => const ButtonSortingScreen(),
        '/identify_picture': (context) => const IdentifyPictureScreen(),
        '/memory_match': (context) => const MemoryMatchScreen(),
        '/jigsaw_puzzle': (context) => const JigsawPuzzleScreen(),
        '/family': (context) => const FamilyEmergencyScreen(),
        '/caregivers_schedule': (context) => const CaregiversScheduleScreen(),
      },
    );
  }
}