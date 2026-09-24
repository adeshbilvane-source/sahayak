import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color _canvas = const Color(0xFFF8FAF7);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);

  late TextEditingController _nameController;
  final TextEditingController _phoneController = TextEditingController(text: '+91 9876543210');
  final TextEditingController _emergencyController = TextEditingController(text: '+91 8765432109');
  final TextEditingController _bloodGroupController = TextEditingController(text: 'O+');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _nameController = TextEditingController(text: (args != null && args is String) ? args : 'Adesh Bilvane');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(backgroundColor: _canvas, elevation: 0, iconTheme: IconThemeData(color: _ink), title: Text('Edit Profile', style: TextStyle(color: _ink, fontWeight: FontWeight.bold)), centerTitle: true),
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
                    bottom: 0, right: 0,
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
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green));
                  Navigator.pop(context); // Go back to settings
                },
                style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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