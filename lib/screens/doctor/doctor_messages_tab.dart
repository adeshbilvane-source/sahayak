import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../api_service.dart';
import 'doctor_chat_screen.dart';

class DoctorMessagesTab extends StatefulWidget {
  const DoctorMessagesTab({super.key});

  @override
  State<DoctorMessagesTab> createState() => _DoctorMessagesTabState();
}

class _DoctorMessagesTabState extends State<DoctorMessagesTab> {
  final Color _primaryDark = const Color(0xFF233621);
  final Color _bgCanvas = const Color(0xFFF9FAF7);

  List<dynamic> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final patients = await ApiService.getAllPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatar(String? img) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: _primaryDark.withValues(alpha: 0.1),
        child: Icon(Icons.person, color: _primaryDark, size: 28),
      );
    }
    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        while (cleanBase64.length % 4 != 0) {
          cleanBase64 += '=';
        }
        return CircleAvatar(
          radius: 24,
          backgroundImage: MemoryImage(base64Decode(cleanBase64)),
        );
      } else if (img.startsWith('http')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(img),
        );
      } else {
        final file = File(img);
        if (file.existsSync()) {
          return CircleAvatar(
            radius: 24,
            backgroundImage: FileImage(file),
          );
        }
      }
    } catch (_) {}
    return CircleAvatar(
      radius: 24,
      backgroundColor: _primaryDark.withValues(alpha: 0.1),
      child: Icon(Icons.person, color: _primaryDark, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Messages',
          style: TextStyle(
            color: _primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? Center(
                  child: Text(
                    'No patient conversations yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _patients.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    final int id = patient['id'] ?? 0;
                    final String name = patient['name'] ?? 'Patient';
                    final String? image = patient['profile_image'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: _buildAvatar(image),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: _primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to open chat',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorChatScreen(
                              patientId: id,
                              patientName: name,
                              profileImage: image,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
