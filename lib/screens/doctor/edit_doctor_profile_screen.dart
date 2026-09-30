import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({super.key});

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final Color _primaryDark = const Color(0xFF233621);
  final Color _bgCanvas = const Color(0xFFF9FAF7);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  String? _profileImageBase64;
  bool _isLoading = false;
  int _caretakerId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _caretakerId = prefs.getInt('userId') ?? 0;

    // Yahan pehle API se latest details fetch karenge
    final data = await ApiService.getUserProfile(_caretakerId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!data.containsKey('error')) {
          var profile = data['profile'] ?? data; // Depending on backend structure
          _nameController.text = profile['full_name'] ?? prefs.getString('savedUsername') ?? '';
          _specializationController.text = profile['specialization'] ?? '';
          _experienceController.text = profile['experience_years']?.toString() ?? '';
          _licenseController.text = profile['license_number'] ?? '';
          _profileImageBase64 = profile['profile_image'] ?? prefs.getString('profile_image');
        } else {
          _nameController.text = prefs.getString('savedUsername') ?? '';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      String base64Img = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        _profileImageBase64 = base64Img;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    int? exp = int.tryParse(_experienceController.text.trim());

    var response = await ApiService.updateCaretakerProfile(
      userId: _caretakerId,
      fullName: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      experienceYears: exp,
      licenseNumber: _licenseController.text.trim(),
      profileImage: _profileImageBase64,
    );

    setState(() => _isLoading = false);

    if (!response.containsKey('error')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUsername', _nameController.text.trim());
      if (_profileImageBase64 != null) {
        await prefs.setString('profile_image', _profileImageBase64!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['error']), backgroundColor: Colors.red));
    }
  }

  Widget _buildSafeAvatar() {
    if (_profileImageBase64 == null || _profileImageBase64!.trim().isEmpty) {
      return CircleAvatar(radius: 50, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, size: 50, color: _primaryDark));
    }
    try {
      String cleanBase64 = _profileImageBase64!.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
      while (cleanBase64.length % 4 != 0) cleanBase64 += '=';
      return CircleAvatar(radius: 50, backgroundImage: MemoryImage(base64Decode(cleanBase64)));
    } catch (e) {
      return CircleAvatar(radius: 50, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, size: 50, color: _primaryDark));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  _buildSafeAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF4A7055), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildInputField('Full Name', Icons.person, _nameController),
            const SizedBox(height: 16),
            _buildInputField('Specialization', Icons.local_hospital, _specializationController),
            const SizedBox(height: 16),
            _buildInputField('Experience (Years)', Icons.timeline, _experienceController, isNumber: true),
            const SizedBox(height: 16),
            _buildInputField('License Number', Icons.badge, _licenseController),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7055),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4A7055), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}