import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'jigsaw_puzzle.dart';

class JigsawTutorialOverlay extends StatefulWidget {
  final String imageUrl;
  final int cols;
  final int rows;
  final VoidCallback onComplete;

  const JigsawTutorialOverlay({
    super.key,
    required this.imageUrl,
    required this.cols,
    required this.rows,
    required this.onComplete
  });

  @override
  State<JigsawTutorialOverlay> createState() => _JigsawTutorialOverlayState();
}

class _JigsawTutorialOverlayState extends State<JigsawTutorialOverlay> with TickerProviderStateMixin {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldHover = const Color(0xFFBD7620);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _border = const Color(0xFFD8E2D9);
  final Color _white = const Color(0xFFFFFFFF);
  final Color _scrim = const Color(0xFF24322A).withValues(alpha: 0.6);

  int _stepIndex = 0;
  bool _isCalculated = false;

  final GlobalKey _trayPieceKey = GlobalKey();
  final GlobalKey _targetSlotKey = GlobalKey();

  Rect _trayPieceRect = Rect.zero;
  Rect _targetSlotRect = Rect.zero;

  late AnimationController _waveController;
  late AnimationController _dragController;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _dragController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRects();
    });
  }

  void _calculateRects() {
    if (!mounted) return;
    _trayPieceRect = _getRect(_trayPieceKey);
    _targetSlotRect = _getRect(_targetSlotKey);
    setState(() {
      _isCalculated = true;
    });
  }

  Rect _getRect(GlobalKey key) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    final Offset position = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(position.dx, position.dy, box.size.width, box.size.height);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dragController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_stepIndex == 0) {
      setState(() => _stepIndex = 1);
    } else if (_stepIndex == 1) {
      setState(() => _stepIndex = 2);
      _playDragDemo();
    }
  }

  void _playDragDemo() async {
    await _dragController.forward(from: 0.0);
    _rippleController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _stepIndex = 3);
    }
  }

  void _replay() {
    setState(() {
      _stepIndex = 0;
      _dragController.reset();
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          // 1. FAKED GAME UI
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: _greenTint, borderRadius: BorderRadius.circular(11)),
                        child: Icon(Icons.arrow_back_ios_new, size: 16, color: _green),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Jigsaw Puzzle',
                        style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Faked Board Grid
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: _white,
                    border: Border.all(color: _border, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildBoardSlot(isTarget: true),
                            _buildBoardSlot(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildBoardSlot(),
                            _buildBoardSlot(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text('Pick a piece from the tray below:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 20),

                // Faked Tray
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTrayPiece(isTarget: true, sliceIndex: 0),
                      _buildTrayPiece(sliceIndex: 1),
                      _buildTrayPiece(sliceIndex: 2),
                    ],
                  ),
                )
              ],
            ),
          ),

          // 2. SCRIM & SPOTLIGHT
          if (_isCalculated && _stepIndex < 3)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              top: _stepIndex == 0 ? _trayPieceRect.top - 8 : _targetSlotRect.top - 6,
              left: _stepIndex == 0 ? _trayPieceRect.left - 8 : _targetSlotRect.left - 6,
              width: _stepIndex == 0 ? _trayPieceRect.width + 16 : _targetSlotRect.width + 12,
              height: _stepIndex == 0 ? _trayPieceRect.height + 16 : _targetSlotRect.height + 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: _scrim, blurRadius: 0, spreadRadius: 9999),
                    ],
                  ),
                ),
              ),
            ),

          // 3. CALLOUT BOX
          if (_isCalculated && _stepIndex < 2)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              top: _stepIndex == 0 ? _trayPieceRect.top - 140 : _targetSlotRect.bottom + 20,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: _marigoldHover, shape: BoxShape.circle),
                            child: const Icon(Icons.volume_up, size: 10, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          _buildAnimatedWave(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stepIndex == 0 ? "Pick a puzzle piece from the tray." : "Drag it to the matching empty spot.",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ink, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildDot(_stepIndex == 0),
                              const SizedBox(width: 5),
                              _buildDot(_stepIndex == 1),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _nextStep,
                            child: Text(_stepIndex == 0 ? 'Next →' : 'Watch →', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

          // 4. ANIMATED DRAG & RIPPLE
          if (_isCalculated && _stepIndex == 2)
            AnimatedBuilder(
              animation: _dragController,
              builder: (context, child) {
                final startTop = _trayPieceRect.top;
                final endTop = _targetSlotRect.top + (_targetSlotRect.height / 2) - 40;
                final startLeft = _trayPieceRect.left;
                final endLeft = _targetSlotRect.left + (_targetSlotRect.width / 2) - 40;

                double moveAnim = const Interval(0.0, 0.7, curve: Curves.easeInOut).transform(_dragController.value);
                double currentTop = startTop + ((endTop - startTop) * moveAnim);
                double currentLeft = startLeft + ((endLeft - startLeft) * moveAnim);

                double scaleAnim = 1.0;
                if (_dragController.value > 0.0 && _dragController.value < 0.2) {
                  scaleAnim = 1.1;
                }

                double opacity = 1.0;
                if (_dragController.value > 0.8) opacity = (1.0 - _dragController.value) * 5;

                return Positioned(
                  top: currentTop,
                  left: currentLeft,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (_dragController.value >= 0.7)
                          Positioned(
                            top: -10, left: -10, bottom: -10, right: -10,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeOut)),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_rippleController),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _green, width: 3),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: scaleAnim,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                                color: _white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 8))]
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ImageSlice(imageUrl: widget.imageUrl, cols: widget.cols, rows: widget.rows, sliceIndex: 0)
                            ),
                          ),
                        ),
                        // Hand Indicator
                        Positioned(
                          top: 50, left: 50,
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: _marigoldHover.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: _marigoldHover, width: 2),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

          // 5. POST-TUTORIAL (POPUP SHOWN HERE)
          if (_stepIndex == 3)
            Container(
              color: Colors.black.withValues(alpha: 0.75), // Dark background
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF3F6B4F), size: 60),
                      const SizedBox(height: 16),
                      Text("You're ready!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _green)),
                      const SizedBox(height: 8),
                      Text(
                        "Match the pieces from the tray to complete the picture.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _inkSoft, height: 1.4),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: _white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: widget.onComplete,
                          child: const Text("Let's Play!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _ink,
                            side: BorderSide(color: _border, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _replay,
                          icon: const Icon(Icons.replay, size: 18),
                          label: const Text('Show me again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_stepIndex < 3)
            Positioned(
              top: 52, right: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child:  Text(
                  'Skip tutorial',
                  style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoardSlot({bool isTarget = false}) {
    return Expanded(
      child: Container(
        key: isTarget ? _targetSlotKey : null,
        decoration: BoxDecoration(
          border: Border.all(color: _border, width: 1.5),
          color: _canvas,
        ),
        child: Center(child: Icon(Icons.add, color: _border, size: 30)),
      ),
    );
  }

  Widget _buildTrayPiece({bool isTarget = false, int sliceIndex = 0}) {
    return Container(
      key: isTarget ? _trayPieceKey : null,
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImageSlice(imageUrl: widget.imageUrl, cols: widget.cols, rows: widget.rows, sliceIndex: sliceIndex)
      ),
    );
  }

  Widget _buildAnimatedWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        double v = math.sin(_waveController.value * 2 * math.pi);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _waveBar(v, 0),
            _waveBar(v, 0.3),
            _waveBar(v, 0.6),
          ],
        );
      },
    );
  }

  Widget _waveBar(double animValue, double delayOffset) {
    double heightModifier = math.sin((_waveController.value + delayOffset) * 2 * math.pi).abs();
    return Container(
      margin: const EdgeInsets.only(right: 2),
      width: 2.5,
      height: 3.0 + (7.0 * heightModifier),
      decoration: BoxDecoration(color: _marigoldHover, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(color: isActive ? _green : _border, shape: BoxShape.circle),
    );
  }
}