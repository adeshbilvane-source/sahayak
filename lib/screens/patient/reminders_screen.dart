import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart'; // NAYA ALARM PACKAGE

class ReminderItem {
  final String id;
  final int alarmId; // Alarm package ke liye Integer ID zaroori hai
  final String title;
  final String time; // "07:30"
  final String displayTime; // "7:30"
  final String period; // "AM" | "PM"
  final String repeat;
  final String type; // 'daily' | 'medicine' | 'water'
  bool enabled;
  final String voiceMessage;
  final String? dosage;

  ReminderItem({
    required this.id,
    required this.alarmId,
    required this.title,
    required this.time,
    required this.displayTime,
    required this.period,
    required this.repeat,
    required this.type,
    required this.enabled,
    required this.voiceMessage,
    this.dosage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'alarmId': alarmId,
    'title': title,
    'time': time,
    'displayTime': displayTime,
    'period': period,
    'repeat': repeat,
    'type': type,
    'enabled': enabled,
    'voiceMessage': voiceMessage,
    'dosage': dosage,
  };

  factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
    id: json['id'],
    alarmId: json['alarmId'] ?? DateTime.now().millisecondsSinceEpoch.remainder(10000),
    title: json['title'],
    time: json['time'] ?? '08:00',
    displayTime: json['displayTime'] ?? '8:00',
    period: json['period'] ?? 'AM',
    repeat: json['repeat'] ?? '',
    type: json['type'] ?? 'daily',
    enabled: json['enabled'] ?? true,
    voiceMessage: json['voiceMessage'] ?? '',
    dosage: json['dosage'],
  );
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _blue = const Color(0xFF3E7FB8);
  final Color _blueDark = const Color(0xFF275782);

