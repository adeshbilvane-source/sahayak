import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'jigsaw_tutorial_overlay.dart'; // Tutorial Overlay ko import kiya

class PuzzleImage {
  final String id;
  final String name;
  final String url;
  PuzzleImage({required this.id, required this.name, required this.url});
}

// Offline local asset images
final List<PuzzleImage> _puzzleImages = [
  PuzzleImage(id: 'img1', name: 'Colorful Umbrellas', url: 'assets/jigsaw_images/01.jpg'),
  PuzzleImage(id: 'img2', name: 'Indian Spices', url: 'assets/jigsaw_images/02.jpg'),
  PuzzleImage(id: 'img3', name: 'Balloon Festival', url: 'assets/jigsaw_images/03.jpg'),
  PuzzleImage(id: 'img4', name: 'Macaw Parrot', url: 'assets/jigsaw_images/04.jpg'),
  PuzzleImage(id: 'img5', name: 'Colorful Rangoli', url: 'assets/jigsaw_images/05.jpeg'),
  PuzzleImage(id: 'img6', name: 'Vintage Yellow Car', url: 'assets/jigsaw_images/06.jpeg'),
  PuzzleImage(id: 'img7', name: 'Fresh Fruit Basket', url: 'assets/jigsaw_images/07.jpg'),
  PuzzleImage(id: 'img8', name: 'Decorated Elephant', url: 'assets/jigsaw_images/08.jpeg'),
  PuzzleImage(id: 'img9', name: 'Autumn Leaves', url: 'assets/jigsaw_images/09.jpg'),
  PuzzleImage(id: 'img10', name: 'Colorful Boats', url: 'assets/jigsaw_images/10.jpg'),
  PuzzleImage(id: 'img11', name: 'Traditional Tea Cups', url: 'assets/jigsaw_images/11.jpg'),
  PuzzleImage(id: 'img12', name: 'Butterfly on Flower', url: 'assets/jigsaw_images/12.jpg'),
  PuzzleImage(id: 'img13', name: 'Sunset Lighthouse', url: 'assets/jigsaw_images/13.jpg'),
  PuzzleImage(id: 'img14', name: 'Puppy with Scarf', url: 'assets/jigsaw_images/14.jpg'),
  PuzzleImage(id: 'img15', name: 'Bright Sunflowers', url: 'assets/jigsaw_images/15.jpg'),
  PuzzleImage(id: 'img16', name: 'Majestic Peacock', url: 'assets/jigsaw_images/16.jpg'),
];

