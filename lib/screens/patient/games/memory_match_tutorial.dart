import 'package:flutter/material.dart';

class MemoryMatchTutorialScreen extends StatefulWidget {
  const MemoryMatchTutorialScreen({super.key});

  @override
  State<MemoryMatchTutorialScreen> createState() => _MemoryMatchTutorialScreenState();
}

class _MemoryMatchTutorialScreenState extends State<MemoryMatchTutorialScreen> with SingleTickerProviderStateMixin {
  final Color _canvas = const Color(0xFFF3F6F0);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);
  final Color _greenTint = const Color(0xFFE3EDE5);
  final Color _marigold = const Color(0xFFD98A2B);
  final Color _marigoldTint = const Color(0xFFFBEEDA);
  final Color _white = const Color(0xFFFFFFFF);
  final Color _inkSoft = const Color(0xFF5B6A61);
  final Color _border = const Color(0xFFD8E2D9);

  // 4 Fixed Cards for Tutorial (2 Carrots, 2 Bananas) directly from local offline assets
  final List<Map<String, String>> _tutorialCards = const [
    {'name': 'Carrot', 'image': 'assets/memory_matching/fruits/carrot.jpg'},
    {'name': 'Banana', 'image': 'assets/memory_matching/fruits/banana.jpg'},
    {'name': 'Banana', 'image': 'assets/memory_matching/fruits/banana.jpg'},
    {'name': 'Carrot', 'image': 'assets/memory_matching/fruits/carrot.jpg'},
  ];

  final List<int> _sequence = [0, 3, 1, 2];
  int _currentStepIndex = 0;

  final List<int> _revealedIndices = [];
  String _guidanceText = "Step 1: Look at the highlighted card. Tap it to open.";
  String _footerTip = "Follow the hand indicator to learn how to play!";

  bool _showWelcomeDialog = true; // State for start tutorial popup

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resetTutorial() {
    setState(() {
      _currentStepIndex = 0;
      _revealedIndices.clear();
      _guidanceText = "Step 1: Look at the highlighted card. Tap it to open.";
      _footerTip = "Follow the hand indicator to learn how to play!";
      _showWelcomeDialog = false; // direct shuru karenge restart me
    });
  }

  void _handleCardTap(int idx) {
    if (_showWelcomeDialog || _currentStepIndex >= _sequence.length || _revealedIndices.contains(idx)) return;

    int expectedIndex = _sequence[_currentStepIndex];

    if (idx != expectedIndex) {
      setState(() {
        _guidanceText = "⚠️ Please tap the highlighted card with the spotlight.";
      });
      return;
    }

    setState(() {
      _revealedIndices.add(idx);
      _currentStepIndex++;

      if (_currentStepIndex == 1) {
        _guidanceText = "Step 2: Great! Now find its matching pair (the other Carrot). Tap it.";
      } else if (_currentStepIndex == 2) {
        _guidanceText = "Step 3: Now tap this Banana card.";
      } else if (_currentStepIndex == 3) {
        _guidanceText = "Step 4: Awesome! Tap the final matching Banana card to finish.";
      } else if (_currentStepIndex == 4) {
        _guidanceText = "🎉 Excellent! You have successfully learned how to play Memory Match!";
        _footerTip = "Tutorial finished. You can restart or exit.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = _currentStepIndex >= _sequence.length;

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
                    color: _white,
                    boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
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
                            'Memory Match',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _marigoldTint,
                          border: Border.all(color: _marigold, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '⭐ Interactive Tutorial',
                          style: TextStyle(color: Color(0xFF8A5A1C), fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Instruction Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _marigoldTint,
                      border: Border.all(color: _marigold, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        const Text('👆', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _guidanceText,
                            style: const TextStyle(
                              color: Color(0xFF7A5015),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 2x2 Fixed Cards Grid inside Board Container
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, idx) {
                        final card = _tutorialCards[idx];
                        final bool isRevealed = _revealedIndices.contains(idx);
                        final bool isTarget = !_showWelcomeDialog && !isCompleted && _sequence[_currentStepIndex] == idx;

                        return GestureDetector(
                          onTap: () => _handleCardTap(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isRevealed ? _white : _green,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isRevealed ? _marigold : (isTarget ? _marigold : _greenTint),
                                width: isTarget || isRevealed ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isTarget ? _marigold.withValues(alpha: 0.4) : _ink.withValues(alpha: 0.1),
                                  blurRadius: isTarget ? 14 : 6,
                                  spreadRadius: isTarget ? 3 : 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Center(
                                  child: isRevealed
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      card['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  )
                                      : const Text(
                                    '?',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isTarget)
                                  Positioned(
                                    bottom: -10,
                                    right: -10,
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: const Text(
                                        '👆',
                                        style: TextStyle(fontSize: 36),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // Footer Tip Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Text(
                    _footerTip,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: _inkSoft),
                  ),
                ),

                const SizedBox(height: 16),

                // Restart Actions (shown only if not completed)
                if (!isCompleted)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: _white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: _resetTutorial,
                            child: const Text('Restart Tutorial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isCompleted)
                  const SizedBox(height: 60),
              ],
            ),

            // WELCOME POPUP DIALOG
            if (_showWelcomeDialog)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🧠', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to Tutorial',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Learn how to find matching pairs step-by-step with guided hints.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _inkSoft, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
                          onPressed: () {
                            setState(() {
                              _showWelcomeDialog = false;
                            });
                          },
                          child: const Text('Start Tutorial', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // POST-TUTORIAL (FINAL COMPLETION POPUP)
            if (isCompleted)
              Container(
                color: Colors.black.withValues(alpha: 0.75),
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
                          "Remember the pictures and match all the pairs.",
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
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: _resetTutorial,
                            icon: const Icon(Icons.replay, size: 18),
                            label: const Text('Show me again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}