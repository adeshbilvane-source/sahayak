import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class DoctorNotificationsTab extends StatefulWidget {
  const DoctorNotificationsTab({super.key});

  @override
  State<DoctorNotificationsTab> createState() => _DoctorNotificationsTabState();
}

class _DoctorNotificationsTabState extends State<DoctorNotificationsTab> {
  final Color _primaryDark = const Color(0xFF233621);
  List<dynamic> _pendingRequests = [];
  bool _isLoading = true;
  int _caretakerId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _caretakerId = prefs.getInt('userId') ?? 0;
    await _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (_caretakerId == 0) return;
    setState(() => _isLoading = true);

    final reqs = await ApiService.getPendingRequests(_caretakerId);
    if (mounted) {
      setState(() {
        _pendingRequests = reqs;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRequest(int requestId, String status) async {
    bool success = await ApiService.updateRequestStatus(requestId, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request $status successfully!'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
      _fetchRequests();
    }
  }

  Widget _buildSafeAvatar(String? img) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: 24, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryDark));
    }
    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        while (cleanBase64.length % 4 != 0) cleanBase64 += '=';
        return CircleAvatar(radius: 24, backgroundImage: MemoryImage(base64Decode(cleanBase64)));
      } else if (img.startsWith('http')) {
        return CircleAvatar(radius: 24, backgroundImage: NetworkImage(img));
      } else {
        return CircleAvatar(radius: 24, backgroundImage: FileImage(File(img)));
      }
    } catch (_) {
      return CircleAvatar(radius: 24, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryDark));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
          ? const Center(child: Text('No new requests.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          var req = _pendingRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildSafeAvatar(req['profile_image']),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['full_name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('Wants to connect with you.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleRequest(req['request_id'], 'rejected'),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                          child: const Text('Decline', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleRequest(req['request_id'], 'accepted'),
                          style: ElevatedButton.styleFrom(backgroundColor: _primaryDark),
                          child: const Text('Accept', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}