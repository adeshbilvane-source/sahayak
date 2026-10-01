import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class PatientAnalyticsTab extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const PatientAnalyticsTab({super.key, required this.patientData});

  @override
  State<PatientAnalyticsTab> createState() => _PatientAnalyticsTabState();
}

class _PatientAnalyticsTabState extends State<PatientAnalyticsTab> {
  final Color primaryDark = const Color(0xFF233621);
  final Color bgHint = const Color(0xFFF9FAF7);

  int _caretakerId = 0;

  // Step 1: connected patients list
  List<dynamic> _connectedPatients = [];
  bool _isLoadingPatients = true;

  // Step 2: selected patient and that patient's real analytics
  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = false;
  bool _analyticsFailed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('userId') ?? 0;
    if (id == 0) {
      // fallback: agar parent screen se caretaker_id pass hua ho
      id = int.tryParse('${widget.patientData['caretaker_id'] ?? 0}') ?? 0;
    }
    _caretakerId = id;
    await _loadConnectedPatients();
  }

  Future<void> _loadConnectedPatients() async {
    if (mounted) setState(() => _isLoadingPatients = true);
    List<dynamic> patients = [];
    if (_caretakerId > 0) {
      patients = await ApiService.getCaretakerAcceptedPatients(_caretakerId);
    }
    if (!mounted) return;
    setState(() {
      _connectedPatients = patients;
      _isLoadingPatients = false;
    });
  }

  Future<void> _openPatient(Map<String, dynamic> patient) async {
    setState(() {
      _selectedPatient = patient;
      _analytics = null;
      _analyticsFailed = false;
      _isLoadingAnalytics = true;
    });
    await _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final pid = int.tryParse('${patient['patient_id']}') ?? 0;
    final data = await ApiService.getPatientAnalytics(pid, _caretakerId);
    if (!mounted || _selectedPatient == null) return;
    setState(() {
      _analytics = data;
      _analyticsFailed = data == null;
      _isLoadingAnalytics = false;
    });
  }

  void _backToList() {
    setState(() {
      _selectedPatient = null;
      _analytics = null;
    });
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------
  int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
  double? _d(dynamic v) => v == null ? null : double.tryParse('$v');

  Widget _buildSafeAvatar(String? img, {double radius = 28}) {
    if (img == null || img.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: primaryDark, size: radius));
    }
    try {
      if (img.contains('base64,')) {
        String cleanBase64 = img.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        while (cleanBase64.length % 4 != 0) {
          cleanBase64 += '=';
        }
        return CircleAvatar(radius: radius, backgroundImage: MemoryImage(base64Decode(cleanBase64)));
      } else if (img.startsWith('http')) {
        return CircleAvatar(radius: radius, backgroundImage: NetworkImage(img));
      } else {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(File(img)));
      }
    } catch (e) {
      return CircleAvatar(radius: radius, backgroundColor: primaryDark.withValues(alpha: 0.1), child: Icon(Icons.person, color: primaryDark, size: radius));
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool inDetail = _selectedPatient != null;

    return PopScope(
      canPop: !inDetail,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && inDetail) _backToList();
      },
      child: Scaffold(
        backgroundColor: bgHint,
        appBar: AppBar(
          title: Text(
            inDetail ? 'Patient Analytics' : 'Select Patient',
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryDark),
            onPressed: () {
              if (inDetail) {
                _backToList();
              } else {
                Navigator.maybePop(context);
              }
            },
          ),
        ),
        body: inDetail ? _buildAnalyticsView() : _buildPatientList(),
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 1: CONNECTED PATIENTS LIST
  // ------------------------------------------------------------
  Widget _buildPatientList() {
    return RefreshIndicator(
      onRefresh: _loadConnectedPatients,
      color: primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text('Your Connected Patients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDark, fontFamily: 'serif')),
          const SizedBox(height: 6),
          Text('Select a patient to view their health & activity analytics.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (_isLoadingPatients)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_connectedPatients.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No connected patients yet.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14))),
            )
          else
            ..._connectedPatients.map((p) {
              final patient = Map<String, dynamic>.from(p);
              final name = patient['full_name'] ?? 'Unknown Patient';
              final pId = '#SAH-2026-0${patient['patient_id'] ?? 0}';
              return GestureDetector(
                onTap: () => _openPatient(patient),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      _buildSafeAvatar(patient['profile_image'], radius: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primaryDark)),
                            const SizedBox(height: 4),
                            Text('ID: $pId', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFEEF5E5), shape: BoxShape.circle),
                        child: const Icon(Icons.bar_chart_rounded, size: 18, color: Color(0xFF6A902A)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 2: ANALYTICS OF SELECTED PATIENT (REAL DATA ONLY)
  // ------------------------------------------------------------
  Widget _buildAnalyticsView() {
    final patient = _selectedPatient!;

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildPatientHeader(patient),
          const SizedBox(height: 20),
          if (_isLoadingAnalytics)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_analyticsFailed || _analytics == null)
            _emptyCard('Could not load analytics. Pull down to retry.', Icons.cloud_off)
          else ...[
              _buildRemindersCard(Map<String, dynamic>.from(_analytics!['reminders'] ?? {})),
              const SizedBox(height: 20),
              _buildGamesCard(Map<String, dynamic>.from(_analytics!['games'] ?? {})),
              const SizedBox(height: 20),
              _buildVitalsRow(_analytics!['vitals'] == null ? null : Map<String, dynamic>.from(_analytics!['vitals'])),
            ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPatientHeader(Map<String, dynamic> patient) {
    final name = patient['full_name'] ?? 'Patient';
    final pId = '#SAH-2026-0${patient['patient_id'] ?? 0}';
    final age = patient['age']?.toString();
    final blood = patient['blood_group']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildSafeAvatar(patient['profile_image'], radius: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryDark)),
                const SizedBox(height: 4),
                Text('ID: $pId', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                if ((age != null && age.isNotEmpty) || (blood != null && blood.isNotEmpty)) ...[
                  const SizedBox(height: 6),
                  Text(
                    [if (age != null && age.isNotEmpty) 'Age $age', if (blood != null && blood.isNotEmpty) 'Blood $blood'].join('  •  '),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _emptyCard(String text, IconData icon) {
    return _cardShell(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // ---------------- Reminders ----------------
  Widget _buildRemindersCard(Map<String, dynamic> r) {
    final total = _i(r['total']);
    final taken = _i(r['taken']);
    final Map<String, dynamic> byType = Map<String, dynamic>.from(r['by_type'] ?? {});

    if (total == 0) {
      return _emptyCard('No reminder activity recorded in the last 7 days.', Icons.alarm_off);
    }

    final overall = (taken * 100 / total).round();
    final rows = <Widget>[];
    final config = {
      'medicine': ['Medicine Taken on Time', Colors.teal],
      'water': ['Hydration Target (Water)', Colors.blue],
      'routine': ['Daily Routine Tasks', Colors.orange],
    };
    config.forEach((key, cfg) {
      final t = byType[key];
      if (t == null) return;
      final tTotal = _i(t['total']);
      if (tTotal == 0) return;
      final tTaken = _i(t['taken']);
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(_buildProgressBar(cfg[0] as String, tTaken / tTotal, cfg[1] as Color));
    });

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reminders Adherence (7 days)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEF5E5), borderRadius: BorderRadius.circular(8)),
                child: Text('$overall% Success', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6A902A))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  // ---------------- Games ----------------
  Widget _buildGamesCard(Map<String, dynamic> g) {
    final sessions = _i(g['sessions']);
    if (sessions == 0) {
      return _emptyCard('No cognitive games played in the last 7 days.', Icons.sports_esports);
    }

    final best = g['best_score'];
    final reaction = _d(g['avg_reaction_ms']);
    final List<dynamic> weekly = (g['weekly'] as List<dynamic>?) ?? [];
    final maxSessions = weekly.fold<int>(0, (m, e) => _i(e['sessions']) > m ? _i(e['sessions']) : m);
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sports_esports, color: Colors.indigo, size: 22),
              SizedBox(width: 8),
              Text('Cognitive Game Performance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBadge('Best Score', best == null ? '--' : '$best pts', Colors.indigo.shade50, Colors.indigo.shade700),
              _buildStatBadge('Games Played', '$sessions Sessions', Colors.teal.shade50, Colors.teal.shade700),
              _buildStatBadge('Avg. Reaction', reaction == null ? '--' : '${(reaction / 1000).toStringAsFixed(1)}s', Colors.orange.shade50, Colors.orange.shade700),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Weekly Brain Exercise Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekly.map<Widget>((e) {
              final dt = DateTime.tryParse('${e['date']}');
              final label = dt == null ? '-' : dayNames[dt.weekday - 1];
              final factor = maxSessions == 0 ? 0.0 : _i(e['sessions']) / maxSessions;
              return _buildBarCol(label, factor);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------- Vitals ----------------
  Widget _buildVitalsRow(Map<String, dynamic>? v) {
    final hr = v?['heart_rate'];
    final spo2 = v?['spo2'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('Heart Rate', hr == null ? '--' : '$hr bpm', Icons.favorite, Colors.red)),
            const SizedBox(width: 14),
            Expanded(child: _buildMetricCard('Blood Oxygen', spo2 == null ? '--' : '$spo2%', Icons.air, Colors.blue)),
          ],
        ),
        if (v == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text('No vitals recorded yet.', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBarCol(String day, double heightFactor) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 70,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: FractionallySizedBox(
            heightFactor: heightFactor.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF3F6B4F), borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}