import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';
import 'login_screen.dart';
import '../doctor/doctor_main_screen.dart';

class DoctorAuthScreen extends StatefulWidget {
  const DoctorAuthScreen({super.key});

  @override
  State<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

class _DoctorAuthScreenState extends State<DoctorAuthScreen> {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _accentOrange = const Color(0xFFE67E22);

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _loginIdentifierController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regSpecializationController = TextEditingController();
  final TextEditingController _regLicenseController = TextEditingController();
  final TextEditingController _regExpController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regSpecializationController.dispose();
    _regLicenseController.dispose();
    _regExpController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (!_isLoginMode) {
      setState(() {
        _isLoginMode = true;
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _submitLogin() async {
    String identifier = _loginIdentifierController.text.trim();
    String password = _loginPasswordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Please fill all login fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['token'] != null) {
        final userData = res['user'] ?? {};
        String role = (userData['role'] ?? '').toString().toLowerCase();

        if (role == 'patient') {
          _showError('This account is registered as Patient. Please use Patient Login.');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', 'caretaker');
        await prefs.setString('token', res['token']);

        final dynamic rawUserId = userData['id'] ?? userData['user_id'];
        if (rawUserId != null) {
          await prefs.setInt('userId', int.tryParse(rawUserId.toString()) ?? 0);
        }

        await prefs.setString('savedPhone', userData['phone_number']?.toString() ?? '');

        final dynamic rawName = userData['profile']?['full_name'] ??
            userData['full_name'] ??
            'Doctor';
        String docName = rawName.toString();
        await prefs.setString('savedUsername', docName);
        await prefs.setString('full_name', docName);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorMainScreen(),
              settings: RouteSettings(arguments: docName),
            ),
                (route) => false,
          );
        }
      } else {
        _showError(res['error'] ?? 'Incorrect credentials!');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Connection error: $e');
    }
  }

  Future<void> _submitRegistration() async {
    String name = _regNameController.text.trim();
    String phone = _regPhoneController.text.trim();
    String email = _regEmailController.text.trim();
    String specialization = _regSpecializationController.text.trim();
    String license = _regLicenseController.text.trim();
    String expText = _regExpController.text.trim();
    String password = _regPasswordController.text.trim();
    String confirmPassword = _regConfirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Full Name, Mobile Number, and Password are required!');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match!');
      return;
    }

    int? expYears = int.tryParse(expText);

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.signup(
        phoneNumber: phone,
        email: email.isNotEmpty ? email : null,
        password: password,
        role: 'caretaker',
        fullName: name,
        specialization: specialization.isNotEmpty ? specialization : 'General Caregiver',
        licenseNumber: license.isNotEmpty ? license : null,
        experienceYears: expYears,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['user_id'] != null || res['message'] != null || res['token'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor account created successfully! Please login with your credentials.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isLoginMode = true;
          _loginIdentifierController.text = phone;
        });
      } else {
        _showError(res['error'] ?? 'Doctor registration failed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Server connection error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  InputDecoration _inputDecor({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _ink, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7F9F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: _ink, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_back, color: _ink, size: 18),
              ),
              onPressed: _handleBackNavigation,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.medical_services_outlined, size: 40, color: _green),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoginMode ? 'Doctor / Caretaker Login' : 'Doctor Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoginMode
                        ? 'Sign in to access your patient visits & care schedules.'
                        : 'Join Sahayak care network as a verified practitioner.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_isLoginMode ? _submitLogin : _submitRegistration),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _isLoginMode ? 'LOGIN' : 'CREATE DOCTOR ACCOUNT',
                        style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoginMode ? "Don't have an account? " : "Already registered? ",
                            style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _isLoginMode ? "Sign Up" : "Login",
                            style: TextStyle(color: _accentOrange, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email or Mobile', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _loginIdentifierController,
          keyboardType: TextInputType.text,
          decoration: _inputDecor(hint: 'doctor@hospital.com or Mobile', icon: Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        Text('Password', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: _ink, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regNameController,
          decoration: _inputDecor(hint: 'Dr. Firstname Lastname', icon: Icons.person_outline),
        ),
        const SizedBox(height: 14),

        Text('Mobile Number *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regPhoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecor(hint: '+91 9876543210', icon: Icons.smartphone_outlined),
        ),
        const SizedBox(height: 14),

        Text('Email Address', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecor(hint: 'doctor@hospital.com', icon: Icons.mail_outline),
        ),
        const SizedBox(height: 14),

        Text('Specialization / Role', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regSpecializationController,
          decoration: _inputDecor(hint: 'e.g. Neurologist, Family Caretaker', icon: Icons.local_hospital_outlined),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medical License #', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _regLicenseController,
                    decoration: _inputDecor(hint: 'e.g. MCI-9821', icon: Icons.badge_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Experience', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _regExpController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecor(hint: 'Yrs', icon: Icons.timeline),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Text('Password *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: _ink, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
        const SizedBox(height: 14),

        Text('Confirm Password *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _regConfirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: _ink, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}