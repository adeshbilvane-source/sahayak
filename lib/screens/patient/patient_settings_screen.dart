import 'package:flutter/material.dart';
// Apni login_screen.dart file ka sahi path yahan import zaroor karein
import '../auth/login_screen.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  final Color _canvas = const Color(0xFFF8FAF7);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _red = const Color(0xFF8B2F27);
  final Color _inkSoft = const Color(0xFF5B6A61);

  bool _notificationsEnabled = true;

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Password', style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email to receive a password reset link.', style: TextStyle(color: _inkSoft)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: _inkSoft))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent!'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String userName = (args != null && args is String) ? args : 'Adesh Bilvane';

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(backgroundColor: _canvas, elevation: 0, iconTheme: IconThemeData(color: _ink), title: Text('Settings', style: TextStyle(color: _ink, fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 50, backgroundColor: _green.withValues(alpha: 0.1), child: Icon(Icons.person, size: 50, color: _green)),
                const SizedBox(height: 16),
                Text(userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _ink)),
                Text('Patient Account', style: TextStyle(fontSize: 14, color: _inkSoft)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu Options
          _buildActionItem(Icons.edit_outlined, 'Edit Profile', onTap: () => Navigator.pushNamed(context, '/edit_profile', arguments: userName)),

          // Notification Toggle
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.notifications_outlined, color: _green)),
            title: Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _ink)),
            trailing: Switch(
              value: _notificationsEnabled,
              activeThumbColor: _green,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),

          _buildActionItem(Icons.lock_reset_outlined, 'Reset Password', onTap: _showResetPasswordDialog),
          _buildActionItem(Icons.security_outlined, 'Privacy & Security', onTap: () {}),

          const SizedBox(height: 40),

          // YAHAN LOGOUT BUTTON UPDATE KIYA GAYA HAI
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                // Agar aapki file me class ka naam kuch aur hai (jaise MainLoginScreen), toh use yahan update kar lein
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: _red, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _green)),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _ink)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _inkSoft),
      onTap: onTap,
    );
  }
}