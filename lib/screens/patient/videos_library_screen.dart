import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Models
class LibraryPhoto {
  final String id;
  final String imageUrl;
  final String label;
  final String category;

  LibraryPhoto({required this.id, required this.imageUrl, required this.label, required this.category});

  Map<String, dynamic> toJson() => {'id': id, 'imageUrl': imageUrl, 'label': label, 'category': category};

  factory LibraryPhoto.fromJson(Map<String, dynamic> json) => LibraryPhoto(
    id: json['id'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    label: json['label'] ?? 'Unknown',
    category: json['category'] ?? 'family',
  );
}

class UploadedVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String duration;
  final String category;
  final String date;

  UploadedVideo({required this.id, required this.title, required this.videoUrl, required this.duration, required this.category, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'videoUrl': videoUrl, 'duration': duration, 'category': category, 'date': date};

  factory UploadedVideo.fromJson(Map<String, dynamic> json) => UploadedVideo(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Video',
    videoUrl: json['videoUrl'] ?? '',
    duration: json['duration'] ?? '0:45',
    category: json['category'] ?? 'Family',
    date: json['date'] ?? 'Today',
  );
}

class CalmingVideo {
  final String id;
  final String title;
  final String duration;
  final String category;
  final String youtubeId;
  final String thumbnail;

  CalmingVideo({required this.id, required this.title, required this.duration, required this.category, required this.youtubeId, required this.thumbnail});
}

final List<CalmingVideo> calmingYoutubeVideos = [
  CalmingVideo(
    id: 'yt-1',
    title: 'Enjoying Bad Weather & Heavy Rain Camping',
    duration: '16:47',
    category: 'Nature Calm',
    youtubeId: '6Ep3c8Cw2Ms',
    thumbnail: 'https://img.youtube.com/vi/6Ep3c8Cw2Ms/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-2',
    title: 'Camping in Heavy Rain & Thunderstorms ASMR',
    duration: '15:45',
    category: 'Nature Calm',
    youtubeId: 'zyOK2fdeXgQ',
    thumbnail: 'https://img.youtube.com/vi/zyOK2fdeXgQ/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-3',
    title: 'Bushcraft Shelter Camping Under Northern Lights',
    duration: '17:48',
    category: 'Nature Calm',
    youtubeId: 'MMSFmoNzQEE',
    thumbnail: 'https://img.youtube.com/vi/MMSFmoNzQEE/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-4',
    title: 'Solo Camping in Heavy Rain ASMR',
    duration: '19:43',
    category: 'Nature Calm',
    youtubeId: 'YGMRdLn2LAI',
    thumbnail: 'https://img.youtube.com/vi/YGMRdLn2LAI/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-5',
    title: 'Solo Car Camping in -18 Degrees',
    duration: '10:47',
    category: 'Nature Calm',
    youtubeId: 'WQneO40JPho',
    thumbnail: 'https://img.youtube.com/vi/WQneO40JPho/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-6',
    title: 'Into the Unknown | Primal Survivor',
    duration: '17:26',
    category: 'Nature Calm',
    youtubeId: '92Ttgaw6I-A',
    thumbnail: 'https://img.youtube.com/vi/92Ttgaw6I-A/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-7',
    title: '7 Minutes of The Cutest Baby Animals',
    duration: '07:06',
    category: 'Animals',
    youtubeId: 'hkBhJxZupeE',
    thumbnail: 'https://img.youtube.com/vi/hkBhJxZupeE/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-8',
    title: '8 Minutes of Baby Animals: Pure Joy',
    duration: '08:28',
    category: 'Animals',
    youtubeId: '3Rf0dIk_Eec',
    thumbnail: 'https://img.youtube.com/vi/3Rf0dIk_Eec/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-9',
    title: 'Cozy Tavern Recipes ASMR Cooking',
    duration: '21:25',
    category: 'Cooking Calm',
    youtubeId: '5BtA9ICV2DQ',
    thumbnail: 'https://img.youtube.com/vi/5BtA9ICV2DQ/hqdefault.jpg',
  ),
  CalmingVideo(
    id: 'yt-10',
    title: 'Village Foods Cooking in Village',
    duration: '16:01',
    category: 'Cooking Calm',
    youtubeId: '9Kf7wXcHJIs',
    thumbnail: 'https://img.youtube.com/vi/9Kf7wXcHJIs/hqdefault.jpg',
  ),
];

class VideosLibraryScreen extends StatefulWidget {
  const VideosLibraryScreen({super.key});

