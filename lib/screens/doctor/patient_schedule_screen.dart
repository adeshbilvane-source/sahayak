import 'package:flutter/material.dart';

class PatientScheduleScreen extends StatefulWidget {
  const PatientScheduleScreen({super.key});

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  // Theme Colors based on the UI
  final Color _primaryDark = const Color(0xFF1E2D1E); // Dark green for text and active states
  final Color _bgHint = const Color(0xFFFFFFFF); // White background
  final Color _cardBg = const Color(0xFFEFF2EC); // Light grayish green for cards
  final Color _topBarBg = const Color(0xFFF3F5F0); // Very light background for top sections
  final Color _fabColor = const Color(0xFFB54536); // Red color for floating call button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgHint,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Title and Date Selector
            Container(
              color: _topBarBg,
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  _buildDateSelectorRow(),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Today, Tue, Sep 22 • 2 VISITS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 1: Nurse Appointment
                    _buildVisitCard(
                      time: '12:00 AM',
                      name: 'Nurse Sarah Jahan',
                      designation: 'Medication Support',
                      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=150&q=80', // Replace with AssetImage later
                      buttonText: 'Reschedule Appointment',
                      isPrimaryButton: true,
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Doctor Appointment
                    _buildVisitCard(
                      time: '5:00 AM',
                      name: 'Doctor Jhonny',
                      designation: 'Physiotherapy Session',
                      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=150&q=80', // Replace with AssetImage later
                      buttonText: 'Request a Urgent Call',
                      isPrimaryButton: false,
                    ),

                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Call
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _fabColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 28),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: _primaryDark, size: 28),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'BACK',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Title
          Text(
            'Patients Schedule',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
          // Action Icons
          Row(
            children: [
              Icon(Icons.translate, color: _primaryDark, size: 26),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateItem('Mon', '21', isActive: false),
            _buildDateItem('Tue', '22', isActive: true, hasDot: true),
            _buildDateItem('Wed', '23', isActive: false, hasDot: true),
            _buildDateItem('Thu', '24', isActive: false),
            _buildDateItem('Fri', '25', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(String day, String date, {bool isActive = false, bool hasDot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? _primaryDark : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white70 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
          if (hasDot) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildVisitCard({
    required String time,
    required String name,
    required String designation,
    required String imageUrl,
    required String buttonText,
    required bool isPrimaryButton,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designation,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile Image Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 90,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // Action Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimaryButton ? _primaryDark : Colors.white,
                foregroundColor: isPrimaryButton ? Colors.white : _primaryDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isPrimaryButton ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}