import 'package:flutter/material.dart';
import '../../api_service.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _accentOrange = const Color(0xFFE67E22);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    String username = _usernameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String ageText = _ageController.text.trim();
    String emergency = _emergencyContactController.text.trim();

    // Validations
    if (username.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Username, Mobile Number aur Password zaroori hain!');
      return;
    }

    if (emergency.isEmpty) {
      _showError('Family Emergency Contact Number daalna zaroori hai!');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords match nahi kar rahe!');
      return;
    }

    int? age = int.tryParse(ageText);

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.signup(
        phoneNumber: phone,
        email: email.isNotEmpty ? email : null,
        password: password,
        role: 'patient',
        fullName: username,
        age: age,
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        emergencyContact: emergency,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Agar account successfully ban gaya
      if (res['user_id'] != null || res['message'] != null || res['token'] != null) {
        // YAHAN KOI BHI SESSION YA USER DATA SAVE NAHI HOGA
        // User ko manual login karna hoga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully ban gaya! Kripya apna mobile number aur password dalkar login karein.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(res['error'] ?? 'Registration fail ho gaya.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Server se connect nahi ho paya: $e');
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
      prefixIcon: Icon(icon, color: _ink),
      filled: true,
      fillColor: const Color(0xFFF7F9F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: _ink, width: 1.5), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.arrow_back, color: _ink, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: _green.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.hub, size: 36, color: _green),
              ),
              const SizedBox(height: 8),
              Text('SAHAYAK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: _accentOrange)),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Register HERE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _ink, fontFamily: 'serif')),
                    const SizedBox(height: 6),
                    Text('Sign-up to continue to your family support hub.', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    Text('Username *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      decoration: _inputDecor(hint: 'Enter your full name', icon: Icons.person_outline),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    Text('Mobile Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecor(hint: '+91 9876543210', icon: Icons.smartphone_outlined),
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecor(hint: 'example@gmail.com', icon: Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),

                    // Age & Gender Row
                    Row(
                      children: [
                        // Age
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Age', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecor(hint: 'e.g. 65', icon: Icons.cake_outlined),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Gender Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: _inputDecor(hint: 'Select', icon: Icons.wc_outlined),
                                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                                onChanged: (val) => setState(() => _selectedGender = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Blood Group
                    Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodGroup,
                      decoration: _inputDecor(hint: 'Select blood group', icon: Icons.bloodtype_outlined),
                      items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) => setState(() => _selectedBloodGroup = val),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact
                    Text('Emergency Contact Number (Family Member) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecor(hint: 'Family member contact number', icon: Icons.contact_phone_outlined),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Text('Enter Password *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
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
                    const SizedBox(height: 16),

                    // Confirm Password
                    Text('Re-Enter Password *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: '••••••••••••••••',
                        prefixIcon: Icon(Icons.lock_outline, color: _ink),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
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
                      Text('Create Account', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}