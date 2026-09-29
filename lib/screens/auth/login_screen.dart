import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Language Pill)
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 22),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: _ink.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, color: _green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'EN',
                        style: TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Brand Section
            Padding(
              padding: const EdgeInsets.only(top: 26, left: 30, right: 30),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          100,
                        ), // Agar logo square hai to thoda gol karne ke liye
                        child: Image.asset(
                          'assets/sahayak_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Sahayak',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cognitive care, made simple',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _inkSoft,
                    ),
                  ),
                ],
              ),
            ),

            // Role List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 34, left: 22, right: 22),
                children: [
                  _buildRoleButton(
                    title: 'Login as Patient',
                    subtitle: 'Games, reminders & care in one place',
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/patient_login');
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildRoleButton(
                    title: 'Login as Doctor',
                    subtitle: 'Monitor patients & manage appointments',
                    icon: Icons.medical_services_outlined,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/doctor_login');
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildDisabledRoleButton(),

                  // Voice Hint
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic,
                          color: const Color(0xFFD98A2B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Or just say "I\'m a patient" / "I\'m a doctor"',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Note
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
              child: Text(
                'Need help logging in?\nAsk a family member or your caregiver to assist.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _inkSoft,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _ink.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _greenTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: _green, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: _inkSoft, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledRoleButton() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE1E4DC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: const Color(0xFF8A9188),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login as Family Member',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stay updated on a loved one\'s care',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _inkSoft,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDFE3D8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: Color(0xFF7C8479),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
