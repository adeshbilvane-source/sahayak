import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../doctor/doctor_home_screen.dart';
import '../../api_service.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);

  bool _isLogin = true;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    String identifier = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String drName = _usernameController.text.trim();

    if (identifier.isEmpty || password.isEmpty || (!_isLogin && drName.isEmpty)) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // DOCTOR LOGIN API
        final res = await ApiService.login(
          identifier: identifier,
          password: password,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (res['token'] != null) {
          String role = res['user']['role'] ?? '';
          if (role != 'caretaker') {
            _showError('This is not a Doctor account. Please use Patient Login.');
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('token', res['token']);
          // main.dart ke check ke sath match karne ke liye 'doctor' set kiya gaya hai
          await prefs.setString('userRole', 'doctor');

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          _showError(res['error'] ?? 'Incorrect credentials!');
        }
      } else {
        // DOCTOR SIGNUP API
        final res = await ApiService.signup(
          phoneNumber: identifier,
          password: password,
          role: 'caretaker',
          fullName: drName,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (res['user_id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor Account Created! Please Login.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isLogin = true;
            _passwordController.clear();
          });
        } else {
          _showError(res['error'] ?? 'Registration failed');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Connection error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _ink),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 80, color: _green),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Doctor Login' : 'Create Doctor Account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _ink),
                ),
                const SizedBox(height: 40),

                if (!_isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Dr. Name',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email or Mobile',
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      _isLogin ? 'LOGIN' : 'SIGN UP',
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                    style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}