import 'package:flutter/material.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Doctor ke liye alag Temporary Database
  final Map<String, String> _dummyDatabase = {
    'doctor@gmail.com': '123456'
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAuth() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && _usernameController.text.trim().isEmpty)) {
      _showError('Please fill all fields');
      return;
    }

    if (_isLogin) {
      if (_dummyDatabase.containsKey(email) && _dummyDatabase[email] == password) {
        // Yahan doctor ke home page par jayega (abhi ke liye route add kiya hai)
        Navigator.pushReplacementNamed(context, '/doctor_home');
      } else {
        _showError('Incorrect Email or Password!');
      }
    } else {
      if (_dummyDatabase.containsKey(email)) {
        _showError('Account already exists! Please Login.');
      } else {
        _dummyDatabase[email] = password;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor Account Created! Please Login.'), backgroundColor: Colors.green),
        );
        setState(() {
          _isLogin = true;
          _passwordController.clear();
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
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
                Icon(Icons.medical_services_outlined, size: 80, color: _green), // Doctor Icon
                const SizedBox(height: 16),
                Text(_isLogin ? 'Doctor Login' : 'Create Doctor Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _ink)),
                const SizedBox(height: 40),
                
                if (!_isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Dr. Name', prefixIcon: const Icon(Icons.person), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _submitAuth,
                    style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(_isLogin ? 'LOGIN' : 'SIGN UP', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login", style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}