  @override
  State<VideosLibraryScreen> createState() => _VideosLibraryScreenState();
}

class _VideosLibraryScreenState extends State<VideosLibraryScreen> {
  final Color canvasColor = const Color(0xFFF3F6F0);
  final Color inkColor = const Color(0xFF24322A);
  final Color inkSoft = const Color(0xFF5B6A61);
  final Color greenColor = const Color(0xFF3F6B4F);
  final Color greenTint = const Color(0xFFE3EDE5);
  final Color redColor = const Color(0xFFB33F33);

  int currentTab = 0;
  int librarySubTab = 0;

  List<LibraryPhoto> libraryPhotos = [];
  List<UploadedVideo> userVideos = [];
  List<String> selectedPhotoIds = [];
  List<String> selectedVideoIds = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    final rawPhotos = prefs.getString('sahayak_library_photos');
    if (rawPhotos != null) {
      final List decoded = jsonDecode(rawPhotos);
      setState(() {
        libraryPhotos = decoded.map((e) => LibraryPhoto.fromJson(e)).toList();
      });
    } else {
      // DEFAULT PHOTOS HATA DI GAYI HAIN - Ab list khali rahegi
      setState(() => libraryPhotos = []);
    }

    final rawVideos = prefs.getString('sahayak_user_videos');
    if (rawVideos != null) {
      final List decoded = jsonDecode(rawVideos);
      setState(() {
        userVideos = decoded.map((e) => UploadedVideo.fromJson(e)).toList();
      });
    }
  }

