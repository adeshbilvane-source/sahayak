import 'package:flutter/material.dart';
// Apni login_screen.dart file ka sahi path yahan import zaroor karein
import '../auth/login_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  // Theme Colors based on your UI
  final Color _primaryDark = const Color(0xFF233621); // Dark green for text and buttons
  final Color _bgHint = const Color(0xFFF2F4EF); // Light background hint
  final Color _lightGreen = const Color(0xFF86B837); // Manage card green
  final Color _lightBlue = const Color(0xFFB5D1E8); // Analytics card blue

  // Logout Dialog Function
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of your Doctor account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Dialog band karein
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Direct 1st page (LoginScreen) par bhejein aur history clear karein
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B2F27), // Red color for logout
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7), // Main background color
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.eco, size: 300, color: _primaryDark),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 24),
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 30),
                        _buildAppointmentsSection(),
                        const SizedBox(height: 30),
                        const Text(
                          'Manage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildManagePatientsCard(),
                        const SizedBox(height: 16),
                        _buildPatientsAnalyticsCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: _primaryDark, size: 28),
              const SizedBox(width: 4),
              Text(
                'BACK',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _primaryDark),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.translate, color: _primaryDark, size: 26),
            const SizedBox(width: 16),
            Icon(Icons.help_outline, color: _primaryDark, size: 26),
            const SizedBox(width: 16),
            Icon(Icons.menu, color: _primaryDark, size: 30),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/image 1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: _primaryDark),
            ),
            Text(
              'Pranav',
              style: TextStyle(fontFamily: 'serif', fontSize: 24, fontStyle: FontStyle.italic, color: _primaryDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Patients, Appointments, Messages & A...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: _primaryDark, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Appointment',
                  style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay on track with your Patients visits.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'View All',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAppointmentCard('Mon', '23', '10:00 AM', 'Kamla Raj...', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80'),
              const SizedBox(width: 12),
              _buildAppointmentCard('Wed', '30', '06:00 PM', 'Pranav Jali...', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String dayStr, String dateStr, String time, String name, String imageUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEEF5E5), borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayStr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6A902A))),
                Text(dateStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A902A))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
        ],
      ),
    );
  }

  Widget _buildManagePatientsCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.lightGreen.shade400, _lightGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: -10,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
              child: Image.asset(
                'assets/image 2.jpg',
                width: 160,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Your Patients', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Manage records, health history, & ongoing care.', style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.3)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8), elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsAnalyticsCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _lightBlue),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
              child: Container(
                width: 150, height: 140, color: _lightBlue,
                // Yahan bhi aap chaho toh Image.network ki jagah AssetImage use kar sakte ho
                child: Image.network(
                  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=300&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            width: 180,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF9F5EC), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Patients Analytics', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Track health trends, treatment outcomes, & metrics', style: TextStyle(color: Colors.grey.shade700, fontSize: 10, height: 1.2)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8), elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: _primaryDark, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: const [
                Icon(Icons.home, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Icon(Icons.chat_bubble_outline, color: _primaryDark, size: 26),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none, color: _primaryDark, size: 28),
              Positioned(
                right: 2, top: 2,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),

          // PROFILE ICON WITH LOGOUT DIALOG
          GestureDetector(
            onTap: _showLogoutDialog, // Yahan tap karne par logout popup aayega
            child: Icon(Icons.account_circle_outlined, color: _primaryDark, size: 28),
          ),
        ],
      ),
    );
  }
}