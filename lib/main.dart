import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/patient_login_screen.dart';
import 'screens/auth/patient_register_screen.dart';
import 'screens/auth/doctor_login_screen.dart';

// Doctor Screen (Uncommented & Active)
import 'screens/doctor/doctor_home_screen.dart';

// Patient Screens
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/emergency_screen.dart';
import 'screens/patient/patient_settings_screen.dart';
import 'screens/patient/edit_profile_screen.dart';
import 'screens/patient/activity_screen.dart';
import 'screens/patient/videos_library_screen.dart';
import 'screens/patient/family_emergency_screen.dart';
import 'screens/patient/caregivers_schedule_screen.dart';

// Games Screens
import 'screens/patient/games/button_sorting.dart';
import 'screens/patient/games/identify_picture.dart';
import 'screens/patient/games/memory_match.dart';
import 'screens/patient/games/jigsaw_puzzle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String userRole = (prefs.getString('userRole') ?? '').toLowerCase();

  // Initial Route decide karna
  String initialRoute = '/login';

  if (isLoggedIn) {
    // Doctor ya Caretaker dono ko doctor_home par bhejega
    if (userRole == 'doctor' || userRole == 'caretaker') {
      initialRoute = '/doctor_home';
    } else {
      initialRoute = '/patient_home';
    }
  }

  runApp(NeuroNestApp(initialRoute: initialRoute));
}

class NeuroNestApp extends StatelessWidget {
  final String initialRoute;

  const NeuroNestApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahayak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3F6B4F),
        scaffoldBackgroundColor: const Color(0xFFF3F6F0),
        fontFamily: 'Nunito',
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/patient_home': (context) => const PatientHomeScreen(),
        // Doctor Home Screen route active kar diya
        '/doctor_home': (context) => const DoctorHomeScreen(),
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