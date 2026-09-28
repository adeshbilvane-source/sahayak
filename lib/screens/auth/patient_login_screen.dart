import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _accentOrange = const Color(0xFFE67E22);

  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    String identifier = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
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
        String role = userData['role'] ?? '';

        if (role != 'patient') {
          _showError('This account is registered as Doctor. Please use Doctor Login.');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', res['token']);

        final dynamic rawUserId = userData['id'] ?? userData['user_id'];
        if (rawUserId != null) {
          await prefs.setInt('userId', int.tryParse(rawUserId.toString()) ?? 0);
        }

        await prefs.setString('savedPhone', userData['phone_number']?.toString() ?? '');

        // Backend response me se dynamically Name nikalna
        final dynamic rawName = userData['profile']?['full_name'] ??
            userData['full_name'] ??
            'User';
        String loggedInName = rawName.toString();
        await prefs.setString('savedUsername', loggedInName);
        await prefs.setString('full_name', loggedInName);

        // Backend response me se dynamically Emergency Number nikalna
        final dynamic rawEmergency = userData['profile']?['emergency_contact'] ??
            userData['emergency_contact'];

        if (rawEmergency != null && rawEmergency.toString().trim().isNotEmpty) {
          String contactStr = rawEmergency.toString().trim();
          // Har possible key me save kar diya taaki emergency screen ko turant mil jaye
          await prefs.setString('savedEmergencyContact', contactStr);
          await prefs.setString('emergency_contact', contactStr);
          await prefs.setString('savedEmergency', contactStr);
        }

        final dynamic rawBlood = userData['profile']?['blood_group'] ?? userData['blood_group'];
        if (rawBlood != null) {
          await prefs.setString('savedBloodGroup', rawBlood.toString());
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/patient_home', arguments: loggedInName);
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.hub, size: 36, color: _green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SAHAYAK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: _accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue to your family support hub.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter Email/Mobile number',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: '+91 **********',
                          prefixIcon: Icon(Icons.smartphone_outlined, color: _ink),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F6),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Enter Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••••••••••',
                          prefixIcon: Icon(Icons.lock_outline, color: _ink),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F6),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Login', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?', style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade200.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_add_alt_1_outlined, color: _ink, size: 22),
                          const SizedBox(width: 12),
                          Text("Don't have an account?", style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Row(
                          children: [
                            Text('Create account', style: TextStyle(color: _accentOrange, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: _accentOrange, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}