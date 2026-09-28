import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color _canvas = const Color(0xFFF8FAF7);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();

  int? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  // Database / SharedPreferences se saved data fetch karke text fields me set karein
  Future<void> _loadInitialUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      _nameController.text = prefs.getString('savedUsername') ?? '';
      _phoneController.text = prefs.getString('savedPhone') ?? '';
      _emergencyController.text = prefs.getString('savedEmergency') ?? '';
      _bloodGroupController.text = prefs.getString('savedBloodGroup') ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String emergency = _emergencyController.text.trim();
    String blood = _bloodGroupController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name aur Phone Number khali nahi ho sakte'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Backend API Call to update database
      final res = await ApiService.updateProfile(
        userId: _userId ?? 1,
        fullName: name,
        phoneNumber: phone,
        emergencyContact: emergency,
        bloodGroup: blood,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['message'] != null) {
        // SharedPreferences update karein taaki Home Screen aur Settings Screen par turant naya data dikhe
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedUsername', name);
        await prefs.setString('savedPhone', phone);
        await prefs.setString('savedEmergency', emergency);
        await prefs.setString('savedBloodGroup', blood);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, name); // Go back with updated name
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Profile update fail ho gaya'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text('Edit Profile', style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Photo with Edit Badge
            Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 60, backgroundColor: _green.withValues(alpha: 0.2), child: Icon(Icons.person, size: 60, color: _green)),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery Opening...'))),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: _green, shape: BoxShape.circle, border: Border.all(color: _canvas, width: 3)),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Input Fields
            _buildTextField('Full Name', Icons.person, _nameController),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', Icons.phone, _phoneController),
            const SizedBox(height: 16),
            _buildTextField('Emergency Contact', Icons.health_and_safety, _emergencyController),
            const SizedBox(height: 16),
            _buildTextField('Blood Group', Icons.bloodtype, _bloodGroupController),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _green),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _green, width: 2)),
      ),
    );
  }
}