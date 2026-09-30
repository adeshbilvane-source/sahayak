import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import 'doctor_schedule_screen.dart';
import 'patient_schedule_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  // Theme Colors
  final Color _primaryDark = const Color(0xFF233621);
  final Color _bgHint = const Color(0xFFF2F4EF);
  final Color _lightGreen = const Color(0xFF86B837);
  final Color _lightBlue = const Color(0xFFB5D1E8);

  String _doctorName = 'Doctor';

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  // SharedPreferences se logged-in doctor ka name dynamically load karein
  Future<void> _loadDoctorData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('savedUsername') ?? prefs.getString('full_name');
    if (savedName != null && savedName.trim().isNotEmpty && mounted) {
      setState(() {
        _doctorName = savedName.trim();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route arguments se bhi name accept karein agar pass hua ho
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && args.trim().isNotEmpty) {
      _doctorName = args.trim();
    }
  }

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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Session clear karein taaki auto-login loop na bane
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!mounted) return;
              // 2. Direct landing/role selection LoginScreen par bhej kar stack clear karein
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B2F27),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Safe back navigation: Stack crash na ho isliye directly landing screen par redirect
  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showLogoutDialog(); // Phone back press par logout confirm karein
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAF7),
        body: Stack(
          children: [
            // Background Decoration
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFFF3F6F0)),
                ),
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
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _handleBack,
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
            IconButton(
              icon: Icon(Icons.logout, color: _primaryDark, size: 26),
              onPressed: _showLogoutDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/image 2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.bold, color: _primaryDark),
              ),
              Text(
                _doctorName, // DYNAMIC LOGGED-IN DOCTOR NAME
                style: TextStyle(fontFamily: 'serif', fontSize: 24, color: _primaryDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Patients, Appointments...',
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: _primaryDark, size: 28),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                  'Your Appointments',
                  style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay on track with your Patients visits.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DoctorScheduleScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 85,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAppointmentCard(
                'Mon',
                '23',
                '10:00 AM',
                'Kamla Raj...',
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80',
              ),
              const SizedBox(width: 16),
              _buildAppointmentCard(
                'Wed',
                '30',
                '06:00 PM',
                'Ramesh Patil...',
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
              ),
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
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildManagePatientsCard() {
    return Container(
      height: 160,
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
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
              child: Image.asset(
                'assets/image 1.png',
                width: 290,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Your Patients', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Manage records, health history, & ongoing care.', style: TextStyle(color: Colors.black, fontSize: 13, height: 1.3)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatientScheduleScreen()),
                      );
                    },
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
      height: 160,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _lightBlue),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
              child: Container(
                width: 250,
                height: 160,
                color: _lightBlue,
                child: Image.asset(
                  'assets/image 2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 16,
            bottom: 16,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Patients Analytics', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Track health trends, treatment outcomes, & metrics', style: TextStyle(color: Colors.black, fontSize: 13, height: 1.2)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
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
                right: 2,
                top: 2,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showLogoutDialog,
            child: Icon(Icons.account_circle_outlined, color: _primaryDark, size: 28),
          ),
        ],
      ),
    );
  }
}