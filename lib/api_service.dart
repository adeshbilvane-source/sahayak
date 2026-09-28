import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // Laptop ka exact IPv4 Address
  static const String myLaptopIp = '10.86.88.126';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // Real Phone testing ke liye:
      return 'http://$myLaptopIp:5000/api';

      // Emulator testing ke liye:
      // return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // ----------------------------------------------------
  // 1. SIGNUP API CALL
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> signup({
    required String phoneNumber,
    required String password,
    required String role,
    required String fullName,
    String? email,
    int? age,
    String? gender,
    String? bloodGroup,
    String? emergencyContact,
    String? specialization,
    int? experienceYears,
    String? licenseNumber,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'email': email,
          'password': password,
          'role': role,
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'blood_group': bloodGroup,
          'emergency_contact': emergencyContact,
          'specialization': specialization,
          'experience_years': experienceYears,
          'license_number': licenseNumber,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server se connect nahi ho paya: $e'};
    }
  }

  // ----------------------------------------------------
  // 2. LOGIN API CALL (Mobile number ya Email dono chalega)
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server se connect nahi ho paya: $e'};
    }
  }

  // ----------------------------------------------------
  // 3. UPDATE PROFILE API CALL
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    required String phoneNumber,
    String? emergencyContact,
    String? bloodGroup,
  }) async {
    final url = Uri.parse('$baseUrl/update-profile');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'emergency_contact': emergencyContact,
          'blood_group': bloodGroup,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Server Error (${response.statusCode}): ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Server connection error: $e'};
    }
  }

  // ----------------------------------------------------
  // 4. GET USER PROFILE (Database se complete profile lene ke liye)
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> getUserProfile(int userId, {String? token}) async {
    final url = Uri.parse('$baseUrl/user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Server Error (${response.statusCode}): ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Server connection error: $e'};
    }
  }

  // ----------------------------------------------------
  // 5. GET DIRECT EMERGENCY CONTACT
  // ----------------------------------------------------
  static Future<String?> getEmergencyContact(int userId, {String? token}) async {
    try {
      final data = await getUserProfile(userId, token: token);
      if (data.containsKey('error')) return null;

      final contact = data['emergency_contact'] ??
          data['user']?['emergency_contact'] ??
          data['profile']?['emergency_contact'];

      return contact?.toString().trim();
    } catch (_) {
      return null;
    }
  }
}