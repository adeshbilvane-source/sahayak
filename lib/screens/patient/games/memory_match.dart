import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_match_tutorial.dart';

enum CategoryType { fruits, shapes, household, numbers }

class CardItem {
  final String id;
  final String name;
  final String image;

  CardItem({
    required this.id,
    required this.name,
    required this.image,
  });
}

class DeckCard {
  final String uid;
  final CardItem item;

  DeckCard({
    required this.uid,
    required this.item,
  });
}

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  // Theme Colors
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _white = const Color(0xFFFFFFFF);
  final Color _blueHint = const Color(0xFF4A90E2);

  CategoryType _selectedCat = CategoryType.fruits;

  final Map<CategoryType, int> _levels = {
    CategoryType.fruits: 1,
    CategoryType.shapes: 1,
    CategoryType.household: 1,
    CategoryType.numbers: 1,
  };

  int get _currentLevel => _levels[_selectedCat]!;

  List<DeckCard> _deck = [];
  final List<int> _flipped = [];
  final List<int> _matched = [];
  bool _isWon = false;
  bool _isProcessing = false;

  int _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;

  final Map<CategoryType, List<CardItem>> _realDatasets = {
    CategoryType.fruits: [
      CardItem(id: 'f1', name: 'Apple', image: 'assets/memory_matching/fruits/apple.jpg'),
      CardItem(id: 'f2', name: 'Banana', image: 'assets/memory_matching/fruits/banana.jpg'),
      CardItem(id: 'f3', name: 'Carrot', image: 'assets/memory_matching/fruits/carrot.jpg'),
      CardItem(id: 'f4', name: 'Cherry', image: 'assets/memory_matching/fruits/cherry.jpg'),
      CardItem(id: 'f5', name: 'Grapes', image: 'assets/memory_matching/fruits/grapes.jpg'),
      CardItem(id: 'f6', name: 'Kiwi', image: 'assets/memory_matching/fruits/kivi.jpg'), // Fixed typo here
      CardItem(id: 'f7', name: 'Lemon', image: 'assets/memory_matching/fruits/lemon.jpg'),
      CardItem(id: 'f8', name: 'Mango', image: 'assets/memory_matching/fruits/mango.jpg'),
      CardItem(id: 'f9', name: 'Onion', image: 'assets/memory_matching/fruits/onion.jpg'),
      CardItem(id: 'f10', name: 'Orange', image: 'assets/memory_matching/fruits/orange.jpg'),
      CardItem(id: 'f11', name: 'Peach', image: 'assets/memory_matching/fruits/peach.jpg'),
      CardItem(id: 'f12', name: 'Pear', image: 'assets/memory_matching/fruits/pear.jpg'),
      CardItem(id: 'f13', name: 'Pineapple', image: 'assets/memory_matching/fruits/pinapple.jpg'),
      CardItem(id: 'f14', name: 'Plum', image: 'assets/memory_matching/fruits/plum.jpg'),
      CardItem(id: 'f15', name: 'Potato', image: 'assets/memory_matching/fruits/potato.jpg'),
      CardItem(id: 'f16', name: 'Raspberry', image: 'assets/memory_matching/fruits/raspberry.jpg'),
      CardItem(id: 'f17', name: 'Strawberry', image: 'assets/memory_matching/fruits/stawberry.jpg'),
      CardItem(id: 'f18', name: 'Tomato', image: 'assets/memory_matching/fruits/tomato.jpg'),
      CardItem(id: 'f19', name: 'Watermelon', image: 'assets/memory_matching/fruits/watermelon.jpg'),
    ],
    CategoryType.shapes: [
      CardItem(id: 's1', name: 'Circle', image: 'assets/memory_matching/shapes/Circle.jpg'),
      CardItem(id: 's2', name: 'Triangle', image: 'assets/memory_matching/shapes/Triangle.jpg'),
      CardItem(id: 's3', name: 'Cube', image: 'assets/memory_matching/shapes/Cube.jpg'),
      CardItem(id: 's4', name: 'Decagon', image: 'assets/memory_matching/shapes/Decagon.jpg'),
      CardItem(id: 's5', name: 'Diamond', image: 'assets/memory_matching/shapes/Diamond.jpg'),
      CardItem(id: 's6', name: 'Heptagon', image: 'assets/memory_matching/shapes/Heptagon.jpg'),
      CardItem(id: 's7', name: 'Hexagon', image: 'assets/memory_matching/shapes/Hexagon.jpg'),
      CardItem(id: 's8', name: 'Kite', image: 'assets/memory_matching/shapes/Kite.jpg'),
      CardItem(id: 's9', name: 'Nonagon', image: 'assets/memory_matching/shapes/Nonagon.jpg'),
      CardItem(id: 's10', name: 'Octagon', image: 'assets/memory_matching/shapes/Octagon.jpg'),
      CardItem(id: 's11', name: 'Pentagon', image: 'assets/memory_matching/shapes/Pentagon.jpg'),
      CardItem(id: 's12', name: 'Rhombus', image: 'assets/memory_matching/shapes/Rhombus.jpg'),
      CardItem(id: 's13', name: 'Square', image: 'assets/memory_matching/shapes/Square.jpg'),
      CardItem(id: 's14', name: 'Star', image: 'assets/memory_matching/shapes/Star.jpg'),
      CardItem(id: 's15', name: 'Trapezium', image: 'assets/memory_matching/shapes/Trapezium.jpg'),
      CardItem(id: 's16', name: 'Parallelogram', image: 'assets/memory_matching/shapes/Parallelogram.jpg'),
    ],
    CategoryType.household: [
      CardItem(id: 'h1', name: 'Bed', image: 'assets/memory_matching/household/Bed.jpg'),
      CardItem(id: 'h2', name: 'Book', image: 'assets/memory_matching/household/Book.jpg'),
      CardItem(id: 'h3', name: 'Chair', image: 'assets/memory_matching/household/chair.jpg'),
      CardItem(id: 'h4', name: 'Clock', image: 'assets/memory_matching/household/Clock.jpg'),
      CardItem(id: 'h5', name: 'Cup', image: 'assets/memory_matching/household/Cup.jpg'),
      CardItem(id: 'h6', name: 'Fan', image: 'assets/memory_matching/household/fan.jpg'),
      CardItem(id: 'h7', name: 'Kettle', image: 'assets/memory_matching/household/Kettle.jpg'),
      CardItem(id: 'h8', name: 'Key', image: 'assets/memory_matching/household/key.jpg'),
      CardItem(id: 'h9', name: 'Lamp', image: 'assets/memory_matching/household/Lamp.jpg'),
      CardItem(id: 'h10', name: 'Mirror', image: 'assets/memory_matching/household/Mirror.jpg'),
      CardItem(id: 'h11', name: 'Oven', image: 'assets/memory_matching/household/Oven.jpg'),
      CardItem(id: 'h12', name: 'Pillow', image: 'assets/memory_matching/household/Pillow.jpg'),
      CardItem(id: 'h13', name: 'Sofa', image: 'assets/memory_matching/household/Sofa.jpg'),
      CardItem(id: 'h14', name: 'Table', image: 'assets/memory_matching/household/Table.jpg'),
      CardItem(id: 'h15', name: 'TV', image: 'assets/memory_matching/household/tv.jpg'),
      CardItem(id: 'h16', name: 'Toaster', image: 'assets/memory_matching/household/Toaster.jpg'),
      CardItem(id: 'h18', name: 'Washing Machine', image: 'assets/memory_matching/household/WashingM.jpg'),
      CardItem(id: 'h19', name: 'Water Bottle', image: 'assets/memory_matching/household/WaterB.jpg'),
    ],
    CategoryType.numbers: [
      CardItem(id: 'n1', name: 'One', image: 'assets/memory_matching/numbers/One.png'),
      CardItem(id: 'n2', name: 'Two', image: 'assets/memory_matching/numbers/two.jpg'),
      CardItem(id: 'n3', name: 'Three', image: 'assets/memory_matching/numbers/three.jpg'),
      CardItem(id: 'n4', name: 'Four', image: 'assets/memory_matching/numbers/four.jpg'),
      CardItem(id: 'n5', name: 'Five', image: 'assets/memory_matching/numbers/five.jpg'),
      CardItem(id: 'n6', name: 'Six', image: 'assets/memory_matching/numbers/six.jpg'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _saveAnalyticsTime();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _levels[CategoryType.fruits] = prefs.getInt('sahayak_mem_lvl_fruits') ?? 1;
      _levels[CategoryType.shapes] = prefs.getInt('sahayak_mem_lvl_shapes') ?? 1;
      _levels[CategoryType.household] = prefs.getInt('sahayak_mem_lvl_household') ?? 1;
      _levels[CategoryType.numbers] = prefs.getInt('sahayak_mem_lvl_numbers') ?? 1;
    });
    _initBoard();
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
    if (!analytics[todayKey].containsKey('Memory Match')) {
      analytics[todayKey]['Memory Match'] = {'minutes': 0, 'icon': '🃏', 'color': '#3F6B4F'};
    }

    analytics[todayKey]['Memory Match']['minutes'] += minutesSpent;
    await prefs.setString('sahayak_game_analytics', jsonEncode(analytics));
    _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;
  }

  void _startTutorialMode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MemoryMatchTutorialScreen()),
    );
  }

  void _initBoard() {
    setState(() {
      _flipped.clear();
      _matched.clear();
      _isWon = false;
      _isProcessing = false;

      int pairCount = 2;
      final dataset = _realDatasets[_selectedCat] ?? _realDatasets[CategoryType.fruits]!;
      final maxAvailable = dataset.length;
      pairCount = min(pairCount, maxAvailable);

      final pool = List<CardItem>.from(dataset)..shuffle(Random());
      final picked = pool.take(pairCount).toList();
      final combined = [...picked, ...picked]..shuffle(Random());

      _deck = combined.asMap().entries.map((entry) {
        int i = entry.key;
        CardItem item = entry.value;
        return DeckCard(
          uid: '${item.id}-$i-${DateTime.now().millisecondsSinceEpoch}',
          item: item,
        );
      }).toList();
    });
  }

  void _handleCardClick(int idx) {
    if (_isProcessing || _flipped.length == 2 || _flipped.contains(idx) || _matched.contains(idx)) return;

    setState(() {
      _flipped.add(idx);
    });

    if (_flipped.length == 2) {
      _isProcessing = true;
      final first = _flipped[0];
      final second = _flipped[1];

      if (_deck[first].item.name == _deck[second].item.name) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _matched.add(first);
            _matched.add(second);
            _flipped.clear();
            _isProcessing = false;
          });

          if (_matched.length == _deck.length && _deck.isNotEmpty) {
            setState(() {
              _isWon = true;
            });
            _saveAnalyticsTime();
            _showWinPopup();
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _flipped.clear();
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _showWinPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: _white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  'Congratulations!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _green),
                ),
                const SizedBox(height: 8),
                Text(
                  'You successfully completed Level $_currentLevel.\nGreat memory!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _inkSoft, height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _marigold,
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      if (_currentLevel < 100) {
                        final nextLvl = _currentLevel + 1;
                        setState(() {
                          _levels[_selectedCat] = nextLvl;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        final keyMap = {
                          CategoryType.fruits: 'sahayak_mem_lvl_fruits',
                          CategoryType.shapes: 'sahayak_mem_lvl_shapes',
                          CategoryType.household: 'sahayak_mem_lvl_household',
                          CategoryType.numbers: 'sahayak_mem_lvl_numbers',
                        };
                        await prefs.setInt(keyMap[_selectedCat]!, nextLvl);
                      }
                      _initBoard();
                    },
                    child: const Text('Go to Next Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
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
            // Top Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: _white,
                boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
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
                            'Memory Match',
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
                          'Lvl $_currentLevel',
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

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category Select Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: [
                        {'key': CategoryType.fruits, 'label': 'Fruits & Veg'},
                        {'key': CategoryType.shapes, 'label': 'Shapes'},
                        {'key': CategoryType.household, 'label': 'Household'},
                        {'key': CategoryType.numbers, 'label': 'Numbers'},
                      ].map((c) {
                        final CategoryType type = c['key'] as CategoryType;
                        final String label = c['label'] as String;
                        final bool isActive = _selectedCat == type;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCat = type;
                            });
                            _initBoard();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive ? _marigoldTint : _white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive ? _marigold : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Text(
                              '$label (Lvl ${_levels[type]})',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isActive ? const Color(0xFF8A5A1C) : _ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Cards Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _deck.length,
                      itemBuilder: (context, idx) {
                        final card = _deck[idx];
                        final bool isFlipped = _flipped.contains(idx) || _matched.contains(idx);
                        final bool isMatched = _matched.contains(idx);

                        return GestureDetector(
                          onTap: () => _handleCardClick(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isFlipped ? _white : _green,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMatched
                                    ? _marigold
                                    : isFlipped
                                    ? _greenTint
                                    : Colors.transparent,
                                width: isMatched ? 3 : 2,
                              ),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Center(
                              child: isFlipped
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  card.item.image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              )
                                  : const Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Callout Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _marigoldTint,
                        border: Border(left: BorderSide(color: _marigold, width: 4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isWon
                            ? 'Superb! Loading next level...'
                            : 'Playing Level $_currentLevel - Tap 2 cards to find matching pairs.',
                        style: const TextStyle(
                          color: Color(0xFF7A5015),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
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
}