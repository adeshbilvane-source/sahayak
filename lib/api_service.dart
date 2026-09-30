import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Aapka current laptop IP
  static const String myLaptopIp = '10.184.82.126';

  // Base URL helper
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      return 'http://$myLaptopIp:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Emulator specific fallback URL
  static String get emulatorUrl => 'http://10.0.2.2:5000/api';

  // Helper method: Real phone IP pehle try karega, agar fail hua toh Emulator IP pe try karega
  static Future<http.Response> _postWithFallback(String endpoint, Map<String, dynamic> body) async {
    final headers = {'Content-Type': 'application/json'};
    final encodedBody = jsonEncode(body);

    try {
      final primaryUrl = Uri.parse('$baseUrl$endpoint');
      return await http
          .post(primaryUrl, headers: headers, body: encodedBody)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      if (Platform.isAndroid) {
        final fallbackUrl = Uri.parse('$emulatorUrl$endpoint');
        return await http
            .post(fallbackUrl, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 5));
      }
      rethrow;
    }
  }

  // Helper method: GET with Fallback
  static Future<http.Response> _getWithFallback(String endpoint) async {
    try {
      final primaryUrl = Uri.parse('$baseUrl$endpoint');
      return await http.get(primaryUrl).timeout(const Duration(seconds: 4));
    } catch (_) {
      if (Platform.isAndroid) {
        final fallbackUrl = Uri.parse('$emulatorUrl$endpoint');
        return await http.get(fallbackUrl).timeout(const Duration(seconds: 5));
      }
      rethrow;
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
    try {
      final response = await _postWithFallback('/signup', {
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
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server se connect nahi ho paya: $e'};
    }
  }

  // ----------------------------------------------------
  // 2. LOGIN API CALL
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _postWithFallback('/login', {
        'identifier': identifier,
        'password': password,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server se connect nahi ho paya: $e'};
    }
  }

  // ----------------------------------------------------
  // 3. UPDATE PROFILE API CALL (Patient Side)
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    required String phoneNumber,
    String? emergencyContact,
    String? bloodGroup,
    String? profileImage,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-profile');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'emergency_contact': emergencyContact,
          'blood_group': bloodGroup,
          if (profileImage != null) 'profile_image': profileImage,
        }),
      ).timeout(const Duration(seconds: 30)); // 30 seconds for image upload

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
  // 3.5 UPDATE CARETAKER PROFILE API CALL (Doctor Side)
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> updateCaretakerProfile({
    required int userId,
    required String fullName,
    String? specialization,
    int? experienceYears,
    String? licenseNumber,
    String? profileImage,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-caretaker-profile');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'specialization': specialization,
          'experience_years': experienceYears,
          'license_number': licenseNumber,
          if (profileImage != null) 'profile_image': profileImage,
        }),
      ).timeout(const Duration(seconds: 30)); // 30 seconds for image upload

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
  // 4. GET USER PROFILE
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> getUserProfile(int userId, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId');
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

  // ----------------------------------------------------
  // 6. GET ALL CARETAKERS (REAL DATA)
  // ----------------------------------------------------
  static Future<List<dynamic>> getAllCaretakers() async {
    try {
      final response = await _getWithFallback('/caretakers');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching caretakers: $e');
    }
    return [];
  }

  // ----------------------------------------------------
  // 7. GET ALL PATIENTS (REAL DATA)
  // ----------------------------------------------------
  static Future<List<dynamic>> getAllPatients() async {
    try {
      final response = await _getWithFallback('/patients');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching patients: $e');
    }
    return [];
  }

  // ----------------------------------------------------
  // 8. CONNECTION REQUESTS - PATIENT TO DOCTOR
  // ----------------------------------------------------
  static Future<bool> sendConnectionRequest(int patientId, int caretakerId) async {
    try {
      final response = await _postWithFallback('/send-request', {
        'patient_id': patientId,
        'caretaker_id': caretakerId,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send request error: $e');
      return false;
    }
  }

  // ----------------------------------------------------
  // 9. CONNECTION REQUESTS - GET PENDING (DOCTOR SIDE)
  // ----------------------------------------------------
  static Future<List<dynamic>> getPendingRequests(int caretakerId) async {
    try {
      final response = await _getWithFallback('/pending-requests/$caretakerId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Fetch pending requests error: $e');
    }
    return [];
  }

  // ----------------------------------------------------
  // 10. CONNECTION REQUESTS - ACCEPT/REJECT (DOCTOR SIDE)
  // ----------------------------------------------------
  static Future<bool> updateRequestStatus(int requestId, String status) async {
    try {
      final response = await _postWithFallback('/update-request', {
        'request_id': requestId,
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update request error: $e');
      return false;
    }
  }

  // Get Accepted Patients for Caretaker Schedule
  static Future<List<dynamic>> getAcceptedPatients(int caretakerId) async {
    try {
      final response = await _getWithFallback('/accepted-patients/$caretakerId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Fetch accepted patients error: $e');
    }
    return [];
  }

  // Book Appointment Slot
  static Future<bool> bookAppointment(int patientId, int caretakerId, String date, String time, String reason) async {
    try {
      final response = await _postWithFallback('/book-appointment', {
        'patient_id': patientId,
        'caretaker_id': caretakerId,
        'appointment_date': date,
        'appointment_time': time,
        'reason': reason,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Book appointment error: $e');
      return false;
    }
  }

  // Get Caretaker Home Appointments
  static Future<List<dynamic>> getCaretakerAppointments(int caretakerId) async {
    try {
      final response = await _getWithFallback('/caretaker-appointments/$caretakerId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Fetch caretaker appointments error: $e');
    }
    return [];
  }
  static Future<List<dynamic>> getCaretakerPendingAppointments(int caretakerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/caretaker-pending-appointments/$caretakerId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get caretaker pending appointments error: $e');
    }
    return [];
  }

  static Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/update-appointment-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'appointment_id': appointmentId, 'status': status}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      debugPrint('Update appointment status error: $e');
    }
    return false;
  }

  // Get Patient Appointments
  static Future<List<dynamic>> getPatientAppointments(int patientId) async {
    try {
      final response = await _getWithFallback('/patient-appointments/$patientId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Fetch appointments error: $e');
    }
    return [];
  }
}