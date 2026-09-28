import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'activity_tutorial_overlay.dart';

enum CategoryTab { random, familyPhotos, mySurroundings }

class QuestionItem {
  final String id;
  final String display;
  final String name;
  final String category;

  QuestionItem({
    required this.id,
    required this.display,
    required this.name,
    required this.category,
  });
}

class LibraryPhoto {
  final String id;
  final String imageUrl;
  final String label;
  final String category;

  LibraryPhoto({
    required this.id,
    required this.imageUrl,
    required this.label,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'label': label,
    'category': category,
  };

  factory LibraryPhoto.fromJson(Map<String, dynamic> json) => LibraryPhoto(
    id: json['id'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    label: json['label'] ?? 'Unknown',
    category: json['category'] ?? 'family',
  );
}

class IdentifyPictureScreen extends StatefulWidget {
  const IdentifyPictureScreen({super.key});

  @override
  State<IdentifyPictureScreen> createState() => _IdentifyPictureScreenState();
}

class _IdentifyPictureScreenState extends State<IdentifyPictureScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _red = const Color(0xFFB33F33);
  final Color _redTint = const Color(0xFFF4DEDA);
  final Color _blueHint = const Color(0xFF4A90E2);
  final Color _white = const Color(0xFFFFFFFF);

  // 1. Offline Local Folder Assets for Random Category
  final List<Map<String, String>> _realRandomData = const [
    {'name': 'Car', 'image': 'assets/identify_picture/1.jpg'},
    {'name': 'Dog', 'image': 'assets/identify_picture/2.jpg'},
    {'name': 'Cat', 'image': 'assets/identify_picture/3.jpg'},
    {'name': 'Apple', 'image': 'assets/identify_picture/4.jpg'},
    {'name': 'Banana', 'image': 'assets/identify_picture/5.jpg'},
    {'name': 'Tea Cup', 'image': 'assets/identify_picture/6.jpg'},
    {'name': 'House', 'image': 'assets/identify_picture/7.jpg'},
    {'name': 'Tree', 'image': 'assets/identify_picture/8.jpg'},
    {'name': 'Aeroplane', 'image': 'assets/identify_picture/9.jpg'},
    {'name': 'Bicycle', 'image': 'assets/identify_picture/10.jpg'},
    {'name': 'Elephant', 'image': 'assets/identify_picture/11.jpg'},
    {'name': 'Clock', 'image': 'assets/identify_picture/12.jpg'},
  ];

  CategoryTab _tab = CategoryTab.random;
  final Map<CategoryTab, int> _levels = {
    CategoryTab.random: 1,
    CategoryTab.familyPhotos: 1,
    CategoryTab.mySurroundings: 1,
  };

  int get _currentLevel => _levels[_tab]!;

  List<LibraryPhoto> _libraryPhotos = [];
  String? _capturedImage;
  String _photoLabel = 'Father';

  // Custom Name states
  bool _isCustomLabel = false;
  final TextEditingController _customLabelController = TextEditingController();

  bool _showUploadModal = false;

  QuestionItem? _currentQuestion;
  List<String> _options = [];
  String? _selectedAnswer;
  bool? _isCorrect;

  // TUTORIAL STATE
  bool _isTutorialMode = false;
  bool _showTutorial = false;

  int _consecutiveErrors = 0;
  final ImagePicker _picker = ImagePicker();
  int _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;

  final List<String> _familyMemberOptions = const [
    'Father', 'Mother', 'Sister', 'Brother', 'Son', 'Daughter',
    'Grandson', 'Grand Daughter', 'Grand Father', 'Grand Mother', 'Friend'
  ];
  final List<String> _roomOptions = const [
    'Living Room', 'Kitchen', 'Bedroom', 'Balcony', 'Garden', 'Temple Area', 'Main Door'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _saveAnalyticsTime();
    _customLabelController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _levels[CategoryTab.random] = prefs.getInt('sahayak_level_random') ?? 1;
      _levels[CategoryTab.familyPhotos] = prefs.getInt('sahayak_level_family') ?? 1;
      _levels[CategoryTab.mySurroundings] = prefs.getInt('sahayak_level_surroundings') ?? 1;

      final rawPhotos = prefs.getString('sahayak_library_photos');
      if (rawPhotos != null) {
        final List decoded = jsonDecode(rawPhotos);
        _libraryPhotos = decoded.map((e) => LibraryPhoto.fromJson(e)).toList();
      }
    });
    _generateQuiz();
  }

  Future<void> _saveAnalyticsTime() async {
    final elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - _sessionStartMillis) / 1000).floor();
    if (elapsedSeconds < 2) return;

    final minutesSpent = max(1, (elapsedSeconds / 60).round());
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sahayak_game_analytics');
    Map<String, dynamic> analytics = raw != null ? jsonDecode(raw) : {};

    final todayKey = DateTime.now().toIso8601String().split('T')[0];

    if (!analytics.containsKey(todayKey)) analytics[todayKey] = {};
    if (!analytics[todayKey].containsKey('Identify Picture')) {
      analytics[todayKey]['Identify Picture'] = {'minutes': 0, 'icon': '🖼️', 'color': '#8A5A1C'};
    }

    analytics[todayKey]['Identify Picture']['minutes'] += minutesSpent;
    await prefs.setString('sahayak_game_analytics', jsonEncode(analytics));
    _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;
  }

  void _startTutorialMode() {
    setState(() {
      _isTutorialMode = true;
      _showTutorial = true;
      _generateQuiz();
    });
  }

  void _generateQuiz() {
    setState(() {
      _selectedAnswer = null;
      _isCorrect = null;

      int optionCount = 2;
      if (!_isTutorialMode) {
        if (_currentLevel > 40) {
          optionCount = 6;
        } else if (_currentLevel > 15) {
          optionCount = 4;
        } else {
          optionCount = 3;
        }
      }

      final random = Random();

      if (_tab == CategoryTab.random) {
        final target = _realRandomData[random.nextInt(_realRandomData.length)];
        final distractors = _realRandomData.where((d) => d['name'] != target['name']).toList()..shuffle(random);
        final distractorNames = distractors.take(optionCount - 1).map((d) => d['name']!).toList();
        final List<String> allOptions = [...distractorNames, target['name']!]..shuffle(random);

        _currentQuestion = QuestionItem(
          id: 'rand-${DateTime.now().millisecondsSinceEpoch}',
          display: target['image']!,
          name: target['name']!,
          category: 'random',
        );
        _options = allOptions;
      } else {
        final targetType = _tab == CategoryTab.familyPhotos ? 'family' : 'surroundings';
        List<LibraryPhoto> categoryPhotos = _libraryPhotos.where((p) => p.category == targetType).toList();

        if (categoryPhotos.isEmpty) {
          _currentQuestion = null;
          _options = [];
          return;
        }

        final targetPhoto = categoryPhotos[random.nextInt(categoryPhotos.length)];
        final defaultPool = _tab == CategoryTab.familyPhotos ? _familyMemberOptions : _roomOptions;

        final otherLabels = defaultPool.where((l) => l.toLowerCase() != targetPhoto.label.toLowerCase()).toList()..shuffle(random);
        final chosenDistractors = otherLabels.take(optionCount - 1).toList();
        final List<String> allOptions = [...chosenDistractors, targetPhoto.label]..shuffle(random);

        _currentQuestion = QuestionItem(
          id: targetPhoto.id,
          display: targetPhoto.imageUrl,
          name: targetPhoto.label,
          category: targetType,
        );
        _options = allOptions;
      }
    });
  }

  Future<void> _handleSelectOption(String chosen) async {
    if (_selectedAnswer != null || _currentQuestion == null) return;

    setState(() {
      _selectedAnswer = chosen;
      final correct = chosen.toLowerCase() == _currentQuestion!.name.toLowerCase();
      _isCorrect = correct;

      if (correct) {
        _consecutiveErrors = 0;
        _saveAnalyticsTime();

        Future.delayed(const Duration(milliseconds: 1000), () async {
          if (!mounted) return;

          if (_isTutorialMode) {
            _isTutorialMode = false;
            _generateQuiz();
            return;
          }

          if (_currentLevel < 100) {
            final nextLvl = _currentLevel + 1;
            setState(() {
              _levels[_tab] = nextLvl;
            });

            final prefs = await SharedPreferences.getInstance();
            final storageKey = _tab == CategoryTab.random
                ? 'sahayak_level_random'
                : _tab == CategoryTab.familyPhotos
                ? 'sahayak_level_family'
                : 'sahayak_level_surroundings';
            await prefs.setInt(storageKey, nextLvl);
          }
          _generateQuiz();
        });
      } else {
        _consecutiveErrors++;

        if (_isTutorialMode) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!mounted) return;
            _generateQuiz();
          });
          return;
        }

        if (_consecutiveErrors >= 3 && _currentLevel > 1) {
          setState(() {
            _levels[_tab] = _currentLevel - 1;
            _consecutiveErrors = 0;
          });
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            _generateQuiz();
          });
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!mounted) return;
            _generateQuiz();
          });
        }
      }
    });
  }

  void _showMediaSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture using Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _handleImageUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _handleImageUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageUpload(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        setState(() {
          _capturedImage = image.path;
          _isCustomLabel = false;
          _customLabelController.clear();
          _photoLabel = _tab == CategoryTab.familyPhotos ? _familyMemberOptions.first : _roomOptions.first;
          _showUploadModal = true;
        });
      }
    } catch (e) {
      debugPrint("Photo upload error: $e");
    }
  }

  Future<void> _handleSaveCustomPhoto() async {
    if (_capturedImage == null) return;

    String finalLabel = _isCustomLabel ? _customLabelController.text.trim() : _photoLabel;
    if (finalLabel.isEmpty) finalLabel = 'Unknown';

    final category = _tab == CategoryTab.familyPhotos ? 'family' : 'surroundings';

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory targetDir = Directory('${appDir.path}/data/$category');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String permanentPath = '${targetDir.path}/$fileName';

      await File(_capturedImage!).copy(permanentPath);

      final newPhoto = LibraryPhoto(
        id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
        imageUrl: permanentPath,
        label: finalLabel,
        category: category,
      );

      final updated = [..._libraryPhotos, newPhoto];
      setState(() {
        _libraryPhotos = updated;
        _capturedImage = null;
        _showUploadModal = false;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sahayak_library_photos', jsonEncode(updated.map((e) => e.toJson()).toList()));
      _generateQuiz();
    } catch (e) {
      debugPrint("Error saving custom photo: $e");
    }
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image, size: 50)),
        ),
      );
    } else if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image, size: 50)),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image, size: 50)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentDropdownOptions = _tab == CategoryTab.familyPhotos
        ? [..._familyMemberOptions, 'Custom']
        : [..._roomOptions, 'Custom'];

    if (!currentDropdownOptions.contains(_photoLabel)) {
      _photoLabel = currentDropdownOptions.first;
    }

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _greenTint,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  _saveAnalyticsTime();
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_back_ios_new, size: 16, color: _green),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Identify Picture',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                  color: _ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _startTutorialMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _white,
                                border: Border.all(color: _blueHint, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.school_rounded, size: 14, color: _blueHint),
                                  const SizedBox(width: 4),
                                  Text('Tutorial', style: TextStyle(color: _blueHint, fontWeight: FontWeight.w900, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _marigoldTint,
                              border: Border.all(color: _marigold, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isTutorialMode ? 'Practice' : 'Lvl $_currentLevel/100',
                              style: const TextStyle(
                                color: Color(0xFF8A5A1C),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: CategoryTab.values.map((c) {
                              bool isActive = _tab == c;
                              String label = c == CategoryTab.random
                                  ? 'Random'
                                  : c == CategoryTab.familyPhotos
                                  ? 'Family photos'
                                  : 'My surroundings';
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _tab = c;
                                    });
                                    _generateQuiz();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isActive ? _green : Colors.white,
                                      border: Border.all(color: _greenTint, width: 1.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$label (Lvl ${_levels[c]})',
                                      style: TextStyle(
                                        color: isActive ? Colors.white : _green,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (_tab != CategoryTab.random)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFB8C7BA), width: 1.5),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _tab == CategoryTab.familyPhotos
                                      ? 'Add more family member photos to train memory mapping'
                                      : 'Add more surroundings photos to train memory mapping',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: _showMediaSourceSheet,
                                  icon: const Icon(Icons.add_a_photo, size: 18),
                                  label: const Text('Take / Upload Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 14),

                        if (_currentQuestion != null) ...[
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 230),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: _greenTint, width: 2),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildImage(_currentQuestion!.display),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tab == CategoryTab.familyPhotos
                                ? 'Who is this?'
                                : _tab == CategoryTab.mySurroundings
                                ? 'Which place is this?'
                                : 'What is shown here?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: _options.length,
                            itemBuilder: (context, idx) {
                              final opt = _options[idx];
                              Color btnBg = Colors.white;
                              Color textColor = _ink;
                              BorderSide borderSide = BorderSide.none;

                              if (_selectedAnswer != null) {
                                if (opt.toLowerCase() == _currentQuestion!.name.toLowerCase()) {
                                  btnBg = _greenTint;
                                  textColor = _green;
                                  borderSide = BorderSide(color: _green, width: 2);
                                } else if (opt == _selectedAnswer && _isCorrect == false) {
                                  btnBg = _redTint;
                                  textColor = _red;
                                  borderSide = BorderSide(color: _red, width: 2);
                                }
                              }

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnBg,
                                  foregroundColor: textColor,
                                  elevation: 2,
                                  shadowColor: _ink.withValues(alpha: 0.06),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: borderSide,
                                  ),
                                ),
                                onPressed: () => _handleSelectOption(opt),
                                child: Text(
                                  opt,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  'No photos available in Library for this category yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _inkSoft),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Upload a photo from Library or here to start training.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: _inkSoft),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _marigoldTint,
                            border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isTutorialMode
                                ? 'Practice Mode - Try to guess correctly!'
                                : _isCorrect == true
                                ? 'Correct! Leveling up (Options: ${_options.length})'
                                : _isCorrect == false
                                ? 'Incorrect. Adapting memory difficulty...'
                                : 'Playing Level $_currentLevel (Active Choices: ${_options.length})',
                            style: const TextStyle(color: Color(0xFF7A5015), fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Upload Modal Overlay
            if (_showUploadModal && _capturedImage != null)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Label Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey[200]),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(File(_capturedImage!), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey)),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _photoLabel,
                          items: currentDropdownOptions
                              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _photoLabel = val;
                                _isCustomLabel = (val == 'Custom');
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        // Custom Input Field
                        if (_isCustomLabel) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _customLabelController,
                            decoration: InputDecoration(
                              labelText: 'Enter Custom Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                                onPressed: _handleSaveCustomPhoto,
                                child: const Text('Save Photo'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black87),
                                onPressed: () => setState(() => _showUploadModal = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ANIMATED TUTORIAL OVERLAY FOR IDENTIFY PICTURE
            if (_showTutorial)
              ActivityGameTutorialOverlay(
                onComplete: () {
                  setState(() {
                    _showTutorial = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}