import 'package:flutter/material.dart';
import 'dart:math' as math;

class ButtonSortingTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ButtonSortingTutorialOverlay({super.key, required this.onComplete});

  @override
  State<ButtonSortingTutorialOverlay> createState() => _ButtonSortingTutorialOverlayState();
}

class _ButtonSortingTutorialOverlayState extends State<ButtonSortingTutorialOverlay> with TickerProviderStateMixin {
  // Theme Colors (Matches Actual Game)
  final Color _canvas = const Color(0xFFF8FAF7);
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
  // 0: Callout on Pool
  // 1: Animating Tap on Pool
  // 2: Callout on Bin
  // 3: Animating Tap on Bin
  // 4: Done Popup

  bool _isCalculated = false;
  bool _isButtonSelected = false;
  bool _isButtonSorted = false;

  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _binKey = GlobalKey();

  Rect _buttonRect = Rect.zero;
  Rect _binRect = Rect.zero;

  late AnimationController _waveController;
  late AnimationController _tap1Controller;
  late AnimationController _tap2Controller;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _tap1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _tap2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRects();
    });
  }

  void _calculateRects() {
    if (!mounted) return;
    _buttonRect = _getRect(_buttonKey);
    _binRect = _getRect(_binKey);
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
    _tap1Controller.dispose();
    _tap2Controller.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_stepIndex == 0) {
      setState(() => _stepIndex = 1);
      _playTap1();
    } else if (_stepIndex == 2) {
      setState(() => _stepIndex = 3);
      _playTap2();
    }
  }

  void _playTap1() async {
    await _tap1Controller.forward(from: 0.0);
    _rippleController.forward(from: 0.0);
    setState(() {
      _isButtonSelected = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _stepIndex = 2);
    }
  }

  void _playTap2() async {
    await _tap2Controller.forward(from: 0.0);
    _rippleController.forward(from: 0.0);
    setState(() {
      _isButtonSorted = true;
      _isButtonSelected = false;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _stepIndex = 4);
    }
  }

  void _replay() {
    setState(() {
      _stepIndex = 0;
      _isButtonSelected = false;
      _isButtonSorted = false;
      _tap1Controller.reset();
      _tap2Controller.reset();
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    Rect currentTargetRect = (_stepIndex < 2) ? _buttonRect : _binRect;

    return Scaffold(
      backgroundColor: _canvas,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { if (_stepIndex == 4) widget.onComplete(); },
        onPanDown: (_) { if (_stepIndex == 4) widget.onComplete(); },
        child: Stack(
          children: [
            // 1. FAKED UI (Matches Actual Game Design)
            SafeArea(
              child: Column(
                children: [
                  // Top Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(
                      children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: _greenTint, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.arrow_back_ios_new, size: 16, color: _green)),
                        const SizedBox(width: 10),
                        Text('Button Sorting', style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 19, color: _ink)),
                      ],
                    ),
                  ),

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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('By Shape', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _greenTint, width: 1.5), borderRadius: BorderRadius.circular(20)),
                                  child: Text('By Colour', style: TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 14)),
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
                              color: Colors.white, borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: _greenTint, width: 2),
                              boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Wrap(
                              spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
                              children: [
                                // The Target Button
                                if (!_isButtonSorted)
                                  Container(
                                    key: _buttonKey,
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB33F33), // Red
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _isButtonSelected ? _ink : Colors.transparent, width: 3),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: _isButtonSelected ? 0.25 : 0.15), blurRadius: _isButtonSelected ? 8 : 4, offset: Offset(0, _isButtonSelected ? 4 : 2))],
                                    ),
                                  ),

                                // Distractor Buttons
                                Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFF3E7FB8), shape: BoxShape.circle)), // Blue Round
                                Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFD98A2B), borderRadius: BorderRadius.circular(14))), // Orange Square
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Target Bins
                          Row(
                            children: [
                              // Round Bin (Target)
                              Expanded(
                                child: Container(
                                  key: _binKey,
                                  constraints: const BoxConstraints(minHeight: 160),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _green, width: 3.0)),
                                  child: Column(
                                    children: [
                                      Text('Round (${_isButtonSorted ? 1 : 0})', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: _ink, fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 16),
                                      if (_isButtonSorted)
                                        Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFB33F33), shape: BoxShape.circle)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Square Bin
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 160),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _green, width: 3.0)),
                                  child: Column(
                                    children: [
                                      Text('Square (0)', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: _ink, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. SCRIM & SPOTLIGHT
            if (_isCalculated && _stepIndex < 4)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                top: currentTargetRect.top - 8,
                left: currentTargetRect.left - 8,
                width: currentTargetRect.width + 16,
                height: currentTargetRect.height + 16,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _scrim, blurRadius: 0, spreadRadius: 9999)],
                    ),
                  ),
                ),
              ),

            // 3. CALLOUT BOX
            if (_isCalculated && (_stepIndex == 0 || _stepIndex == 2))
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                top: _stepIndex == 0 ? _buttonRect.bottom + 15 : _binRect.bottom + 15,
                left: 20,
                child: IgnorePointer(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: _marigoldHover, shape: BoxShape.circle), child: const Icon(Icons.volume_up, size: 10, color: Colors.white)),
                              const SizedBox(width: 6),
                              _buildAnimatedWave(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stepIndex == 0 ? "Step 1: Tap a button to select it." : "Step 2: Now tap the matching bin to place it.",
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
                                  _buildDot(_stepIndex == 2),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(10)),
                                child: Text('Watch →', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 4. ANIMATED FINGER TAPS
            if (_isCalculated && (_stepIndex == 1 || _stepIndex == 3))
              AnimatedBuilder(
                animation: _stepIndex == 1 ? _tap1Controller : _tap2Controller,
                builder: (context, child) {
                  double moveAnim = const Interval(0.0, 0.4, curve: Curves.easeInOut).transform(_stepIndex == 1 ? _tap1Controller.value : _tap2Controller.value);

                  final startTop = currentTargetRect.top + 60;
                  final endTop = currentTargetRect.top + (currentTargetRect.height / 2) - 10;
                  final startLeft = currentTargetRect.left + 50;
                  final endLeft = currentTargetRect.left + (currentTargetRect.width / 2) - 10;

                  double currentTop = startTop + ((endTop - startTop) * moveAnim);
                  double currentLeft = startLeft + ((endLeft - startLeft) * moveAnim);

                  double val = _stepIndex == 1 ? _tap1Controller.value : _tap2Controller.value;
                  double scaleAnim = 1.0;
                  if (val > 0.4 && val < 0.6) scaleAnim = 0.75;

                  double opacity = 1.0;
                  if (val > 0.8) opacity = (1.0 - val) * 5;

                  return Positioned(
                    top: currentTop,
                    left: currentLeft,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (val >= 0.4)
                            Positioned(
                              top: -10, left: -10, right: -10, bottom: -10,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 1.0, end: 1.8).animate(_rippleController),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_rippleController),
                                  child: Container(decoration: BoxDecoration(border: Border.all(color: _green, width: 3), shape: BoxShape.circle)),
                                ),
                              ),
                            ),
                          // Fingertip
                          Transform.scale(
                            scale: scaleAnim,
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: _marigoldHover.withValues(alpha: 0.35), shape: BoxShape.circle, border: Border.all(color: _marigoldHover, width: 2.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // 5. POST-TUTORIAL (FINAL POPUP)
            if (_stepIndex == 4)
              Container(
                color: Colors.black.withValues(alpha: 0.75),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF3F6B4F), size: 60),
                        const SizedBox(height: 16),
                        Text("You're ready!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _green)),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to select a button, then tap the matching bin to sort it.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _inkSoft, height: 1.4),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green, foregroundColor: _white, padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
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
                              foregroundColor: _ink, side: BorderSide(color: _border, width: 2), padding: const EdgeInsets.symmetric(vertical: 12),
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

            // INVISIBLE TRIGGER TO GO TO NEXT STEP
            if (_stepIndex == 0 || _stepIndex == 2)
              Positioned(
                top: _stepIndex == 0 ? _buttonRect.bottom + 15 : _binRect.bottom + 15,
                left: 20,
                child: GestureDetector(
                  onTap: _nextStep,
                  child: Container(width: 260, height: 120, color: Colors.transparent),
                ),
              ),

            // SKIP BUTTON
            if (_stepIndex < 4)
              Positioned(top: 52, right: 20, child: GestureDetector(onTap: widget.onComplete, child: Text('Skip tutorial', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w800)))),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) => Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? _green : _border, shape: BoxShape.circle));

  Widget _buildAnimatedWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        double v = math.sin(_waveController.value * 2 * math.pi);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _waveBar(v, 0), _waveBar(v, 0.3), _waveBar(v, 0.6),
          ],
        );
      },
    );
  }

  Widget _waveBar(double animValue, double delayOffset) {
    double heightModifier = math.sin((_waveController.value + delayOffset) * 2 * math.pi).abs();
    return Container(
      margin: const EdgeInsets.only(right: 2), width: 2.5, height: 3.0 + (7.0 * heightModifier),
      decoration: BoxDecoration(color: _marigoldHover, borderRadius: BorderRadius.circular(2)),
    );
  }
}