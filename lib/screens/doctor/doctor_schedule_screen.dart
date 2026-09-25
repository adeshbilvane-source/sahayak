import 'package:flutter/material.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final Color _primaryDark = const Color(0xFF233621); // Dark green text
  final Color _bgHint = const Color(0xFFF9FAF7); // Main background
  final Color _dateBoxBg = const Color(0xFFEEF5E5); // Light green for time
  final Color _lightGreenText = const Color(0xFF6A902A); // Green text
  final Color _orangeText = const Color(0xFFD98A2B); // Orange for section headers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgHint,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildDateSelectorRow(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TODAY SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today, 22 Sep 2026 . 3 VISITS',
                          style: TextStyle(color: _orangeText, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_month, size: 12, color: Colors.black54),
                              SizedBox(width: 4),
                              Text('View full month', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Active Cards
                    _buildAppointmentCard(time: '9:00\nAM', name: 'Schumacher, Elias', isActive: true, hasDot: true),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(time: '08:21\nAM', name: 'Fischer, Lea', isActive: true),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(time: '08:37\nAM', name: 'Angelika, Lorenz', isActive: true),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(time: '08:18\nAM', name: 'Krämer, Anneliese', isActive: true),

                    const SizedBox(height: 24),

                    // --- FUTURE SECTION ---
                    Text(
                      'WED, SEPT 23 . 3 VISITS',
                      style: TextStyle(color: _orangeText, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Inactive (Greyed out) Cards
                    _buildAppointmentCard(time: '08:21\nAM', name: 'Fischer, Lea', isActive: false),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(time: '08:37\nAM', name: 'Angelika, Lorenz', isActive: false),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(time: '08:18\nAM', name: 'Krämer, Anneliese', isActive: false),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Bottom Icon (Optional based on design)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: _primaryDark,
          child: const Icon(Icons.mic_none, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
            'Caregivers Schedule',
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

  Widget _buildDateSelectorRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Thursday, 22 Sep 2026',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: _primaryDark),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({required String time, required String name, required bool isActive, bool hasDot = false}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isActive ? Colors.grey.shade200 : Colors.transparent),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              // Time Box
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? _dateBoxBg : const Color(0xFFDCE3D6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isActive ? _lightGreenText : _primaryDark, height: 1.2),
                ),
              ),
              const SizedBox(width: 12),
              // Profile Pic
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'), // Dummy photo
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _primaryDark)),
                    const SizedBox(height: 2),
                    Text('Routine Checkup - Check Vitals', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // Call Button
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.phone_in_talk_outlined, size: 20, color: Colors.black),
              ),
            ],
          ),
        ),
        // Active Green Dot Indicator (Slightly outside the left edge)
        if (hasDot)
          Positioned(
            left: -4,
            child: Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(color: Color(0xFF5B7F24), shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}