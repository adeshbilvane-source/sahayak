import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0), // Halka laal background
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text('Emergency / SOS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Do you need help?',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 60),
            
            // Bada Laal Call Button
            GestureDetector(
              onTap: () {
                // Filhal ke liye ye ek popup dikhayega. Baad me hum ise asli phone call se link karenge.
                _showCallingDialog(context);
              },
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.phone_in_talk, size: 120, color: Colors.white),
              ),
            ),
            
            const SizedBox(height: 60),
            const Text(
              'Tap the red button to\ncall your caregiver',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Calling Caregiver...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Connecting to your emergency contact.', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel Call', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}