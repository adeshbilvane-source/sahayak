import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_service.dart';

class CaregiversScheduleScreen extends StatefulWidget {
  const CaregiversScheduleScreen({super.key});

  @override
  State<CaregiversScheduleScreen> createState() => _CaregiversScheduleScreenState();
}

class _CaregiversScheduleScreenState extends State<CaregiversScheduleScreen> {
  final Color _bgCanvas = const Color(0xFFF7F8F5);
  final Color _primaryGreen = const Color(0xFF2E5140);
  final Color _textDark = const Color(0xFF1E2822);
  final Color _orangeBtn = const Color(0xFFD98A2B);

  int _selectedBottomIndex = 0;

  // Real Patient Data
  String _patientName = 'Loading...';
  int _patientUserId = 0;
  String _patientIdStr = '#SAH-2026';
  String? _patientProfileImage;

  // Real Data
  List<dynamic> _realCaregivers = [];
  List<dynamic> _myAppointments = [];
  bool _isLoading = true;

  // Connected doctors for Chat (Instagram style list)
  List<dynamic> _connectedDoctorsForChat = [];

  // Booking Form Controllers
  final TextEditingController _dateController = TextEditingController(text: 'Fri, 28 Aug');
  final TextEditingController _timeController = TextEditingController(text: '10:30 AM');
  final TextEditingController _reasonController = TextEditingController(text: 'Routine Checkup');
  int? _selectedCaregiverId;

