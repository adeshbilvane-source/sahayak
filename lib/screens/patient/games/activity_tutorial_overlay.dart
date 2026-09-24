import 'package:flutter/material.dart';
import 'dart:math' as math;

class ActivityGameTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ActivityGameTutorialOverlay({super.key, required this.onComplete});

  @override
  State<ActivityGameTutorialOverlay> createState() => _ActivityGameTutorialOverlayState();
}

class _ActivityGameTutorialOverlayState extends State<ActivityGameTutorialOverlay> with TickerProviderStateMixin {
  // Theme Colors matching HTML
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

  int _stepIndex = 0; // 0: Photo, 1: Answers, 2: Animating Tap, 3: Done
  bool _isCalculated = false;

  final GlobalKey _photoKey = GlobalKey();
  final GlobalKey _answersKey = GlobalKey();
  final GlobalKey _targetAnswerKey = GlobalKey();

  Rect _photoRect = Rect.zero;
  Rect _answersRect = Rect.zero;
  Rect _targetAnswerRect = Rect.zero;

  late AnimationController _waveController;
  late AnimationController _tapController;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _tapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    // Calculate positions after the UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRects();
    });
  }

  void _calculateRects() {
    if (!mounted) return;
    _photoRect = _getRect(_photoKey);
    _answersRect = _getRect(_answersKey);
    _targetAnswerRect = _getRect(_targetAnswerKey);
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
    _tapController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_stepIndex == 0) {
      setState(() => _stepIndex = 1);
    } else if (_stepIndex == 1) {
      setState(() => _stepIndex = 2);
      _playTapDemo();
    }
  }

  void _playTapDemo() async {
    await _tapController.forward(from: 0.0);
    _rippleController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _stepIndex = 3);
    }
  }

  void _replay() {
    setState(() {
      _stepIndex = 0;
      _tapController.reset();
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          // 1. FAKED GAME UI (Matches the HTML exactly)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        'Identify the Picture',
                        style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                // Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      _buildChip('Random', isActive: true),
                      const SizedBox(width: 8),
                      _buildChip('Family photos'),
                      const SizedBox(width: 8),
                      _buildChip('My surroundings'),
                    ],
                  ),
                ),
                // Photo Target
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    key: _photoKey,
                    width: double.infinity,
                    height: 200, // Approximating 16/11 aspect ratio
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [Color(0xFF8fb3d9), Color(0xFFcfd8b8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=500&q=60',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (c,e,s) => const SizedBox(), // Fallback
                        ),
                        Positioned(
                          bottom: 10, left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFF24322A).withValues(alpha: 0.55), borderRadius: BorderRadius.circular(14)),
                            child: const Text('What is this?', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Answers Grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GridView.count(
                    key: _answersKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildAnswerBtn('Boat'),
                      _buildAnswerBtn('Airplane', isTarget: true), // The target key is attached inside this method
                      _buildAnswerBtn('Bicycle'),
                      _buildAnswerBtn('Train'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. SCRIM & SPOTLIGHT (Only if calculated and not done)
          if (_isCalculated && _stepIndex < 3)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              top: _stepIndex == 0 ? _photoRect.top - 8 : _answersRect.top - 6,
              left: _stepIndex == 0 ? _photoRect.left - 8 : _answersRect.left - 6,
              width: _stepIndex == 0 ? _photoRect.width + 16 : _answersRect.width + 12,
              height: _stepIndex == 0 ? _photoRect.height + 16 : _answersRect.height + 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: _scrim, blurRadius: 0, spreadRadius: 9999), // The massive shadow trick
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
              top: _stepIndex == 0 ? _photoRect.bottom + 14 : _answersRect.top - 130, // Below photo OR above answers
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
                      // Speaker & Wave
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
                        _stepIndex == 0 ? "This is today's picture." : "Tap the one that matches.",
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

          // 4. ANIMATED FINGER TAP & RIPPLE
          if (_isCalculated && _stepIndex == 2)
            AnimatedBuilder(
              animation: _tapController,
              builder: (context, child) {
                // Animate from Callout position to correct answer position
                final startTop = _answersRect.top - 100;
                final endTop = _targetAnswerRect.top + (_targetAnswerRect.height / 2) - 17;
                final startLeft = 60.0;
                final endLeft = _targetAnswerRect.left + (_targetAnswerRect.width / 2) - 17;

                // Move animation
                double moveAnim = const Interval(0.0, 0.4, curve: Curves.easeInOut).transform(_tapController.value);
                double currentTop = startTop + ((endTop - startTop) * moveAnim);
                double currentLeft = startLeft + ((endLeft - startLeft) * moveAnim);

                // Tap Scale Animation
                double scaleAnim = 1.0;
                if (_tapController.value > 0.4 && _tapController.value < 0.6) {
                  scaleAnim = 0.75; // Press down
                }

                // Opacity Animation
                double opacity = 1.0;
                if (_tapController.value < 0.1) opacity = _tapController.value * 10;
                if (_tapController.value > 0.8) opacity = (1.0 - _tapController.value) * 5;

                return Positioned(
                  top: currentTop,
                  left: currentLeft,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Ripple
                        if (_tapController.value >= 0.4)
                          Positioned(
                            top: -10, left: -10, bottom: -10, right: -10,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.8).animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeOut)),
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
                        // Fingertip
                        Transform.scale(
                          scale: scaleAnim,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: _marigoldHover.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                              border: Border.all(color: _marigoldHover, width: 2.5),
                            ),
                          ),
                        ),
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
                        "Tap the correct name for the picture shown.",
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

          // 6. SKIP LINK (Top Right)
          if (_stepIndex < 3)
            Positioned(
              top: 52, right: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child: const Text(
                  'Skip tutorial',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? _green : _white,
        border: Border.all(color: isActive ? _green : _border, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : _inkSoft,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAnswerBtn(String label, {bool isTarget = false}) {
    return Container(
      key: isTarget ? _targetAnswerKey : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _white,
        border: Border.all(color: _border, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildAnimatedWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        double v = math.sin(_waveController.value * 2 * math.pi); // Wave curve
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
    // Offset phase for each bar
    double heightModifier = math.sin((_waveController.value + delayOffset) * 2 * math.pi).abs();
    return Container(
      margin: const EdgeInsets.only(right: 2),
      width: 2.5,
      height: 3.0 + (7.0 * heightModifier), // Bounces between 3px and 10px
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