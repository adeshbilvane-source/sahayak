import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _pickedImageFile;
  String? _existingProfileImage; // Existing image from database/prefs

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  Future<void> _loadInitialUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      _nameController.text = prefs.getString('savedUsername') ?? '';
      _phoneController.text = prefs.getString('savedPhone') ?? '';
      _emergencyController.text = prefs.getString('savedEmergency') ?? prefs.getString('emergency_contact') ?? '';
      _bloodGroupController.text = prefs.getString('savedBloodGroup') ?? '';
      _existingProfileImage = prefs.getString('profile_image');
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

  // Camera ya Gallery se photo pick karne ka bottom sheet
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: _green),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: _green),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (picked != null) {
        setState(() {
          _pickedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveChanges() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String emergency = _emergencyController.text.trim();
    String blood = _bloodGroupController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name aur Phone Number required hain!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? base64Image;
      if (_pickedImageFile != null) {
        final bytes = await _pickedImageFile!.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final res = await ApiService.updateProfile(
        userId: _userId ?? 1,
        fullName: name,
        phoneNumber: phone,
        emergencyContact: emergency,
        bloodGroup: blood,
        profileImage: base64Image ?? _existingProfileImage,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['message'] != null || res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedUsername', name);
        await prefs.setString('savedPhone', phone);
        await prefs.setString('savedEmergency', emergency);
        await prefs.setString('emergency_contact', emergency);
        await prefs.setString('savedBloodGroup', blood);

        if (_pickedImageFile != null) {
          await prefs.setString('profile_image', _pickedImageFile!.path);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
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

  Widget _buildAvatarPreview() {
    if (_pickedImageFile != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    }

    if (_existingProfileImage != null && _existingProfileImage!.isNotEmpty) {
      if (_existingProfileImage!.startsWith('http')) {
        return CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(_existingProfileImage!),
        );
      } else if (_existingProfileImage!.startsWith('/') || _existingProfileImage!.contains('\\')) {
        return CircleAvatar(
          radius: 60,
          backgroundImage: FileImage(File(_existingProfileImage!)),
        );
      } else {
        return CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage(_existingProfileImage!),
        );
      }
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: _green.withValues(alpha: 0.15),
      child: Icon(Icons.person, size: 60, color: _green),
    );
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
            Center(
              child: Stack(
                children: [
                  _buildAvatarPreview(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                          border: Border.all(color: _canvas, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField('Full Name', Icons.person, _nameController),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', Icons.phone, _phoneController),
            const SizedBox(height: 16),
            _buildTextField('Emergency Contact', Icons.health_and_safety, _emergencyController),
            const SizedBox(height: 16),
            _buildTextField('Blood Group', Icons.bloodtype, _bloodGroupController),
            const SizedBox(height: 40),

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
                    : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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