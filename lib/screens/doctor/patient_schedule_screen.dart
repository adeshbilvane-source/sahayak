import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_service.dart';

class PatientScheduleScreen extends StatefulWidget {
  const PatientScheduleScreen({super.key});

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  final Color _primaryDark = const Color(0xFF233621);
  final Color _bgHint = const Color(0xFFF9FAF7);

  List<dynamic> _acceptedPatients = [];
  List<dynamic> _pendingAppointments = [];
  List<dynamic> _confirmedAppointments = [];
  bool _isLoading = true;
  int _currentCaretakerId = 0;

  // Jis appointment pe accept/reject chal raha hai (double tap rokne ke liye)
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadCaretakerData();
  }

  Future<void> _loadCaretakerData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    debugPrint('Doctor userId from prefs: $userId');
    if (!mounted) return;
    setState(() => _currentCaretakerId = userId);
    await _fetchAll();
  }

  /// Teeno lists ek saath refresh karta hai
  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getAcceptedPatients(_currentCaretakerId),
        ApiService.getPendingAppointments(_currentCaretakerId),
        ApiService.getCaretakerAppointments(_currentCaretakerId),
      ]);
      if (!mounted) return;
      setState(() {
        _acceptedPatients = results[0];
        _pendingAppointments = results[1];
        _confirmedAppointments = results[2];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch all error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppointmentAction(Map<String, dynamic> appt, String status) async {
    final int id = int.tryParse(appt['appointment_id'].toString()) ?? 0;
    if (id == 0 || _processingIds.contains(id)) return;

    setState(() => _processingIds.add(id));
    final ok = await ApiService.updateAppointmentStatus(id, status);
    if (!mounted) return;
    setState(() => _processingIds.remove(id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (status == 'accepted' ? 'Appointment accepted!' : 'Appointment rejected.')
            : 'Something went wrong. Please try again.'),
        backgroundColor: ok ? (status == 'accepted' ? Colors.green : Colors.red) : Colors.orange,
      ),
    );

    if (ok) await _fetchAll();
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty || phoneNumber == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency number not available for this patient', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Call error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the dialer')));
      }
    }
  }

  Map<String, dynamic> _patientMapFromAppointment(Map<String, dynamic> a) {
    return {
      'patient_id': a['patient_id'],
      'full_name': a['patient_name'],
      'profile_image': a['profile_image'],
      'emergency_contact': a['emergency_contact'],
    };
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

  Widget _sectionTitle(String title, {int? count, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'serif')),
            if (count != null && count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text('$count', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _dateTimeRow(Map<String, dynamic> a) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF5F6F3), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text('${a['appointment_date'] ?? '-'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primaryDark)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.alarm, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text('${a['appointment_time'] ?? '-'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> a) {
    final int id = int.tryParse(a['appointment_id'].toString()) ?? 0;
    final bool busy = _processingIds.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSafeAvatar(a['profile_image'], radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(a['patient_name'] ?? 'Unknown Patient', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _primaryDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text('PENDING', style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dateTimeRow(a),
          const SizedBox(height: 10),
          Text('Reason: ${a['reason'] ?? 'Routine Checkup'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _handleAppointmentAction(a, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _handleAppointmentAction(a, 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedCard(Map<String, dynamic> a) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(patientData: _patientMapFromAppointment(a))),
        ).then((_) => _fetchAll());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSafeAvatar(a['profile_image'], radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(a['patient_name'] ?? 'Unknown Patient', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _primaryDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text('CONFIRMED', style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dateTimeRow(a),
            const SizedBox(height: 10),
            Text('Reason: ${a['reason'] ?? 'Routine Checkup'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Yahan par explicitly sirf emergency_contact ko call ke liye bheja ja raha hai
                  String? phoneToCall = a['emergency_contact']?.toString();
                  _makePhoneCall(phoneToCall);
                },
                icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                label: const Text('Call Patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedPatientTile(Map<String, dynamic> patient) {
    String name = patient['full_name'] ?? 'Unknown Patient';
    String? image = patient['profile_image'];
    String pId = '#SAH-2026-0${patient['patient_id'] ?? 0}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PatientDetailScreen(patientData: patient)),
        ).then((_) => _fetchAll());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            _buildSafeAvatar(image, radius: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _primaryDark)),
                  const SizedBox(height: 4),
                  Text('ID: $pId', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFEEF5E5), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6A902A)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgHint,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchAll,
                color: _primaryDark,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    else ...[
                      _sectionTitle('Appointment Requests', count: _pendingAppointments.length, subtitle: 'Patients waiting for your approval.'),
                      if (_pendingAppointments.isEmpty)
                        _emptyHint('No pending requests right now.')
                      else
                        ..._pendingAppointments.map((a) => _buildPendingCard(Map<String, dynamic>.from(a))),

                      const SizedBox(height: 16),

                      _sectionTitle('Confirmed Schedule', subtitle: 'Your accepted appointments.'),
                      if (_confirmedAppointments.isEmpty)
                        _emptyHint('No confirmed appointments yet.')
                      else
                        ..._confirmedAppointments.map((a) => _buildConfirmedCard(Map<String, dynamic>.from(a))),

                      const SizedBox(height: 16),

                      _sectionTitle('My Connected Patients', subtitle: 'Tap on any patient to view details, analytics, and reminders.'),
                      if (_acceptedPatients.isEmpty)
                        _emptyHint('No connected patients yet.')
                      else
                        ..._acceptedPatients.map((p) => _buildConnectedPatientTile(Map<String, dynamic>.from(p))),
                    ],
                  ],
                ),
              ),
            ),
          ],
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
}

// ==============================================================
// FULL SCREEN PATIENT DETAIL & ANALYTICS
// ==============================================================
class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientDetailScreen({super.key, required this.patientData});

  Future<void> _makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty || phoneNumber == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency number not available'), backgroundColor: Colors.red));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Call error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the dialer')));
      }
    }
  }

  void _showRemovePatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Patient', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${patientData['full_name']} from your connected list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient removed successfully!'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeAvatar(Color primaryDark, String? img, {double radius = 40}) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: primaryDark, size: radius + 10));
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
      return CircleAvatar(radius: radius, backgroundColor: primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: primaryDark, size: radius + 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryDark = const Color(0xFF233621);
    final Color _bgHint = const Color(0xFFF9FAF7);

    String name = patientData['full_name'] ?? 'Unknown Patient';

    // Yahan bhi sirf emergency_contact ko hi map kiya gaya hai
    String? phone = patientData['emergency_contact']?.toString();

    String? image = patientData['profile_image'];
    String pId = '#SAH-2026-0${patientData['patient_id'] ?? 0}';
    String age = patientData['age']?.toString() ?? 'N/A';
    String blood = patientData['blood_group'] ?? 'N/A';

    return Scaffold(
      backgroundColor: _bgHint,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryDark, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Patient Overview', style: TextStyle(color: _primaryDark, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_remove, color: Colors.red),
            tooltip: 'Remove Patient',
            onPressed: () => _showRemovePatientDialog(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  _buildSafeAvatar(_primaryDark, image, radius: 45),
                  const SizedBox(height: 16),
                  Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _primaryDark)),
                  const SizedBox(height: 4),
                  Text('ID: $pId', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoBadge('Age', age, const Color(0xFFEEF5E5), const Color(0xFF6A902A)),
                      _buildInfoBadge('Blood', blood, Colors.red.shade50, Colors.red.shade700),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _makePhoneCall(context, phone),
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text('Call Patient / Emergency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Health Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'serif')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildAnalyticsCard('Heart Rate', '72', 'bpm', Icons.favorite, Colors.red.shade400)),
                const SizedBox(width: 12),
                Expanded(child: _buildAnalyticsCard('Blood Press.', '120/80', 'mmHg', Icons.bloodtype, Colors.blue.shade400)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAnalyticsCard('Sugar Lvl', '95', 'mg/dL', Icons.monitor_weight, Colors.orange.shade400)),
                const SizedBox(width: 12),
                Expanded(child: _buildAnalyticsCard('Sleep', '6.5', 'hrs', Icons.bedtime, Colors.indigo.shade400)),
              ],
            ),
            const SizedBox(height: 30),
            Text('Active Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'serif')),
            const SizedBox(height: 16),
            _buildReminderCard('Morning Medicine', '09:00 AM', Icons.medication, Colors.teal),
            _buildReminderCard('Physiotherapy Session', '05:30 PM', Icons.fitness_center, Colors.orange),
            _buildReminderCard('Drink Water (2L)', 'Ongoing', Icons.water_drop, Colors.blue),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String unit, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 28),
        ],
      ),
    );
  }
}