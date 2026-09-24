import 'package:flutter/material.dart';
import 'dart:math';
import 'button_sorting_tutorial_overlay.dart'; // Tutorial file ko import kiya hai

// Game modes
enum SortMode { shape, color }

// Button Model
class ButtonItem {
  final int id;
  final String shape; // 'round' or 'square'
  final String colorName;
  final Color colorValue;

  ButtonItem({
    required this.id,
    required this.shape,
    required this.colorName,
    required this.colorValue,
  });
}

class ColorPaletteEntry {
  final String name;
  final Color value;
  const ColorPaletteEntry({required this.name, required this.value});
}

class ButtonSortingScreen extends StatefulWidget {
  const ButtonSortingScreen({super.key});

  @override
  State<ButtonSortingScreen> createState() => _ButtonSortingScreenState();
}

class _ButtonSortingScreenState extends State<ButtonSortingScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF8FAF7);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _red = const Color(0xFFB33F33);
  final Color _redTint = const Color(0xFFFBE8E6);
  final Color _blueHint = const Color(0xFF4A90E2);

  // Color Palette
  final List<ColorPaletteEntry> _colorPalette = const [
    ColorPaletteEntry(name: 'Orange', value: Color(0xFFD98A2B)),
    ColorPaletteEntry(name: 'Green', value: Color(0xFF3F6B4F)),
    ColorPaletteEntry(name: 'Red', value: Color(0xFFB33F33)),
    ColorPaletteEntry(name: 'Blue', value: Color(0xFF3E7FB8)),
  ];

  // Game States
  SortMode _mode = SortMode.shape;
  int _level = 1;
  bool _showTutorial = false; // Tutorial dikhane ke liye switch

  List<ButtonItem> _items = [];
  ButtonItem? _selectedItem;

  // Shape Bins
  final List<ButtonItem> _roundBin = [];
  final List<ButtonItem> _squareBin = [];

  // Color Bins
  final List<ButtonItem> _colorBin1 = [];
  final List<ButtonItem> _colorBin2 = [];
  late ColorPaletteEntry _colorTarget1;
  late ColorPaletteEntry _colorTarget2;

  String _feedback = 'Select a button from above, then tap the matching bin below.';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _colorTarget1 = _colorPalette[0];
    _colorTarget2 = _colorPalette[1];
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      _selectedItem = null;
      _roundBin.clear();
      _squareBin.clear();
      _colorBin1.clear();
      _colorBin2.clear();
      _isError = false;
      _feedback = 'Select a button from above, then tap the matching bin below.';

      int count = 4;
      if (_level > 25) {
        count = 8;
      } else if (_level > 10) {
        count = 6;
      }

      final random = Random();

      if (_mode == SortMode.shape) {
        List<ButtonItem> generated = [];
        for (int i = 0; i < count; i++) {
          String shape = random.nextBool() ? 'round' : 'square';
          ColorPaletteEntry col = _colorPalette[random.nextInt(_colorPalette.length)];
          generated.add(ButtonItem(
            id: DateTime.now().millisecondsSinceEpoch + i,
            shape: shape,
            colorName: col.name,
            colorValue: col.value,
          ));
        }
        _items = generated;
      } else {
        List<ColorPaletteEntry> shuffledColors = List.from(_colorPalette)..shuffle(random);
        _colorTarget1 = shuffledColors[0];
        _colorTarget2 = shuffledColors[1];

        List<ButtonItem> generated = [];
        for (int i = 0; i < count; i++) {
          ColorPaletteEntry chosenCol = random.nextBool() ? _colorTarget1 : _colorTarget2;
          String shape = random.nextBool() ? 'round' : 'square';
          generated.add(ButtonItem(
            id: DateTime.now().millisecondsSinceEpoch + i,
            shape: shape,
            colorName: chosenCol.name,
            colorValue: chosenCol.value,
          ));
        }
        _items = generated;
      }
    });
  }

  void _handleSelectButton(ButtonItem item) {
    setState(() {
      _selectedItem = item;
      _isError = false;
      _feedback = 'Selected ${item.shape} button in ${item.colorName}.';
    });
  }

  void _handlePlaceInBin(String binType) {
    if (_selectedItem == null) {
      setState(() {
        _isError = true;
        _feedback = 'Please select a button first!';
      });
      return;
    }

    setState(() {
      if (_mode == SortMode.shape) {
        if (_selectedItem!.shape == binType) {
          if (binType == 'round') {
            _roundBin.add(_selectedItem!);
          } else {
            _squareBin.add(_selectedItem!);
          }

          _items.removeWhere((i) => i.id == _selectedItem!.id);
          _selectedItem = null;
          _isError = false;
          _feedback = 'Correct!';

          if (_items.isEmpty) {
            _feedback = 'Level Complete! 🎉';
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) {
                setState(() {
                  if (_level < 100) {
                    _level++;
                  }
                  _generateLevel();
                });
              }
            });
          }
        } else {
          _isError = true;
          _feedback = 'Incorrect! This is a ${_selectedItem!.shape} button.';
        }
      } else {
        // Color Mode
        String targetColorName = (binType == 'c1') ? _colorTarget1.name : _colorTarget2.name;
        if (_selectedItem!.colorName == targetColorName) {
          if (binType == 'c1') {
            _colorBin1.add(_selectedItem!);
          } else {
            _colorBin2.add(_selectedItem!);
          }

          _items.removeWhere((i) => i.id == _selectedItem!.id);
          _selectedItem = null;
          _isError = false;
          _feedback = 'Correct!';

          if (_items.isEmpty) {
            _feedback = 'Level Complete! 🎉';
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) {
                setState(() {
                  if (_level < 100) {
                    _level++;
                  }
                  _generateLevel();
                });
              }
            });
          }
        } else {
          _isError = true;
          _feedback = 'Incorrect! This is a ${_selectedItem!.colorName} button.';
        }
      }
    });
  }

  Widget _buildButtonWidget(ButtonItem item, {double size = 52, bool isSelected = false}) {
    bool isSquare = item.shape == 'square';
    return GestureDetector(
      onTap: () => _handleSelectButton(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: item.colorValue,
          borderRadius: BorderRadius.circular(isSquare ? 14 : size / 2),
          border: Border.all(
            color: isSelected ? _ink : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.15),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Yahan check kar rahe hain ki Tutorial dikhana hai ya Game
    if (_showTutorial) {
      return ButtonSortingTutorialOverlay(
        onComplete: () {
          setState(() {
            _showTutorial = false; // Tutorial band, actual game start
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                          onPressed: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios_new, size: 16, color: _green),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Button Sorting',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),

                  // TUTORIAL BUTTON
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showTutorial = true; // Button dabane par tutorial on ho jayega
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _blueHint, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded, size: 14, color: _blueHint),
                          const SizedBox(width: 4),
                          Text('Tutorial', style: TextStyle(color: _blueHint, fontWeight: FontWeight.w900, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Selector Chips
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mode = SortMode.shape;
                                _generateLevel();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _mode == SortMode.shape ? _green : Colors.white,
                                border: Border.all(color: _greenTint, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'By Shape',
                                style: TextStyle(
                                  color: _mode == SortMode.shape ? Colors.white : _green,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mode = SortMode.color;
                                _generateLevel();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _mode == SortMode.color ? _green : Colors.white,
                                border: Border.all(color: _greenTint, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'By Colour',
                                style: TextStyle(
                                  color: _mode == SortMode.color ? Colors.white : _green,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Selection Pool Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(minHeight: 100),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _greenTint, width: 2),
                        boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: _items.isEmpty
                          ? Center(
                        child: Text(
                          'Level Completed!',
                          style: TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      )
                          : Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _items.map((item) {
                          bool isSelected = _selectedItem?.id == item.id;
                          return Transform.scale(
                            scale: isSelected ? 1.15 : 1.0,
                            child: _buildButtonWidget(item, isSelected: isSelected, size: 60),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Target Bins
                    if (_mode == SortMode.shape)
                      Row(
                        children: [
                          Expanded(
                            child: _buildBin(
                              title: 'Round (${_roundBin.length})',
                              binType: 'round',
                              contents: _roundBin,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBin(
                              title: 'Square (${_squareBin.length})',
                              binType: 'square',
                              contents: _squareBin,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildBin(
                              title: '🎨 ${_colorTarget1.name} (${_colorBin1.length})',
                              binType: 'c1',
                              borderColor: _colorTarget1.value,
                              contents: _colorBin1,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBin(
                              title: '🎨 ${_colorTarget2.name} (${_colorBin2.length})',
                              binType: 'c2',
                              borderColor: _colorTarget2.value,
                              contents: _colorBin2,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Feedback Callout Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isError ? _redTint : _marigoldTint,
                        border: Border(
                          left: BorderSide(
                            color: _isError ? _red : _marigold,
                            width: 6,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _feedback,
                        style: TextStyle(
                          color: _isError ? _red : const Color(0xFF7A5015),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBin({
    required String title,
    required String binType,
    required List<ButtonItem> contents,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: () => _handlePlaceInBin(binType),
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor ?? _green,
            width: 3.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: contents.map((b) => _buildButtonWidget(b, size: 30)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}