import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_service.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final Color _primaryDark = const Color(0xFF233621);
  final Color _bgHint = const Color(0xFFF9FAF7);

  int _selectedTabIndex = 0; // 0 = Schedule, 1 = Requests

  // --- REAL DATA STATE ---
  List<dynamic> _realPendingRequests = [];
  List<dynamic> _allAppointments = [];
  bool _isLoadingRequests = true;
  bool _isLoadingSchedule = true;
  int _currentCaretakerId = 0;

  @override
  void initState() {
    super.initState();
    _loadCaretakerData();
  }

  Future<void> _loadCaretakerData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (mounted) {
      setState(() {
        _currentCaretakerId = userId;
      });
    }

    // Jab tak valid caretaker ID na mil jaye, tab tak API call mat karo
    if (_currentCaretakerId > 0) {
      _fetchRealRequests();
      _fetchScheduledAppointments();
    }
  }

  // Pending Appointment Requests
  Future<void> _fetchRealRequests() async {
    if (_currentCaretakerId == 0) return;
    setState(() => _isLoadingRequests = true);
    final requests = await ApiService.getCaretakerPendingAppointments(_currentCaretakerId);
    if (mounted) {
      setState(() {
        _realPendingRequests = requests;
        _isLoadingRequests = false;
      });
    }
  }

  // Fetch All Booked Appointments for this Caretaker
  Future<void> _fetchScheduledAppointments() async {
    if (_currentCaretakerId == 0) return;
    setState(() => _isLoadingSchedule = true);
    final appointments = await ApiService.getCaretakerAppointments(_currentCaretakerId);
    if (mounted) {
      setState(() {
        _allAppointments = appointments;
        _isLoadingSchedule = false;
      });
    }
  }

  Future<void> _handleRequest(int appointmentId, String status, int index) async {
    final removedItem = _realPendingRequests.removeAt(index);
    setState(() {});

    bool success = await ApiService.updateAppointmentStatus(appointmentId, status);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepted' ? 'Appointment Accepted!' : 'Appointment Rejected.'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
      _fetchScheduledAppointments();
    } else {
      setState(() {
        _realPendingRequests.insert(index, removedItem);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update request.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available for this patient')));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
      }
    } catch (e) {
      debugPrint('Call error: $e');
    }
  }

  Widget _buildSafeAvatar(String? img, {double radius = 28}) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryDark, size: radius));
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
      return CircleAvatar(radius: radius, backgroundColor: _primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: _primaryDark, size: radius));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgHint,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildScheduleTab(),
                  _buildRequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _makePhoneCall(_allAppointments.isNotEmpty ? _allAppointments[0]['emergency_contact'] : null),
        backgroundColor: const Color(0xFFC0392B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.phone, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_selectedTabIndex != 0) {
                setState(() => _selectedTabIndex = 0);
              } else {
                Navigator.pop(context);
              }
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: _primaryDark, size: 30),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Text('BACK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _primaryDark)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _selectedTabIndex == 0 ? 'Patients Schedule' : 'Patient Requests',
            style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark),
          ),
          Row(
            children: [
              Icon(Icons.translate, color: _primaryDark, size: 28),
              const Icon(Icons.arrow_drop_down, color: Colors.black, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchScheduledAppointments,
            color: _primaryDark,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                if (_isLoadingSchedule)
                  const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                else if (_allAppointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        "No appointments booked yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ..._allAppointments.map((appt) {
                    String name = appt['patient_name'] ?? 'Patient';
                    String dateStr = appt['appointment_date'] ?? '';
                    String timeStr = appt['appointment_time'] ?? '10:00 AM';
                    String reason = appt['reason'] ?? 'Routine Checkup';
                    String? image = appt['profile_image'];
                    String? emergencyPhone = appt['emergency_contact'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4EF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                          child: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6A902A))),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                          child: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _primaryDark)),
                                    const SizedBox(height: 4),
                                    Text(reason, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildSafeAvatar(image, radius: 32),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              onPressed: () => _makePhoneCall(emergencyPhone),
                              label: const Text(
                                'Call Patient',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _fetchRealRequests,
      color: _primaryDark,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Text('Pending Appointments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryDark)),
          const SizedBox(height: 4),
          Text('Patient appointment requests for checkup.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (_isLoadingRequests)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_realPendingRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text("No pending requests right now.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            )
          else
            ..._realPendingRequests.asMap().entries.map((entry) {
              int index = entry.key;
              var request = entry.value;

              int appointmentId = request['appointment_id'];
              String name = request['patient_name'] ?? 'Unknown Patient';
              String reason = request['reason'] ?? 'Routine Checkup';
              String dateStr = request['appointment_date'] ?? '';
              String timeStr = request['appointment_time'] ?? '';
              String? image = request['profile_image'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSafeAvatar(image, radius: 26),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _primaryDark)),
                                const SizedBox(height: 2),
                                Text('Reason: $reason', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFEEF5E5), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6A902A)),
                                const SizedBox(width: 6),
                                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6A902A))),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Color(0xFF6A902A)),
                                const SizedBox(width: 6),
                                Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6A902A))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () => _handleRequest(appointmentId, 'rejected', index),
                              child: Text('Decline', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () => _handleRequest(appointmentId, 'accepted', index),
                              child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.calendar_month, 'Schedule', 0),
            const SizedBox(width: 40),
            _buildNavItem(Icons.person_add_alt_1, 'Requests', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? _primaryDark : Colors.black54, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _primaryDark : Colors.black54,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: 20,
                decoration: BoxDecoration(color: _primaryDark, borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ),
      ),
    );
  }
}