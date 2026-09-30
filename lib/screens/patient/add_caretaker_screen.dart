import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class AddCaretakerScreen extends StatefulWidget {
  const AddCaretakerScreen({super.key});

  @override
  State<AddCaretakerScreen> createState() => _AddCaretakerScreenState();
}

class _AddCaretakerScreenState extends State<AddCaretakerScreen> {
  final Color _primaryGreen = const Color(0xFF2E5140);
  final Color _bgCanvas = const Color(0xFFF7F8F5);

  List<dynamic> _allCaregivers = [];
  List<dynamic> _filteredCaregivers = [];
  bool _isLoading = true;
  int _patientUserId = 0;

  // Un doctors ki IDs store karne ke liye jinko request bhej di gayi hai
  final List<int> _sentRequestDoctorIds = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterDoctors);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _patientUserId = prefs.getInt('userId') ?? 0;

    final caretakers = await ApiService.getAllCaretakers();
    setState(() {
      _allCaregivers = caretakers;
      _filteredCaregivers = caretakers;
      _isLoading = false;
    });
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCaregivers = _allCaregivers.where((doc) {
        String name = (doc['full_name'] ?? '').toLowerCase();
        String spec = (doc['specialization'] ?? '').toLowerCase();
        return name.contains(query) || spec.contains(query);
      }).toList();
    });
  }

  Future<void> _sendRequest(int doctorId, String doctorName) async {
    if (_patientUserId == 0) return;

    bool success = await ApiService.sendConnectionRequest(_patientUserId, doctorId);
    if (success) {
      setState(() {
        _sentRequestDoctorIds.add(doctorId); // Button ko 'Sent' karne ke liye ID add ki
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Request sent to $doctorName!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request already pending or failed.'), backgroundColor: Colors.orange),
      );
    }
  }

  Widget _buildSafeAvatar(String? img, {double radius = 26}) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: _primaryGreen.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryGreen));
    }
    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        while (cleanBase64.length % 4 != 0) cleanBase64 += '=';
        return CircleAvatar(radius: radius, backgroundImage: MemoryImage(base64Decode(cleanBase64)));
      } else if (img.startsWith('http')) {
        return CircleAvatar(radius: radius, backgroundImage: NetworkImage(img));
      } else {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(File(img)));
      }
    } catch (e) {
      return CircleAvatar(radius: radius, backgroundColor: _primaryGreen.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryGreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: _primaryGreen), onPressed: () => Navigator.pop(context)),
        title: Text('Find Caretaker', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name or Specialization...',
                prefixIcon: Icon(Icons.search, color: _primaryGreen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCaregivers.isEmpty
                    ? const Center(child: Text("No doctors found.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                    itemCount: _filteredCaregivers.length,
                    itemBuilder: (context, index) {
                      var doctor = _filteredCaregivers[index];
                      int docId = doctor['user_id'] ?? 0;
                      bool isSent = _sentRequestDoctorIds.contains(docId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: _buildSafeAvatar(doctor['profile_image']),
                          title: Text(doctor['full_name'] ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doctor['specialization'] ?? 'Caretaker', style: const TextStyle(fontSize: 12)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSent ? Colors.grey.shade400 : _primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isSent ? null : () => _sendRequest(docId, doctor['full_name'] ?? 'Doctor'),
                            child: Text(
                              isSent ? 'Sent' : 'Add',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    }
                )
            )
          ],
        ),
      ),
    );
  }
}