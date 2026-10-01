import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';
import 'doctor_schedule_screen.dart';
import 'patient_schedule_screen.dart';
import 'patient_analytics_tab.dart';

class DoctorHomeTab extends StatefulWidget {
  const DoctorHomeTab({super.key});

  @override
  State<DoctorHomeTab> createState() => _DoctorHomeTabState();
}

class _DoctorHomeTabState extends State<DoctorHomeTab> {
  final Color _primaryDark = const Color(0xFF233621);
  final Color _lightGreen = const Color(0xFF86B837);
  final Color _lightBlue = const Color(0xFFB5D1E8);

  String _doctorName = 'Doctor';
  String? _profileImage;

  List<dynamic> _realHomeAppointments = [];
  bool _isLoadingHomeAppts = true;
  int _caretakerId = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _loadDoctorHomeAppointments();
  }

  Future<void> _loadDoctorData() async {
    final prefs = await SharedPreferences.getInstance();
    final uId = prefs.getInt('userId') ?? 0;

    if (mounted) {
      setState(() {
        _caretakerId = uId;
        _doctorName = prefs.getString('savedUsername') ?? prefs.getString('full_name') ?? 'Doctor';
        _profileImage = prefs.getString('profile_image');
      });
    }

    if (_caretakerId > 0) {
      final data = await ApiService.getUserProfile(_caretakerId);
      if (!data.containsKey('error') && mounted) {
        var profile = data['profile'] ?? data;
        setState(() {
          if (profile['full_name'] != null) {
            _doctorName = profile['full_name'];
            prefs.setString('savedUsername', _doctorName);
          }
          if (profile['profile_image'] != null && profile['profile_image'].toString().trim().isNotEmpty) {
            _profileImage = profile['profile_image'];
            prefs.setString('profile_image', _profileImage!);
          }
        });
      }
    }
  }

  Future<void> _loadDoctorHomeAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    int uId = prefs.getInt('userId') ?? 0;

    final appts = await ApiService.getCaretakerAppointments(uId);
    if (mounted) {
      setState(() {
        _realHomeAppointments = appts;
        _isLoadingHomeAppts = false;
      });
    }
  }

  Widget _fallbackAvatar() {
    return Container(
      color: _lightGreen.withAlpha(50),
      child: Icon(Icons.person, size: 40, color: _primaryDark),
    );
  }

  Widget _displayImageWidget(String? img) {
    if (img == null || img.trim().isEmpty) return _fallbackAvatar();

    try {
      if (img.contains('base64,')) {
        final cleanBase64 = img.split('base64,').last.trim();
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        );
      } else if (img.startsWith('http')) {
        return Image.network(
          img,
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        );
      } else {
        final file = File(img);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) => _fallbackAvatar(),
          );
        }
      }
    } catch (e) {
      debugPrint("Image show error: $e");
    }

    return _fallbackAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: Stack(
        children: [
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize_outlined, color: _primaryDark, size: 28),
            const SizedBox(width: 8),
            Text('DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _primaryDark)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.translate, color: _primaryDark, size: 26),
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
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(38), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipOval(
            child: _displayImageWidget(_profileImage),
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
                _doctorName,
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
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4)),
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
                Text('Your Appointments', style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark)),
                const SizedBox(height: 4),
                Text('Stay on track with your Patients visits.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorScheduleScreen()));
                _loadDoctorHomeAppointments();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _isLoadingHomeAppts
            ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
            : _realHomeAppointments.isEmpty
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Text('No confirmed appointments right now.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        )
            : SizedBox(
          height: 85,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _realHomeAppointments.length,
            itemBuilder: (context, index) {
              var appt = _realHomeAppointments[index];
              String name = appt['patient_name'] ?? 'Patient';
              String dateStr = appt['appointment_date'] ?? 'Mon 23';
              String timeStr = appt['appointment_time'] ?? '10:00 AM';
              String? img = appt['profile_image'];

              List<String> dateParts = dateStr.split(' ');
              String dayLabel = dateParts.isNotEmpty ? dateParts[0] : 'Mon';
              String dayNum = dateParts.length > 1 ? dateParts[1] : '23';

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildAppointmentCard(dayLabel, dayNum, timeStr, name, img),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String dayStr, String dateStr, String time, String name, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 5, offset: const Offset(0, 2))],
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
                Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A902A))),
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
              SizedBox(
                width: 90,
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: _displayImageWidget(imageUrl),
            ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientScheduleScreen()));
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientAnalyticsTab(
                            patientData: {
                              'full_name': _doctorName,
                              'patient_id': _caretakerId,
                            },
                          ),
                        ),
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
}