  // Chat state
  int? _activeChatDoctorId;
  String? _activeChatDoctorName;
  String? _activeChatDoctorImage;
  final TextEditingController _msgInputController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'doctor', 'text': 'Hello! How can I help you today?'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientDataAndAppointments();
  }

  Future<void> _loadPatientDataAndAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    int uId = prefs.getInt('userId') ?? 0;

    if (mounted) {
      setState(() {
        _patientName = prefs.getString('savedUsername') ?? prefs.getString('full_name') ?? 'Patient';
        _patientUserId = uId;
        _patientIdStr = '#SAH-2026-0$uId';
        _patientProfileImage = prefs.getString('profile_image');
      });
    }

    _fetchCaregiversAndAppointments();
    _fetchConnectedDoctorsForChat();
  }

  Future<void> _fetchCaregiversAndAppointments() async {
    if (_patientUserId == 0) return;

    setState(() => _isLoading = true);
    final caretakers = await ApiService.getAllCaretakers();
    final appointments = await ApiService.getPatientAppointments(_patientUserId);

    if (mounted) {
      setState(() {
        _realCaregivers = caretakers;
        _myAppointments = appointments;
        _isLoading = false;

        if (caretakers.isNotEmpty && _selectedCaregiverId == null) {
          _selectedCaregiverId = caretakers[0]['user_id'];
        }
      });
    }
  }

  Future<void> _fetchConnectedDoctorsForChat() async {
    if (_patientUserId == 0) return;
    final caretakers = await ApiService.getPatientAcceptedCaretakers(_patientUserId);
    if (mounted) {
      setState(() {
        _connectedDoctorsForChat = caretakers;
        if (caretakers.isNotEmpty && _activeChatDoctorId == null) {
          _activeChatDoctorId = caretakers[0]['caretaker_id'];
          _activeChatDoctorName = caretakers[0]['full_name'];
          _activeChatDoctorImage = caretakers[0]['profile_image'];
        }
      });
    }
  }

  // --- BOOK SLOT DIALOG ---
  void _showBookSlotDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Book Appointment Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Caretaker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: _selectedCaregiverId,
                  items: _realCaregivers.map<DropdownMenuItem<int>>((doc) {
                    return DropdownMenuItem<int>(
                      value: doc['user_id'],
                      child: Text(doc['full_name'] ?? 'Doctor'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCaregiverId = val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _timeController,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                const Text('Reason / Symptoms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (_selectedCaregiverId == null) return;
                Navigator.pop(context);

                bool success = await ApiService.bookAppointment(
                  _patientUserId,
                  _selectedCaregiverId!,
                  _dateController.text.trim(),
                  _timeController.text.trim(),
                  _reasonController.text.trim(),
                );

                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment requested successfully!'), backgroundColor: Colors.green));
                  }
                  _loadPatientDataAndAppointments();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book appointment.'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Send Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchVideoCall() async {
    final Uri url = Uri.parse('https://meet.jit.si/SahayakTeleconsultation');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open video call link')));
        }
      }
    } catch (e) {
      debugPrint('Video call error: $e');
    }
  }

  Widget _buildSafeAvatar(String? img, {double radius = 24}) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: _primaryGreen.withValues(alpha: 0.2), child: Icon(Icons.person, color: _primaryGreen, size: radius));
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
      return CircleAvatar(radius: radius, backgroundColor: _primaryGreen.withValues(alpha: 0.2), child: Icon(Icons.person, color: _primaryGreen, size: radius));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedBottomIndex,
                    children: [
                      _buildAppointmentsTab(),
                      _buildCaregiversTab(),
                      _buildMessagesTab(),
                      _buildProfileTab(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    String title = ['Appointments', 'Find Caregivers', 'Live Messages', 'Patient Profile'][_selectedBottomIndex];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFECEFE8), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _selectedBottomIndex != 0 ? setState(() => _selectedBottomIndex = 0) : Navigator.pop(context),
            child: const Row(children: [Icon(Icons.arrow_back, color: Colors.black, size: 22), SizedBox(width: 4), Text('BACK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
          ),
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _textDark, fontFamily: 'serif')),
          IconButton(icon: const Icon(Icons.translate, color: Colors.black), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return RefreshIndicator(
      onRefresh: _loadPatientDataAndAppointments,
      color: _primaryGreen,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('NEED A CONSULTATION?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFC7DFD0))),
                    SizedBox(height: 6),
                    Text('Request Doctor\nVisit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _orangeBtn, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _showBookSlotDialog,
                  child: const Text('+ Book\nSlot', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('YOUR SCHEDULED VISITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade700)),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_myAppointments.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text("No appointments booked yet.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("Tap '+ Book Slot' above to schedule with a Doctor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          else
            ..._myAppointments.map((appt) {
              String docName = appt['caretaker_name'] ?? 'Doctor';
              String spec = appt['specialization'] ?? 'Family Doctor';
              String date = appt['appointment_date'] ?? '';
              String time = appt['appointment_time'] ?? '';
              String status = appt['status'] ?? 'pending';
              String? img = appt['profile_image'];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildSafeAvatar(img),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(docName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _textDark)),
                              const SizedBox(height: 2),
                              Text(spec, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: status == 'accepted' ? const Color(0xFFE2EFE5) : Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: status == 'accepted' ? const Color(0xFF386646) : Colors.orange.shade800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: _bgCanvas, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [const Text('🗓  ', style: TextStyle(fontSize: 14)), Text(date, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800))]),
                          Row(children: [const Text('⏰  ', style: TextStyle(fontSize: 14)), Text(time, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reason: ${appt['reason'] ?? 'Checkup'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                        if (status == 'accepted')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                            icon: const Icon(Icons.videocam, size: 16, color: Colors.white),
                            label: const Text('Video Call', style: TextStyle(color: Colors.white, fontSize: 12)),
                            onPressed: _launchVideoCall,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCaregiversTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text('All Available Caretakers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
        const SizedBox(height: 4),
        Text('Find a doctor and book a slot directly.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 14),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ..._realCaregivers.map((caretaker) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildSafeAvatar(caretaker['profile_image'], radius: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(caretaker['full_name'] ?? 'Doctor', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(caretaker['specialization'] ?? 'Caretaker', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        setState(() {
                          _selectedCaregiverId = caretaker['user_id'];
                          _selectedBottomIndex = 0;
                        });
                        _showBookSlotDialog();
                      },
                      child: const Text('Book Slot', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- MESSAGES TAB (INSTAGRAM STYLE CONNECTED DOCTORS LIST & CHAT) ---
  Widget _buildMessagesTab() {
    if (_connectedDoctorsForChat.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No connected doctors yet.\nConnect with a caretaker to start chatting!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Connected Doctors Horizontal List (Instagram Story / Chat list style)
        Container(
          height: 85,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _connectedDoctorsForChat.length,
            itemBuilder: (context, index) {
              var doc = _connectedDoctorsForChat[index];
              bool isSelected = _activeChatDoctorId == doc['caretaker_id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeChatDoctorId = doc['caretaker_id'];
                    _activeChatDoctorName = doc['full_name'];
                    _activeChatDoctorImage = doc['profile_image'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? _primaryGreen : Colors.transparent, width: 2),
                        ),
                        child: _buildSafeAvatar(doc['profile_image'], radius: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(doc['full_name'] ?? 'Doctor', style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // Active Chat Header (Fixed string interpolation syntax here)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFF9FBF7),
          child: Row(
            children: [
              _buildSafeAvatar(_activeChatDoctorImage, radius: 16),
              const SizedBox(width: 8),
              Text('Chatting with ${_activeChatDoctorName ?? 'Doctor'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        const Divider(height: 1),

        // Messages List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final bool isMe = msg['sender'] == 'patient';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
                ),
              );
            },
          ),
        ),

        // Message Input Box
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgInputController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    filled: true,
                    fillColor: const Color(0xFFF1F4EE),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: _primaryGreen,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () {
                    if (_msgInputController.text.trim().isNotEmpty) {
                      setState(() {
                        _messages.add({'sender': 'patient', 'text': _msgInputController.text.trim()});
                        _msgInputController.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              _buildSafeAvatar(_patientProfileImage, radius: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Patient ID: $_patientIdStr', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.calendar_month, 'Appointments', 0),
            _buildNavItem(Icons.people_alt_outlined, 'Caregivers', 1),
            _buildNavItem(Icons.chat_bubble_outline, 'Messages', 2),
            _buildNavItem(Icons.account_circle_outlined, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottomIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? _primaryGreen : Colors.black54, size: 24),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? _primaryGreen : Colors.black54)),
          if (isSelected) Container(margin: const EdgeInsets.only(top: 2), height: 2.5, width: 24, decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }
}