  double _waterInterval = 1.5;
  List<ReminderItem> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterInterval = prefs.getDouble('sahayak_water_interval') ?? 1.5;
    });

    final raw = prefs.getString('sahayak_reminders_list');
    if (raw != null && raw.isNotEmpty) {
      final List decoded = jsonDecode(raw);
      setState(() {
        _reminders = decoded.map((e) => ReminderItem.fromJson(e)).toList();
      });
    } else {
      // Default items generate karte waqt alarmId bhi set kar rahe hain
      setState(() {
        _reminders = [
          ReminderItem(
            id: 'rem-1',
            alarmId: 1001,
            title: 'Have breakfast',
            time: '07:30',
            displayTime: '7:30',
            period: 'AM',
            repeat: 'Repeats every day',
            type: 'daily',
            enabled: true,
            voiceMessage: 'Attention please! Your breakfast time is now. Please pause your activity and have your breakfast.',
          ),
          ReminderItem(
            id: 'rem-2',
            alarmId: 1002,
            title: 'Wind down for bed',
            time: '21:00',
            displayTime: '9:00',
            period: 'PM',
            repeat: 'Repeats every day',
            type: 'daily',
            enabled: true,
            voiceMessage: 'Attention please! It is time to wind down for bed. Please pause your activity and get ready to sleep.',
          ),
          ReminderItem(
            id: 'rem-3',
            alarmId: 1003,
            title: 'Blood pressure tablet',
            time: '08:00',
            displayTime: '8:00',
            period: 'AM',
            repeat: '1 tablet, after breakfast',
            type: 'medicine',
            enabled: true,
            dosage: '1 tablet',
            voiceMessage: 'Attention please! It is time to take your medicine: Blood pressure tablet. Please pause your activity and take your medication now.',
          ),
        ];
      });
      _saveReminders();
    }

    _resetWaterTimer();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString('sahayak_reminders_list', jsonStr);
  }

  Future<void> _saveWaterInterval() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sahayak_water_interval', _waterInterval);
    _resetWaterTimer();
  }

  // --- NAYA ALARM SCHEDULING LOGIC ---
  Future<void> _scheduleAlarm(ReminderItem item, DateTime scheduleTime) async {
    if (!item.enabled) return;

    // FIX: Naye format ke hisaab se vibrate aur VolumeSettings set kiye
    final alarmSettings = AlarmSettings(
      id: item.alarmId,
      dateTime: scheduleTime,
      assetAudioPath: 'assets/alarm.mp3', // Aapke project me 'assets/alarm.mp3' zaroor honi chahiye
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: item.title,
        body: 'Time to complete your task',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  // Next din (ya same din) ke liye exact time calculate karta hai
  void _scheduleForNextOccurrence(ReminderItem item) {
    if (!item.time.contains(':')) return;
    final parts = item.time.split(':');
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);

    DateTime t = DateTime.now().copyWith(hour: h, minute: m, second: 0);
    if (t.isBefore(DateTime.now())) {
      t = t.add(const Duration(days: 1));
    }
    _scheduleAlarm(item, t);
  }

  void _resetWaterTimer() {
    // Stop existing water alarm (ID 8888 for water)
    Alarm.stop(8888);

    final int ms = (_waterInterval * 3600 * 1000).toInt();
    final scheduleTime = DateTime.now().add(Duration(milliseconds: ms));

    final waterItem = ReminderItem(
      id: 'water-live',
      alarmId: 8888,
      title: 'Drink Water',
      time: 'Now',
      displayTime: 'Now',
      period: '',
      repeat: 'Hydration reminder',
      type: 'water',
      enabled: true,
      voiceMessage: 'Attention please! It is time to drink a glass of fresh water. Please pause your activity and stay hydrated.',
    );

    // Ensure water item is saved in prefs so global handler can find it
    if (!_reminders.any((r) => r.type == 'water')) {
      _reminders.add(waterItem);
      _saveReminders();
    }

    _scheduleAlarm(waterItem, scheduleTime);
  }

  // Test Alarm Logic: Set for 2 seconds from now to trigger the Global Popup
  void _triggerTestAlarm(ReminderItem item) async {
    final scheduleTime = DateTime.now().add(const Duration(seconds: 2));
    await _scheduleAlarm(item, scheduleTime);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Testing alarm... will ring in 2 seconds!'), backgroundColor: _marigold),
      );
    }
  }

  void _showAddModal(String type) {
    String title = '';
    String timeStr = '08:00';
    String dosage = '1 tablet';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setMState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20, right: 20, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New ${type == 'medicine' ? "Medicine" : "Daily"} Reminder',
                  style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.bold, color: _ink),
                ),
                const SizedBox(height: 16),
                Text('Reminder Name / Medicine', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (v) => title = v,
                  decoration: InputDecoration(
                    hintText: type == 'medicine' ? 'e.g. Blood Pressure Pill' : 'e.g. Afternoon Walk',
                    filled: true,
                    fillColor: _canvas,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Scheduled Time (24h format HH:MM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    hintText: 'e.g. 08:30 or 14:00',
                    filled: true,
                    fillColor: _canvas,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint)),
                  ),
                  onChanged: (v) => timeStr = v.trim(),
                ),
                if (type == 'medicine') ...[
                  const SizedBox(height: 14),
                  Text('Dosage Instructions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (v) => dosage = v,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1 tablet after food',
                      filled: true,
                      fillColor: _canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      if (title.trim().isEmpty || !timeStr.contains(':')) return;
                      final parts = timeStr.split(':');
                      int h = int.tryParse(parts[0]) ?? 8;
                      int m = int.tryParse(parts[1]) ?? 0;
                      final period = h >= 12 ? 'PM' : 'AM';
                      final displayH = h % 12 == 0 ? 12 : h % 12;
                      final displayTime = '$displayH:${m.toString().padLeft(2, '0')}';
                      final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(10000);

                      final newRem = ReminderItem(
                        id: 'rem-$alarmId',
                        alarmId: alarmId, // Assigning random unique ID
                        title: title.trim(),
                        time: '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
                        displayTime: displayTime,
                        period: period,
                        repeat: type == 'medicine' ? '$dosage, daily' : 'Repeats every day',
                        type: type,
                        enabled: true,
                        dosage: type == 'medicine' ? dosage : null,
                        voiceMessage: 'Your scheduled time for $title is now.',
                      );

                      setState(() {
                        _reminders.add(newRem);
                      });
                      _saveReminders();
                      _scheduleForNextOccurrence(newRem); // Schedule it for reality!

                      Navigator.pop(ctx);
                    },
                    child: const Text('Set Alarm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: _greenTint, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: _green),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Reminders',
                    style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 24, fontWeight: FontWeight.bold, color: _ink),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 15, color: _ink),
                        const SizedBox(width: 4),
                        Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ink)),
                        Icon(Icons.keyboard_arrow_down, size: 14, color: _ink),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                children: [
                  _buildSectionLabel('WATER REMINDER'),
                  _buildWaterCard(),

                  const SizedBox(height: 12),
                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _marigoldTint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: _marigold, width: 4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔔 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            'Alarms will now ring natively on your device. The screen will pause until you complete or snooze the task.',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.brown.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _buildSectionLabel('DAILY REMINDERS'),
                  ..._reminders.where((r) => r.type == 'daily').map((r) => _buildReminderCard(r)),

                  const SizedBox(height: 8),
                  _buildAddButton('Add reminder', () => _showAddModal('daily')),

                  const SizedBox(height: 22),
                  _buildSectionLabel('MEDICINE REMINDERS'),
                  ..._reminders.where((r) => r.type == 'medicine').map((r) => _buildReminderCard(r)),

                  const SizedBox(height: 8),
                  _buildAddButton('Add medicine reminder', () => _showAddModal('medicine')),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: _inkSoft, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildWaterCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_blue, _blueDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BACKGROUND REMINDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD5E8F8), letterSpacing: 0.6)),
              GestureDetector(
                onTap: () {
                  final waterItem = _reminders.firstWhere((r) => r.type == 'water', orElse: () => ReminderItem(
                      id: 'water-test', alarmId: 8888, title: 'Drink Water', time: 'Now', displayTime: 'Now', period: 'AM', repeat: '', type: 'water', enabled: true, voiceMessage: ''
                  ));
                  _triggerTestAlarm(waterItem);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
                  child: const Text('🔔 Test Water Alarm', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('A gentle nudge to drink water, all day', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleBtn('−', () {
                if (_waterInterval > 0.5) {
                  setState(() => _waterInterval = (_waterInterval - 0.5));
                  _saveWaterInterval();
                }
              }),
              const SizedBox(width: 18),
              Text('Every ${_waterInterval.toStringAsFixed(1)} hours', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(width: 18),
              _circleBtn('+', () {
                setState(() => _waterInterval = (_waterInterval + 0.5));
                _saveWaterInterval();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.22)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (item.type == 'medicine')
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: _marigoldTint, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const Text('💊', style: TextStyle(fontSize: 18)),
            ),
          SizedBox(
            width: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.displayTime, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _ink)),
                Text(item.period, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _green)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
                Text(item.repeat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _inkSoft)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _triggerTestAlarm(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: _greenTint, borderRadius: BorderRadius.circular(10)),
              child: Text('🔔 Test', style: TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: item.enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: _green,
            onChanged: (val) {
              setState(() => item.enabled = val);
              _saveReminders();
              if (val) {
                _scheduleForNextOccurrence(item); // Re-enable alarm
              } else {
                Alarm.stop(item.alarmId); // Stop alarm if disabled
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB8C7BA), width: 1.5, style: BorderStyle.solid),
        ),
        alignment: Alignment.center,
        child: Text('+ $text', style: TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 13.5)),
      ),
    );
  }
}