  Future<void> _pickAndUploadVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        _showSaveVideoModal(video.path, video.name);
      }
    } catch (e) {
      debugPrint("Video pick error: $e");
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        _showPhotoConfigDialog(image.path);
      }
    } catch (e) {
      debugPrint("Photo pick error: $e");
    }
  }

  void _showPhotoConfigDialog(String imagePath) {
    String selectedCategory = 'family';
    String selectedItem = 'Father';
    final TextEditingController customController = TextEditingController();
    bool isCustom = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final List<String> currentOptions = selectedCategory == 'family'
              ? ['Father', 'Mother', 'Sister', 'Brother', 'Son', 'Daughter', 'Grandson', 'Grand Daughter', 'Grand Father', 'Grand Mother', 'Custom']
              : ['Living Room', 'Kitchen', 'Bedroom', 'Balcony', 'Garden', 'Temple Area', 'Main Door', 'Custom'];

          if (!currentOptions.contains(selectedItem)) {
            selectedItem = currentOptions.first;
          }

          return AlertDialog(
            title: const Text('Configure Photo Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSmartImage(imagePath, height: 110, width: double.infinity),
                  const SizedBox(height: 12),
                  const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'family', child: Text('Family')),
                      DropdownMenuItem(value: 'surroundings', child: Text('Surroundings')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                          selectedItem = selectedCategory == 'family' ? 'Father' : 'Living Room';
                          isCustom = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(selectedCategory == 'family' ? 'Select Relation:' : 'Select Location:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedItem,
                    items: currentOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedItem = val;
                          isCustom = val == 'Custom';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customController,
                      decoration: InputDecoration(
                        labelText: 'Enter Custom Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: greenColor),
                onPressed: () async {
                  String finalLabel = '';
                  if (isCustom) {
                    finalLabel = customController.text.trim();
                  } else {
                    finalLabel = selectedItem;
                  }
                  if (finalLabel.isEmpty) {
                    finalLabel = selectedCategory == 'family' ? 'Family Member' : 'Surroundings';
                  }

                  Navigator.pop(ctx);
                  await _savePhotoToPermanentStorage(imagePath, finalLabel, selectedCategory);
                },
                child: const Text('Save Photo', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSaveVideoModal(String path, String fileName) {
    String title = fileName.split('.').first;
    String category = 'Family';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Video to Library'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: title),
              onChanged: (val) => title = val,
              decoration: const InputDecoration(labelText: 'Video Title'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: greenColor),
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveVideoToPermanentStorage(path, title, category);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _savePhotoToPermanentStorage(String tempPath, String label, String category) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      String folderName = category == 'family' ? 'family' : 'surrounding';
      final Directory targetDir = Directory('${appDir.path}/data/$folderName');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String permanentPath = '${targetDir.path}/$fileName';

      await File(tempPath).copy(permanentPath);

      final newPhoto = LibraryPhoto(
        id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
        imageUrl: permanentPath,
        label: label,
        category: category,
      );

      final updated = [...libraryPhotos, newPhoto];
      if (mounted) {
        setState(() => libraryPhotos = updated);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sahayak_library_photos', jsonEncode(updated.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving photo permanently: $e");
    }
  }

  Future<void> _saveVideoToPermanentStorage(String tempPath, String title, String category) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      final Directory targetDir = Directory('${appDir.path}/data/videos');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String permanentPath = '${targetDir.path}/$fileName';

      await File(tempPath).copy(permanentPath);

      final newVid = UploadedVideo(
        id: 'uvid-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        videoUrl: permanentPath,
        duration: '0:45',
        category: category,
        date: 'Today',
      );

      final updated = [newVid, ...userVideos];
      if (mounted) {
        setState(() => userVideos = updated);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sahayak_user_videos', jsonEncode(updated.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving video permanently: $e");
    }
  }

  Widget _buildSmartImage(String path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Image.file(
        File(path),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }

  void _playVideo(UploadedVideo video) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: FullScreenVideoPlayer(videoPath: video.videoUrl, title: video.title),
      ),
    );
  }

  void _playYouTubeVideo(String youtubeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenYoutubePlayer(youtubeId: youtubeId),
      ),
    );
  }

  void _viewPhoto(LibraryPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Center(
                child: _buildSmartImage(photo.imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black54,
                child: Text(photo.label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoOptionsDialog(UploadedVideo video) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Play Video'),
              onTap: () {
                Navigator.pop(context);
                _playVideo(video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Rename Video'),
              onTap: () {
                Navigator.pop(context);
                _showRenameVideoDialog(video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Video'),
              onTap: () {
                Navigator.pop(context);
                _deleteVideo(video.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameVideoDialog(UploadedVideo video) {
    final TextEditingController nameController = TextEditingController(text: video.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Video'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'New Video Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: greenColor),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  userVideos = userVideos.map((v) {
                    if (v.id == video.id) {
                      return UploadedVideo(
                        id: v.id,
                        title: nameController.text.trim(),
                        videoUrl: v.videoUrl,
                        duration: v.duration,
                        category: v.category,
                        date: v.date,
                      );
                    }
                    return v;
                  }).toList();
                });
                final navigator = Navigator.of(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('sahayak_user_videos', jsonEncode(userVideos.map((e) => e.toJson()).toList()));
                if (mounted) navigator.pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteVideo(String id) async {
    setState(() {
      userVideos.removeWhere((v) => v.id == id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sahayak_user_videos', jsonEncode(userVideos.map((e) => e.toJson()).toList()));
  }

  void _showPhotoOptionsDialog(LibraryPhoto photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.green),
              title: const Text('View Photo'),
              onTap: () {
                Navigator.pop(context);
                _viewPhoto(photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Rename Photo Label'),
              onTap: () {
                Navigator.pop(context);
                _showRenamePhotoDialog(photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo'),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(photo.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenamePhotoDialog(LibraryPhoto photo) {
    final TextEditingController nameController = TextEditingController(text: photo.label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Photo'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'New Photo Label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: greenColor),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  libraryPhotos = libraryPhotos.map((p) {
                    if (p.id == photo.id) {
                      return LibraryPhoto(
                        id: p.id,
                        imageUrl: p.imageUrl,
                        label: nameController.text.trim(),
                        category: p.category,
                      );
                    }
                    return p;
                  }).toList();
                });
                final navigator = Navigator.of(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('sahayak_library_photos', jsonEncode(libraryPhotos.map((e) => e.toJson()).toList()));
                if (mounted) navigator.pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deletePhoto(String id) async {
    setState(() {
      libraryPhotos.removeWhere((p) => p.id == id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sahayak_library_photos', jsonEncode(libraryPhotos.map((e) => e.toJson()).toList()));
  }

  void _showMediaSourceSheet(bool isVideo) {
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
                if (isVideo) {
                  _pickAndUploadVideo(ImageSource.camera);
                } else {
                  _pickAndUploadPhoto(ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                if (isVideo) {
                  _pickAndUploadVideo(ImageSource.gallery);
                } else {
                  _pickAndUploadPhoto(ImageSource.gallery);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: greenColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Videos & Library', style: TextStyle(color: inkColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: currentTab == 0 ? greenColor : greenTint),
                      onPressed: () => setState(() => currentTab = 0),
                      child: Text('Videos', style: TextStyle(color: currentTab == 0 ? Colors.white : greenColor)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: currentTab == 1 ? greenColor : greenTint),
                      onPressed: () => setState(() => currentTab = 1),
                      child: Text('Library', style: TextStyle(color: currentTab == 1 ? Colors.white : greenColor)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: currentTab == 0 ? _buildVideosTab() : _buildLibraryTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('User Uploaded Videos', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _showMediaSourceSheet(true),
              child: Text('Add Video +', style: TextStyle(color: greenColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        userVideos.isEmpty
            ? const Text('No custom videos added yet.')
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2),
          itemCount: userVideos.length,
          itemBuilder: (context, index) {
            final vid = userVideos[index];
            return GestureDetector(
              onTap: () => _playVideo(vid),
              onLongPress: () => _showVideoOptionsDialog(vid),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_fill, size: 40, color: Colors.green),
                    const SizedBox(height: 8),
                    Text(vid.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('Calming & Therapy Videos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1),
          itemCount: calmingYoutubeVideos.length,
          itemBuilder: (context, index) {
            final yt = calmingYoutubeVideos[index];
            return GestureDetector(
              onTap: () => _playYouTubeVideo(yt.youtubeId),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            yt.thumbnail,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => const Icon(Icons.video_library, size: 40, color: Colors.grey),
                          ),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(yt.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLibraryTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: greenColor, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('All Photos (${libraryPhotos.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: libraryPhotos.isEmpty
              ? const Center(
              child: Text('No photos added yet.\nUse the + button to add.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
          )
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: libraryPhotos.length,
            itemBuilder: (context, index) {
              final photo = libraryPhotos[index];
              return GestureDetector(
                onTap: () => _viewPhoto(photo),
                onLongPress: () => _showPhotoOptionsDialog(photo),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildSmartImage(photo.imageUrl),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${photo.label} (${photo.category == 'family' ? 'Family' : 'Surroundings'})', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- FULL SCREEN LOCAL VIDEO PLAYER WIDGET ---
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String title;
  const FullScreenVideoPlayer({super.key, required this.videoPath, required this.title});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.startsWith('http://') || widget.videoPath.startsWith('https://')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller.play();
      }
    }).catchError((e) {
      debugPrint("Video play error: $e");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        AspectRatio(
          aspectRatio: _isInitialized ? _controller.value.aspectRatio : 16 / 9,
          child: _isInitialized
              ? VideoPlayer(_controller)
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// --- UPDATED FULL SCREEN YOUTUBE PLAYER WIDGET ---
class FullScreenYoutubePlayer extends StatefulWidget {
  final String youtubeId;
  const FullScreenYoutubePlayer({super.key, required this.youtubeId});

  @override
  State<FullScreenYoutubePlayer> createState() => _FullScreenYoutubePlayerState();
}

class _FullScreenYoutubePlayerState extends State<FullScreenYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    // Vapas vertical set karta hai close karne ke baad
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: player,
        ),
      ),
    );
  }
}