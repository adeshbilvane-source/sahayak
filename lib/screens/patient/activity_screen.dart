import 'package:flutter/material.dart';
import 'games/yoga.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  // Theme Colors
  final Color _canvas = const Color(0xFFF8FAF7);
  final Color _ink = const Color(0xFF24322A);
  final Color _green = const Color(0xFF3F6B4F);

  @override
  Widget build(BuildContext context) {
    // Poore Scaffold ko Container mein daal kar background image lagayi hai
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Agar aapki image .jpg hai, toh yahan .png ki jagah .jpg kar dena
          image: AssetImage('assets/1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        // Background ko transparent kiya taaki pichhe ki image dikhe
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // AppBar ko bhi transparent kiya
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: _ink), onPressed: () => Navigator.pop(context)),
            ),
          ),
          title: Text('Games', style: TextStyle(fontFamily: 'Fraunces', fontStyle: FontStyle.italic, fontWeight: FontWeight.w800, color: _ink, fontSize: 26)),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0, top: 10, bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 16, color: _green),
                    const SizedBox(width: 6),
                    Text('EN', style: TextStyle(color: _ink, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: _ink),
                  ],
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Games Section
              Text('GAMES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _green, letterSpacing: 1.2)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildImageCard('Picture game', 'Name what you see', 'assets/picture_identifier.png', () {
                      Navigator.pushNamed(context, '/identify_picture');
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child:_buildImageCard('Memory cards', 'Find two alike', 'assets/memory_game.png', () {
                      Navigator.pushNamed(context, '/memory_match');
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildImageCard('Jigsaw', 'Put the picture together', 'assets/jigsaw.png', () {
                      Navigator.pushNamed(context, '/jigsaw_puzzle');
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageCard('Sort buttons', 'Match shape and colour', 'assets/button_sort.png', () {
                      // Yahan seedhe game screen par navigate hoga
                      Navigator.pushNamed(context, '/game_button_sort');
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Wellness Section
              Text('WELLNESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _green, letterSpacing: 1.2)),
              const SizedBox(height: 16),

              _buildImageCard('Yoga & Rest', 'Gentle stretching and breathing', 'assets/yoga.png', () {
                // Yahan se direct aapka YogaPage open hoga
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const YogaPage()),
                );
              }, isLarge: true),

            ],
          ),
        ),

        // Floating Mic Button
        floatingActionButton: FloatingActionButton(
          backgroundColor: _green.withValues(alpha: 0.15),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () {},
          child: Icon(Icons.mic, color: _ink, size: 28),
        ),
      ),
    );
  }

  Widget _buildImageCard(String title, String subtitle, String imagePath, VoidCallback onTap, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 160 : 150,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) => debugPrint('Image not found: $imagePath'),
          ),
          boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.3, 1.0],
            ),
          ),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}