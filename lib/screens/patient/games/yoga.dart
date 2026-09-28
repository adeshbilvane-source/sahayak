import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// Models
class YogaStep {
  final int stepNumber;
  final String title;
  final String instruction;

  YogaStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
  });
}

class YogaPose {
  final String id;
  final String name;
  final String sanskrit;
  final String thumbnailPath;
  final String localVideoPath;
  final String description;
  final String benefits;
  final List<YogaStep> steps;

  YogaPose({
    required this.id,
    required this.name,
    required this.sanskrit,
    required this.thumbnailPath,
    required this.localVideoPath,
    required this.description,
    required this.benefits,
    required this.steps,
  });
}

// Total 10 Yoga Poses mapped with exact folder image filenames (.jpg)
final List<YogaPose> yogaPosesList = [
  YogaPose(
    id: 'tadasana',
    name: 'Mountain Pose',
    sanskrit: 'Tadasana',
    thumbnailPath: 'assets/yoga_images/tadasana.jpg',
    localVideoPath: 'assets/yoga_videos/tadasana.mp4',
    description: 'A steady, grounding standing posture that improves posture, balance, and quiet focus for seniors.',
    benefits: 'Improves posture, strengthens thighs and ankles, reduces flat feet symptoms.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Feet Alignment & Foundation', instruction: 'Stand tall with feet hip-width apart.'),
      YogaStep(stepNumber: 2, title: 'Lengthen Spine & Relax Arms', instruction: 'Let your arms hang comfortably by your sides.'),
    ],
  ),
  // 2. Vrikshasana (tree_pose.jpg)
  YogaPose(
    id: 'tree-pose',
    name: 'Supported Tree Pose',
    sanskrit: 'Vrikshasana',
    thumbnailPath: 'assets/yoga_images/tree_pose.jpg',
    localVideoPath: 'assets/yoga_videos/tree_pose.mp4',
    description: 'A gentle balance-building pose practiced with a wall or chair for safe, fall-free stability.',
    benefits: 'Enhances neuromuscular coordination, strengthens calves.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Steady Stand by Wall/Chair', instruction: 'Stand upright near a sturdy wall or chair.'),
      YogaStep(stepNumber: 2, title: 'Place Foot on Ankle', instruction: 'Place the sole of your foot against your ankle.'),
    ],
  ),
  // 3. Virabhadrasana I (virabhadrasana_i.jpg)
  YogaPose(
    id: 'virabhadrasana-i',
    name: 'Warrior I Pose',
    sanskrit: 'Virabhadrasana I',
    thumbnailPath: 'assets/yoga_images/virabhadrasana_i.jpg',
    localVideoPath: 'assets/yoga_videos/virabhadrasana_i.mp4',
    description: 'A powerful standing posture that builds stamina, strength, and focus.',
    benefits: 'Strengthens shoulders, arms, legs, back and ankles.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Stance Setup', instruction: 'Step feet wide apart, turn front foot out and bend front knee.'),
      YogaStep(stepNumber: 2, title: 'Reach Arms Up', instruction: 'Raise arms overhead and gaze gently upward.'),
    ],
  ),
  // 4. Bhujangasan (bhujangasan.jpg)
  YogaPose(
    id: 'bhujangasan',
    name: 'Cobra Pose',
    sanskrit: 'Bhujangasana',
    thumbnailPath: 'assets/yoga_images/bhujangasan.jpg',
    localVideoPath: 'assets/yoga_videos/bhujangasan.mp4',
    description: 'A prone backbend that stretches chest muscles and strengthens the spine.',
    benefits: 'Improves posture, strengthens the spine, and opens the chest.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Lie on Abdomen', instruction: 'Lie face down with palms flat under your shoulders.'),
      YogaStep(stepNumber: 2, title: 'Lift Chest', instruction: 'Inhale and gently lift your chest off the floor.'),
    ],
  ),
  // 5. Anjaneyasana (anjaneyasana.jpg)
  YogaPose(
    id: 'anjaneyasana',
    name: 'Low Lunge Pose',
    sanskrit: 'Anjaneyasana',
    thumbnailPath: 'assets/yoga_images/anjaneyasana.jpg',
    localVideoPath: 'assets/yoga_videos/anjaneyasana.mp4',
    description: 'A deep lunge stretch that opens hips and stretches thighs.',
    benefits: 'Stretches hips, thighs, and groins; builds core stability.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Kneeling Lunge', instruction: 'Step one foot forward into a lunge, back knee on floor.'),
      YogaStep(stepNumber: 2, title: 'Raise Arms', instruction: 'Inhale and sweep your arms up toward the sky.'),
    ],
  ),
  // 6. Paschimottanasana (paschimottanasana.jpg)
  YogaPose(
    id: 'paschimottanasana',
    name: 'Seated Forward Bend',
    sanskrit: 'Paschimottanasana',
    thumbnailPath: 'assets/yoga_images/paschimottanasana.jpg',
    localVideoPath: 'assets/yoga_videos/paschimottanasana.mp4',
    description: 'A calming stretch for the entire back body.',
    benefits: 'Calms the brain and helps relieve stress and mild depression.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Sit with Legs Extended', instruction: 'Sit tall with legs straight out in front.'),
      YogaStep(stepNumber: 2, title: 'Fold Forward', instruction: 'Hinge from hips and reach for your feet or shins.'),
    ],
  ),
  // 7. Adho Mukha Svanasana (adho_mukha_svanasana.jpg)
  YogaPose(
    id: 'adho-mukha-svanasana',
    name: 'Downward Facing Dog',
    sanskrit: 'Adho Mukha Svanasana',
    thumbnailPath: 'assets/yoga_images/adho_mukha_svanasana.jpg',
    localVideoPath: 'assets/yoga_videos/adho_mukha_svanasana.mp4',
    description: 'An energizing inversion that stretches shoulders, hamstrings, and calves.',
    benefits: 'Energizes the body, stretches shoulders, hamstrings, calves, and hands.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Tabletop Position', instruction: 'Start on hands and knees.'),
      YogaStep(stepNumber: 2, title: 'Lift Hips', instruction: 'Press into hands and lift hips up, forming an inverted V shape.'),
    ],
  ),
  // 8. Setu Bandhasana (setu_bandhasana.jpg)
  YogaPose(
    id: 'setu-bandhasana',
    name: 'Bridge Pose',
    sanskrit: 'Setu Bandhasana',
    thumbnailPath: 'assets/yoga_images/setu_bandhasana.jpg',
    localVideoPath: 'assets/yoga_videos/setu_bandhasana.mp4',
    description: 'A gentle backbend that opens the chest and stretches the neck and spine.',
    benefits: 'Strengthens glutes, back muscles, and improves blood circulation.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Lie on Back', instruction: 'Lie on your back with knees bent and feet flat on the floor.'),
      YogaStep(stepNumber: 2, title: 'Lift Hips Up', instruction: 'Press feet down and lift hips toward the ceiling.'),
    ],
  ),
  // 9. Supta Matsyendrasana (supta_matsyendrasana.jpg)
  YogaPose(
    id: 'supta-matsyendrasana',
    name: 'Supine Spinal Twist',
    sanskrit: 'Supta Matsyendrasana',
    thumbnailPath: 'assets/yoga_images/supta_matsyendrasana.jpg',
    localVideoPath: 'assets/yoga_videos/supta_matsyendrasana.mp4',
    description: 'A relaxing reclining twist that releases tension in the lower back and spine.',
    benefits: 'Relieves back tension, stretches glutes and spine, aids digestion.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Lie Down & Hug Knees', instruction: 'Lie on back, bring knees to chest.'),
      YogaStep(stepNumber: 2, title: 'Drop Knees to Side', instruction: 'Gently drop both knees to one side while looking opposite way.'),
    ],
  ),
  // 10. Baddha Konasana (baddha_konasana.jpg)
  YogaPose(
    id: 'baddha-konasana',
    name: 'Bound Angle Pose',
    sanskrit: 'Baddha Konasana',
    thumbnailPath: 'assets/yoga_images/baddha_konasana.jpg',
    localVideoPath: 'assets/yoga_videos/baddha_konasana.mp4',
    description: 'A seated posture that opens hips and inner thighs.',
    benefits: 'Stimulates abdominal organs, improves circulation, relieves fatigue.',
    steps: [
      YogaStep(stepNumber: 1, title: 'Soles Together', instruction: 'Sit tall, bend knees and bring soles of feet together.'),
      YogaStep(stepNumber: 2, title: 'Hold Feet & Relax Knees', instruction: 'Hold your feet with hands and gently let knees drop toward floor.'),
    ],
  ),
];