class JigsawPuzzleScreen extends StatefulWidget {
  const JigsawPuzzleScreen({super.key});
  @override
  State<JigsawPuzzleScreen> createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends State<JigsawPuzzleScreen> {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _white = const Color(0xFFFFFFFF);
  final Color _red = const Color(0xFFB33F33);
  final Color _blueHint = const Color(0xFF4A90E2);

  int _level = 1;

  bool _isTutorialMode = false;
  bool _showTutorial = false;

  int get _cols {
    if (_isTutorialMode) return 2;
    if (_level >= 86) return 3;
    if (_level >= 76) return 4;
    if (_level >= 61) return 3;
    if (_level >= 51) return 3;
    if (_level >= 41) return 2;
    if (_level >= 31) return 3;
    if (_level >= 21) return 2;
    if (_level >= 11) return 2;
    return 2;
  }

  int get _rows {
    if (_isTutorialMode) return 2;
    if (_level >= 86) return 6;
    if (_level >= 76) return 4;
    if (_level >= 61) return 5;
    if (_level >= 51) return 4;
    if (_level >= 41) return 5;
    if (_level >= 31) return 3;
    if (_level >= 21) return 4;
    if (_level >= 11) return 3;
    return 2;
  }

  int get _totalTiles => _cols * _rows;

  int _currentImageIndex = 0;
  PuzzleImage get _activeImage => _puzzleImages[_currentImageIndex % _puzzleImages.length];

  final Map<int, int> _placedPieces = {};
  List<int> _poolPieces = [];
  Map<String, int>? _selectedPiece;

  bool _isWon = false;
  bool _showPreview = false;

  Timer? _idleTimer;
  int? _hintPiece;
  int? _hintSlot;

  int _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _saveAnalyticsTime();
    _idleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _level = prefs.getInt('sahayak_jigsaw_level') ?? 1;
      _currentImageIndex = (_level - 1) % _puzzleImages.length;
    });
    _initPuzzle();
  }

  Future<void> _saveAnalyticsTime() async {
    final elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - _sessionStartMillis) / 1000).floor();
    if (elapsedSeconds < 2) return;

    final minutesSpent = math.max(1, (elapsedSeconds / 60).round());
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sahayak_game_analytics');
    Map<String, dynamic> analytics = raw != null ? jsonDecode(raw) : {};
    final todayKey = DateTime.now().toIso8601String().split('T')[0];

    if (!analytics.containsKey(todayKey)) analytics[todayKey] = {};
    if (!analytics[todayKey].containsKey('Jigsaw Puzzle')) {
      analytics[todayKey]['Jigsaw Puzzle'] = {'minutes': 0, 'icon': '🧩', 'color': '#D98A2B'};
    }

    analytics[todayKey]['Jigsaw Puzzle']['minutes'] += minutesSpent;
    await prefs.setString('sahayak_game_analytics', jsonEncode(analytics));
    _sessionStartMillis = DateTime.now().millisecondsSinceEpoch;
  }

  void _startTutorialMode() {
    setState(() {
      _isTutorialMode = true;
      _showTutorial = true;
      _isWon = false;
      _placedPieces.clear();
      _selectedPiece = null;
      _currentImageIndex = 0;
      _poolPieces = List.generate(_totalTiles, (i) => i)..shuffle(math.Random());
    });
    _idleTimer?.cancel();
  }

  void _initPuzzle() {
    setState(() {
      _isTutorialMode = false;
      _showTutorial = false;
      _isWon = false;
      _placedPieces.clear();
      _selectedPiece = null;
      _currentImageIndex = (_level - 1) % _puzzleImages.length;
      _poolPieces = List.generate(_totalTiles, (i) => i)..shuffle(math.Random());
    });
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    setState(() {
      _hintPiece = null;
      _hintSlot = null;
    });

    if (!_isWon && !_isTutorialMode) {
      _idleTimer = Timer(const Duration(seconds: 10), _triggerHint);
    }
  }

  void _triggerHint() {
    if (_isWon || !mounted || _isTutorialMode) return;

    int? pieceToMove;
    if (_poolPieces.isNotEmpty) {
      pieceToMove = _poolPieces.first;
    } else {
      for (var entry in _placedPieces.entries) {
        if (entry.key != entry.value) {
          pieceToMove = entry.value;
          break;
        }
      }
    }

    if (pieceToMove != null) {
      setState(() {
        _hintPiece = pieceToMove;
        _hintSlot = pieceToMove;
      });
    }
  }

  void _handlePieceMove(Map<String, int> pieceData, int targetSlot) {
    if (_isWon || _showTutorial) return;
    _resetIdleTimer();

    final int pieceIndex = pieceData['piece']!;
    final int sourceSlot = pieceData['source']!;

    setState(() {
      _selectedPiece = null;

      if (targetSlot == -1) {
        if (sourceSlot != -1) {
          _placedPieces.remove(sourceSlot);
          if (!_poolPieces.contains(pieceIndex)) {
            _poolPieces.add(pieceIndex);
          }
        }
      } else {
        if (sourceSlot == -1) {
          _poolPieces.remove(pieceIndex);
          if (_placedPieces.containsKey(targetSlot)) {
            _poolPieces.add(_placedPieces[targetSlot]!);
          }
          _placedPieces[targetSlot] = pieceIndex;
        } else {
          if (_placedPieces.containsKey(targetSlot)) {
            final int existingPiece = _placedPieces[targetSlot]!;
            _placedPieces[sourceSlot] = existingPiece;
            _placedPieces[targetSlot] = pieceIndex;
          } else {
            _placedPieces.remove(sourceSlot);
            _placedPieces[targetSlot] = pieceIndex;
          }
        }
      }
      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_placedPieces.length == _totalTiles) {
      bool isAllCorrect = true;
      _placedPieces.forEach((slot, piece) {
        if (slot != piece) {
          isAllCorrect = false;
        }
      });

      if (isAllCorrect) {
        setState(() {
          _isWon = true;
          _selectedPiece = null;
        });
        _idleTimer?.cancel();
        _saveAnalyticsTime();
        _showWinPopup();
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
                  _isTutorialMode ? 'Tutorial Completed!' : 'Congratulations!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _green),
                ),
                const SizedBox(height: 8),
                Text(
                  _isTutorialMode
                      ? 'You now know how to play!\nLet\'s play the real game.'
                      : 'You successfully completed Level $_level.\nGreat job!',
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
                      if (_isTutorialMode) {
                        _initPuzzle();
                      } else {
                        if (_level < 100) {
                          final nextLvl = _level + 1;
                          setState(() => _level = nextLvl);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('sahayak_jigsaw_level', nextLvl);
                        }
                        _initPuzzle();
                      }
                    },
                    child: Text(
                      _isTutorialMode ? 'Play My Level' : 'Go to Next Level',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleBoardSlotTap(int slotIndex) {
    if (_isWon || _showTutorial) return;
    _resetIdleTimer();

    setState(() {
      if (_selectedPiece != null) {
        if (_selectedPiece!['source'] == slotIndex) {
          _selectedPiece = null;
        } else {
          _handlePieceMove(_selectedPiece!, slotIndex);
        }
      } else {
        if (_placedPieces.containsKey(slotIndex)) {
          _selectedPiece = {'piece': _placedPieces[slotIndex]!, 'source': slotIndex};
        }
      }
    });
  }

  void _handleTrayPieceTap(int pieceIndex) {
    if (_isWon || _showTutorial) return;
    _resetIdleTimer();

    setState(() {
      if (_selectedPiece != null) {
        if (_selectedPiece!['source'] == -1 && _selectedPiece!['piece'] == pieceIndex) {
          _selectedPiece = null;
        } else if (_selectedPiece!['source'] != -1) {
          _handlePieceMove(_selectedPiece!, -1);
        } else {
          _selectedPiece = {'piece': pieceIndex, 'source': -1};
        }
      } else {
        _selectedPiece = {'piece': pieceIndex, 'source': -1};
      }
    });
  }

  void _handleTrayBackgroundTap() {
    if (_isWon || _showTutorial) return;
    _resetIdleTimer();

    setState(() {
      if (_selectedPiece != null && _selectedPiece!['source'] != -1) {
        _handlePieceMove(_selectedPiece!, -1);
      } else {
        _selectedPiece = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tutorial mode check
    if (_showTutorial) {
      return JigsawTutorialOverlay(
        imageUrl: _activeImage.url,
        cols: _cols,
        rows: _rows,
        onComplete: () {
          setState(() {
            _showTutorial = false;
          });
          _resetIdleTimer();
        },
      );
    }

    // 2. Main Game Screen
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: _white,
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
                            'Jigsaw Puzzle',
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
                          _isTutorialMode ? 'Practice' : 'Lvl $_level/100',
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

            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      // Target Board
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCAD5C6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _green, width: 3),
                                  boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 6))],
                                ),
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _cols,
                                    childAspectRatio: _rows / _cols,
                                  ),
                                  itemCount: _totalTiles,
                                  itemBuilder: (context, slotIndex) {
                                    final hasPiece = _placedPieces.containsKey(slotIndex);
                                    final isSelected = _selectedPiece != null && _selectedPiece!['source'] == slotIndex;
                                    final isHintTargetSlot = _hintSlot == slotIndex;
                                    final isHintPieceHere = hasPiece && _placedPieces[slotIndex] == _hintPiece;
                                    final showHintGlow = isHintTargetSlot || isHintPieceHere;

                                    return GestureDetector(
                                      onTap: () => _handleBoardSlotTap(slotIndex),
                                      child: DragTarget<Map<String, int>>(
                                        onWillAcceptWithDetails: (details) => true,
                                        onAcceptWithDetails: (details) => _handlePieceMove(details.data, slotIndex),
                                        builder: (context, candidateData, rejectedData) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? _marigold
                                                    : (showHintGlow ? _blueHint : _white.withValues(alpha: 0.4)),
                                                width: isSelected || showHintGlow ? 3.5 : 0.5,
                                              ),
                                              color: candidateData.isNotEmpty || isSelected || showHintGlow
                                                  ? (showHintGlow
                                                  ? _blueHint.withValues(alpha: 0.3)
                                                  : _marigoldTint.withValues(alpha: 0.6))
                                                  : Colors.transparent,
                                            ),
                                            child: hasPiece
                                                ? Draggable<Map<String, int>>(
                                              data: {'piece': _placedPieces[slotIndex]!, 'source': slotIndex},
                                              feedback: Material(color: Colors.transparent, child: _buildDraggedPiece(_placedPieces[slotIndex]!)),
                                              childWhenDragging: Opacity(opacity: 0.3, child: _buildStaticPiece(_placedPieces[slotIndex]!)),
                                              child: _buildStaticPiece(_placedPieces[slotIndex]!),
                                            )
                                                : Center(
                                              child: Icon(Icons.add, color: showHintGlow ? _blueHint : _white.withValues(alpha: 0.4), size: 24),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hint & Control Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _isTutorialMode
                                    ? 'Practice Mode - Place pieces correctly.'
                                    : _isWon
                                    ? 'Perfect! Next level coming...'
                                    : _hintPiece != null
                                    ? 'Hint: Move the blue piece to the blue box!'
                                    : _selectedPiece != null
                                    ? 'Tap an empty box to drop'
                                    : 'Drag or Tap a piece to move',
                                style: TextStyle(fontWeight: FontWeight.w900, color: _hintPiece != null ? _blueHint : _inkSoft, fontSize: 12),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_isTutorialMode) {
                                      _startTutorialMode();
                                    } else {
                                      _initPuzzle();
                                    }
                                    _resetIdleTimer();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _white,
                                      border: Border.all(color: _red.withValues(alpha: 0.4), width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Reset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _red)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _showPreview = true);
                                    _resetIdleTimer();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _white,
                                      border: Border.all(color: _greenTint, width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('View Photo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _green)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tray Area
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _handleTrayBackgroundTap,
                          child: DragTarget<Map<String, int>>(
                            onWillAcceptWithDetails: (details) => true,
                            onAcceptWithDetails: (details) => _handlePieceMove(details.data, -1),
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty ? _marigoldTint.withValues(alpha: 0.3) : _white,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                  boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -5))],
                                ),
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: _poolPieces.map((pieceIndex) {
                                      final isSelected = _selectedPiece != null && _selectedPiece!['source'] == -1 && _selectedPiece!['piece'] == pieceIndex;
                                      final isHint = _hintPiece == pieceIndex && _poolPieces.contains(pieceIndex);

                                      return GestureDetector(
                                        onTap: () => _handleTrayPieceTap(pieceIndex),
                                        child: Draggable<Map<String, int>>(
                                          data: {'piece': pieceIndex, 'source': -1},
                                          feedback: Material(color: Colors.transparent, child: _buildDraggedPiece(pieceIndex)),
                                          childWhenDragging: Opacity(opacity: 0.2, child: _buildTrayPiece(pieceIndex, isSelected, isHint)),
                                          child: _buildTrayPiece(pieceIndex, isSelected, isHint),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_showPreview)
                    GestureDetector(
                      onTap: () => setState(() => _showPreview = false),
                      child: Container(
                        color: _ink.withValues(alpha: 0.8),
                        alignment: Alignment.center,
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Target Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _ink)),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(_activeImage.url, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  setState(() => _showPreview = false);
                                  _resetIdleTimer();
                                },
                                child: const Text('Back to Game', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildTrayPiece(int pieceIndex, bool isSelected, bool isHint) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? _marigold : (isHint ? _blueHint : Colors.transparent), width: isSelected || isHint ? 4 : 0),
        boxShadow: isSelected
            ? [BoxShadow(color: _marigold.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
            : isHint
            ? [BoxShadow(color: _blueHint.withValues(alpha: 0.6), blurRadius: 12, offset: const Offset(0, 4))]
            : const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: ImageSlice(imageUrl: _activeImage.url, cols: _cols, rows: _rows, sliceIndex: pieceIndex)),
    );
  }

  Widget _buildStaticPiece(int pieceIndex) {
    return ImageSlice(imageUrl: _activeImage.url, cols: _cols, rows: _rows, sliceIndex: pieceIndex);
  }

  Widget _buildDraggedPiece(int pieceIndex) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 8))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: ImageSlice(imageUrl: _activeImage.url, cols: _cols, rows: _rows, sliceIndex: pieceIndex)),
    );
  }
}

class ImageSlice extends StatelessWidget {
  final String imageUrl;
  final int cols;
  final int rows;
  final int sliceIndex;
  const ImageSlice({super.key, required this.imageUrl, required this.cols, required this.rows, required this.sliceIndex});

  @override
  Widget build(BuildContext context) {
    final int origRow = sliceIndex ~/ cols;
    final int origCol = sliceIndex % cols;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileW = constraints.maxWidth;
        final double tileH = constraints.maxHeight;
        final double imageW = tileW * cols;
        final double imageH = tileH * rows;
        final double offsetX = origCol * tileW;
        final double offsetY = origRow * tileH;
        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: -offsetX,
                top: -offsetY,
                width: imageW,
                height: imageH,
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}