import 'package:flutter/material.dart';

class CaregiversScheduleScreen extends StatefulWidget {
  const CaregiversScheduleScreen({super.key});

  @override
  State<CaregiversScheduleScreen> createState() => _CaregiversScheduleScreenState();
}

class _CaregiversScheduleScreenState extends State<CaregiversScheduleScreen> {
  final Color _bgCanvas = const Color(0xFFF7F8F5);
  final Color _primaryGreen = const Color(0xFF2E5140);
  final Color _subHeadingAmber = const Color(0xFFC78436);
  final Color _cardTimeBg = const Color(0xFFE8F2DC);
  final Color _textDark = const Color(0xFF1E2822);
  final Color _orangeBtn = const Color(0xFFD98A2B);

  int _selectedBottomIndex = 0; // Default Appointments

  // Chat state
  String? _activeChatDoctor;
  final TextEditingController _msgInputController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'doctor', 'text': 'Hello! How are you feeling today?'},
    {'sender': 'patient', 'text': 'I have a slight headache since morning.'},
    {'sender': 'doctor', 'text': 'Please make sure to take your vitals and rest.'},
  ];

  // Dummy Data for Caregivers & Profile Visits
  final List<Map<String, dynamic>> _todayVisits = [
    {
      'time': '9:00',
      'period': 'AM',
      'name': 'Schumacher, Elias',
      'role': 'Routine Checkup - Check Vitals',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'isActive': true,
      'status': 'Confirmed',
    },
    {
      'time': '08:21',
      'period': 'AM',
      'name': 'Fischer, Lea',
      'role': 'Routine Checkup - Check Vitals',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'isActive': false,
      'status': 'Confirmed',
    },
    {
      'time': '08:37',
      'period': 'AM',
      'name': 'Angelika, Lorenz',
      'role': 'Routine Checkup - Check Vitals',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'isActive': false,
      'status': 'Pending Approval',
    },
  ];

  @override
  void dispose() {
    _msgInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      body: SafeArea(
        child: Column(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice Assistant Listening...')),
          );
        },
        backgroundColor: _primaryGreen,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.mic, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ----------------------------------------------------
  // TOP BAR HEADER
  // ----------------------------------------------------
  Widget _buildHeader() {
    String title = 'Appointments';
    if (_selectedBottomIndex == 1) title = 'Find Caregivers';
    if (_selectedBottomIndex == 2) title = 'Live Messages';
    if (_selectedBottomIndex == 3) title = 'Patient Profile';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFE8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_selectedBottomIndex != 0) {
                setState(() => _selectedBottomIndex = 0);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black, size: 22),
                SizedBox(width: 4),
                Text(
                  'BACK',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontFamily: 'serif',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 0: APPOINTMENTS (1st Photo Exact Design)
  // ----------------------------------------------------
  Widget _buildAppointmentsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // 1. NEED A CONSULTATION? BANNER
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _primaryGreen.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'NEED A CONSULTATION?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC7DFD0),
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Request Doctor\nVisit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeBtn,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor booking request sent!')),
                  );
                },
                child: const Text(
                  '+ Book\nSlot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'YOUR SCHEDULED VISITS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),

        // 2. CONFIRMED DOCTOR VISIT CARD
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF4A3E8A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Sharma',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Family Doctor',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CONFIRMED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF386646),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Date & Time Pills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _bgCanvas,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Text('🗓️ ', style: TextStyle(fontSize: 14)),
                        Text('Fri, 28 Aug', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('⏰ ', style: TextStyle(fontSize: 14)),
                        Text('10:30 AM', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reason: Blood Pressure & Memory Review',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ----------------------------------------------------
  // TAB 1: CAREGIVERS (Fix Appointment, Call, Video, Chat)
  // ----------------------------------------------------
  Widget _buildCaregiversTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(
          'Select & Connect with Caretaker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
        ),
        const SizedBox(height: 4),
        Text('Book a session or connect directly via Call/Chat.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 14),

        ..._todayVisits.map((caretaker) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 26, backgroundImage: NetworkImage(caretaker['avatar'])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(caretaker['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(caretaker['role'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Available Today', style: TextStyle(color: _primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.call, size: 16, color: Colors.white),
                        label: const Text('Call', style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting Voice Call with ${caretaker['name']}...')));
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.videocam, size: 16, color: Colors.white),
                        label: const Text('Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joining Video Call with ${caretaker['name']}...')));
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.black87),
                        label: const Text('Message', style: TextStyle(color: Colors.black87, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            _activeChatDoctor = caretaker['name'];
                            _selectedBottomIndex = 2;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // TAB 2: MESSAGES (Chatting Screen)
  // ----------------------------------------------------
  Widget _buildMessagesTab() {
    String chatHeaderName = _activeChatDoctor ?? 'Dr. Schumacher, Elias';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chatHeaderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Online • Caretaker Support', style: TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.call, size: 20), onPressed: () {}),
            ],
          ),
        ),
        const Divider(height: 1),

        // Chat message bubbles
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
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    color: isMe ? _primaryGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    msg['text'],
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13),
                  ),
                ),
              );
            },
          ),
        ),

        // Text input field
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgInputController,
                  decoration: InputDecoration(
                    hintText: 'Type your symptoms or question...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    String text = _msgInputController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _messages.add({'sender': 'patient', 'text': text});
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

  // ----------------------------------------------------
  // TAB 3: PROFILE & APPOINTMENT REQUEST DETAILS
  // ----------------------------------------------------
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        // Profile Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: _primaryGreen.withOpacity(0.2),
                child: Icon(Icons.person, size: 36, color: _primaryGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Adesh Bilvane', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Patient ID: #SAH-2026-04', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _cardTimeBg, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Blood: A+', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Age: 26', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Requested Appointments Section
        Text(
          'Your Appointment Requests',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
        ),
        const SizedBox(height: 10),

        ..._todayVisits.map((visit) {
          bool isConfirmed = visit['status'] == 'Confirmed';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  isConfirmed ? Icons.check_circle : Icons.hourglass_top_rounded,
                  color: isConfirmed ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visit['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${visit['time']} ${visit['period']} • ${visit['role']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConfirmed ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    visit['status'] ?? 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isConfirmed ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // BOTTOM NAVIGATION DOCK
  // ----------------------------------------------------
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
            const SizedBox(width: 40), // Center mic gap
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
          Icon(
            icon,
            color: isSelected ? _primaryGreen : Colors.black54,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _primaryGreen : Colors.black54,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2.5,
              width: 24,
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}