class YogaPage extends StatefulWidget {
  const YogaPage({super.key});

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  late YogaPose selectedPose;
  bool showDetailView = false;
  bool isGuiding = false;
  int currentStepIdx = 0;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  final Color canvasColor = const Color(0xFFF3F6F0);
  final Color inkColor = const Color(0xFF24322A);
  final Color inkSoft = const Color(0xFF5B6A61);
  final Color purpleColor = const Color(0xFF6B4E9B);
  final Color purpleTint = const Color(0xFFEFE9F6);
  final Color greenTint = const Color(0xFFE3EDE5);

  @override
  void initState() {
    super.initState();
    selectedPose = yogaPosesList[0];
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo(String assetPath) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.asset(assetPath)
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _isPlaying = true;
          _showControls = true;
        });
        _videoController?.setLooping(true);
        _videoController?.play();
        _startHideControlsTimer();
      }).catchError((error) {
        debugPrint("Video load error: $error");
      });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
        _showControls = true;
        _hideControlsTimer?.cancel();
      } else {
        _videoController!.play();
        _isPlaying = true;
        _startHideControlsTimer();
      }
    });
  }

  void _onVideoTap() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _isPlaying) {
      _startHideControlsTimer();
    }
  }

  Future<void> saveYogaSessionToAnalytics(int mins) async {
    final prefs = await SharedPreferences.getInstance();
    int totalMins = prefs.getInt('yoga_total_minutes') ?? 0;
    int totalSessions = prefs.getInt('yoga_total_sessions') ?? 0;
    await prefs.setInt('yoga_total_minutes', totalMins + mins);
    await prefs.setInt('yoga_total_sessions', totalSessions + 1);
  }

  void handleStartSession() {
    setState(() {
      currentStepIdx = 0;
      isGuiding = true;
    });
    _initializeVideo(selectedPose.localVideoPath);
  }

  void handleStopSession() {
    _hideControlsTimer?.cancel();
    _videoController?.pause();
    setState(() {
      isGuiding = false;
      currentStepIdx = 0;
      _isPlaying = false;
      _showControls = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: greenTint, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back, color: Color(0xFF3F6B4F), size: 18),
            ),
            onPressed: () {
              handleStopSession();
              if (showDetailView) {
                setState(() => showDetailView = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Text(
          'Yoga Asanas ',
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: inkColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showDetailView) ...[
                  Text(
                    'Select a pose to view step-by-step guidance & videos:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: inkSoft),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: yogaPosesList.length,
                    itemBuilder: (context, index) {
                      final pose = yogaPosesList[index];
                      final isSelected = selectedPose.id == pose.id;
                      return GestureDetector(
                        onTap: () {
                          handleStopSession();
                          setState(() {
                            selectedPose = pose;
                            showDetailView = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? purpleColor : Colors.transparent, width: 2.5),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                  child: Image.asset(
                                    pose.thumbnailPath,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pose.name,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: inkColor),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ] else if (isGuiding) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: purpleTint, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: purpleTint, borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text(
                            'Step ${selectedPose.steps[currentStepIdx].stepNumber} of ${selectedPose.steps.length}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: purpleColor),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Video Player with Tap-to-Toggle and Auto-Hide Play Button
                        GestureDetector(
                          onTap: _onVideoTap,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: _isVideoInitialized && _videoController != null
                                      ? AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                      : const Center(child: CircularProgressIndicator()),
                                ),
                              ),
                              if (_isVideoInitialized)
                                AnimatedOpacity(
                                  opacity: _showControls ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: GestureDetector(
                                    onTap: _togglePlayPause,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: canvasColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border(left: BorderSide(color: purpleColor, width: 4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selectedPose.steps[currentStepIdx].title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: inkColor)),
                              const SizedBox(height: 4),
                              Text(selectedPose.steps[currentStepIdx].instruction, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: inkSoft)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purpleColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  if (currentStepIdx < selectedPose.steps.length - 1) {
                                    setState(() {
                                      currentStepIdx++;
                                    });
                                  } else {
                                    handleStopSession();
                                    saveYogaSessionToAnalytics(1);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('🎉 Session complete! Logged to your daily health report.')),
                                    );
                                  }
                                },
                                child: Text(
                                  currentStepIdx < selectedPose.steps.length - 1 ? 'Next Step ➔' : 'Finish Session ✅',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: handleStopSession,
                                child: Text('End', style: TextStyle(color: inkColor, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            selectedPose.thumbnailPath,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                selectedPose.name,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: inkColor,
                                ),
                              ),
                              Text('(${selectedPose.sanskrit})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: purpleColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: canvasColor, borderRadius: BorderRadius.circular(14)),
                          child: Text(selectedPose.description, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: inkSoft)),
                        ),
                        const SizedBox(height: 12),
                        Text('🌿 Key Benefits: ${selectedPose.benefits}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: inkColor)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: handleStartSession,
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text(
                              'Start guided session',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}