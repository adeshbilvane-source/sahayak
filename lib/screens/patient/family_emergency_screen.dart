import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Model ---
class FamilyContact {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final String availability;
  final String? avatarUrl;

  FamilyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.availability,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relation': relation,
    'phone': phone,
    'availability': availability,
    'avatarUrl': avatarUrl,
  };

  factory FamilyContact.fromJson(Map<String, dynamic> json) => FamilyContact(
    id: json['id'],
    name: json['name'],
    relation: json['relation'],
    phone: json['phone'],
    availability: json['availability'],
    avatarUrl: json['avatarUrl'],
  );
}

class FamilyEmergencyScreen extends StatefulWidget {
  const FamilyEmergencyScreen({super.key});

  @override
  State<FamilyEmergencyScreen> createState() => _FamilyEmergencyScreenState();
}

class _FamilyEmergencyScreenState extends State<FamilyEmergencyScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _white = const Color(0xFFFFFFFF);

  List<FamilyContact> _contacts = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _relationshipOptions = [
    'Daughter', 'Son', 'Spouse', 'Brother', 'Sister', 'Caregiver', 'Friend', 'Custom'
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('sahayak_family_contacts');
    if (rawData != null) {
      final List decoded = jsonDecode(rawData);
      setState(() {
        _contacts = decoded.map((e) => FamilyContact.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveContacts(List<FamilyContact> newContacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'sahayak_family_contacts', jsonEncode(newContacts.map((e) => e.toJson()).toList()));
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this family member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _contacts.removeWhere((c) => c.id == id);
                _saveContacts(_contacts);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddModal() {
    String newName = '';
    String newRelation = 'Son';
    String customRelation = '';
    String newPhone = '';
    String newAvailability = 'Usually available';
    String? newAvatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 24,
            ),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Family Member', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink, fontFamily: 'serif')),
                  const SizedBox(height: 20),

                  // Name Input
                  Text('Member Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (val) => newName = val,
                    decoration: InputDecoration(
                      filled: true, fillColor: _canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Relationship Dropdown
                  Text('Relationship', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: newRelation,
                    decoration: InputDecoration(
                      filled: true, fillColor: _canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                    ),
                    items: _relationshipOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => newRelation = val);
                    },
                  ),
                  if (newRelation == 'Custom') ...[
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) => customRelation = val,
                      decoration: InputDecoration(
                        hintText: 'Enter custom relationship',
                        filled: true, fillColor: _canvas,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Phone Input
                  Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (val) => newPhone = val,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true, fillColor: _canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Availability Input
                  Text('Availability', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (val) => newAvailability = val,
                    decoration: InputDecoration(
                      hintText: 'Usually available',
                      filled: true, fillColor: _canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _greenTint, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Photo Upload
                  Text('Photo (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _inkSoft)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) setModalState(() => newAvatarPath = image.path);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _canvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _green, width: 1.5, strokeAlign: BorderSide.strokeAlignCenter),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        newAvatarPath != null ? 'Photo Selected' : 'Upload Photo',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _ink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      if (newName.trim().isEmpty || newPhone.trim().isEmpty) return;

                      String finalRelation = newRelation == 'Custom'
                          ? (customRelation.trim().isNotEmpty ? customRelation.trim() : 'Custom')
                          : newRelation;

                      final newContact = FamilyContact(
                        id: 'fam-${DateTime.now().millisecondsSinceEpoch}',
                        name: newName.trim(),
                        relation: finalRelation,
                        phone: newPhone.trim(),
                        availability: newAvailability.trim().isEmpty ? 'Usually available' : newAvailability.trim(),
                        avatarUrl: newAvatarPath,
                      );

                      setState(() {
                        _contacts.add(newContact);
                        _saveContacts(_contacts);
                      });

                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                    ),
                    child: Text('Cancel', style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE3D6), // Outer background matching React body
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _canvas,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: _white,
                    boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: _greenTint, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.arrow_back_ios_new, size: 16, color: _green),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Family Members',
                        style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 20, color: _ink),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR FAMILY CONTACTS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: _inkSoft, letterSpacing: 0.6)),
                        const SizedBox(height: 12),

                        if (_contacts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Column(
                              children: [
                                const Text('👨‍👩‍👧', style: TextStyle(fontSize: 38)),
                                const SizedBox(height: 8),
                                Text('No family members added', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ink)),
                                const SizedBox(height: 4),
                                Text('Add your loved ones below for direct 1-tap calls.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _inkSoft)),
                              ],
                            ),
                          )
                        else
                          ..._contacts.map((c) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: _white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: _marigoldTint, shape: BoxShape.circle),
                                  clipBehavior: Clip.antiAlias,
                                  child: c.avatarUrl != null
                                      ? Image.file(File(c.avatarUrl!), fit: BoxFit.cover, errorBuilder: (_,_,_) => const Center(child: Text('👤', style: TextStyle(fontSize: 24))))
                                      : const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _ink)),
                                      Text(c.relation, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _green)),
                                      Text(c.availability, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _inkSoft)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _makeCall(c.phone),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                        decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(14)),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.call, color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('Call', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      onPressed: () => _deleteContact(c.id),
                                      icon: Icon(Icons.close, color: _inkSoft, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )),

                        const SizedBox(height: 8),

                        // Dashed Add Button alternative using Container
                        GestureDetector(
                          onTap: _showAddModal,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFB8C7BA), width: 2), // Solid fallback for dashed
                            ),
                            alignment: Alignment.center,
                            child: Text('+ Add Family Contact', style: TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 13.5)),
                          ),
                        ),

                        // Callout Box
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _marigoldTint,
                            border: Border(left: BorderSide(color: _marigold, width: 4)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Tap the call button to connect with your family members instantly.',
                            style: TextStyle(color: Color(0xFF7A5015), fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.45),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}