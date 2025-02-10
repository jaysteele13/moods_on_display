
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/emotion_image.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:extended_image/extended_image.dart';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => AddImageScreenState();
}

class AddImageScreenState extends State<AddImageScreen> {
  final ImageManager _imageManager = ImageManager();
  final ModelManager _modelManager = ModelManager();
  final ValueNotifier<bool> isPerFace = ValueNotifier<bool>(false); // Toggle state

  bool _isGalleryLoading = false;
  List faceDetections = [];
  

  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager();

  @override
  void dispose() {
    albumManager.releaseCache(); // ✅ Ensures cache is cleared when screen is disposed
    super.dispose();
  }

  Color getEmotionColor(String emotion) {
  switch (emotion) {
    case "happy":
      return Colors.yellow;
    case "sad":
      return Colors.blue;
    case "angry":
      return Colors.red;
    case "fear":
      return Colors.purple;
    case "disgust":
      return Colors.green;
    case "neutral":
      return Colors.grey;
    case "surprise":
      return Colors.orange;
    default:
      return Colors.black;
  }
}

 Widget _buildEmotionWidget(EmotionImage emotion) {
    if (emotion.emotions.isEmpty) {
      return const Text('No emotions detected.');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (emotion.selectedImage != null)
           ExtendedImage.memory(
              emotion.selectedImage!,
              fit: BoxFit.cover,
              width: isPerFace.value ? 75: 200,
              height:isPerFace.value ? 75: 200,
              clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
            ),
          
          Icon(
            Icons.mood,
            color: getEmotionColor(emotion.mostCommonEmotion ?? ""),
          ),
          const SizedBox(width: 8),
          Text(
            emotion.mostCommonEmotion ?? 'Unknown',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }



Widget showAverageEmotion() {
  return ValueListenableBuilder<List<Uint8List>?>(
    valueListenable: _imageManager.selectedByteImagesNotifier,
    builder: (context, selectedImages, child) {
      if (selectedImages == null || selectedImages.isEmpty) return const Text('No selected image');

      return FutureBuilder<List<EmotionImage>>(
        future: _modelManager.modelArchitecture(selectedImages),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}', );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No predictions found.');
          }

          final emotionImages = snapshot.data!;
          final averageEmotions = <String, double>{};
          final emotionCounts = <String, int>{};

          for (var emotionImage in emotionImages) {
            for (var entry in emotionImage.emotions.entries) {
              averageEmotions[entry.key] = (averageEmotions[entry.key] ?? 0) + entry.value;
              emotionCounts[entry.key] = (emotionCounts[entry.key] ?? 0) + 1;
            }
          }

          averageEmotions.forEach((key, value) {
            averageEmotions[key] = value / (emotionCounts[key] ?? 1);
          });

          final emotionWidgets = averageEmotions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.mood, color: getEmotionColor(entry.key)),
                  const SizedBox(width: 8),
                  Text("\${entry.key}: \${entry.value.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList();

          return Column(
            children: [
              Text("Average emotions across images:"),
              const SizedBox(height: 10),
              ...emotionWidgets,
            ],
          );
        },
      );
    },
  );
}

Widget showEmotionsOnToggle() {
  return ValueListenableBuilder<List<Uint8List>?>(
    valueListenable: _imageManager.selectedByteImagesNotifier,
    builder: (context, selectedImages, child) {
      if (selectedImages == null || selectedImages.isEmpty) {
        return const Text('No selected images');
      }

      return FutureBuilder<List<dynamic>>(
        future: Future.wait(selectedImages.map((image) => _modelManager.modelArchitectureV2(image, perFace: isPerFace.value))),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error - emotion detection modelV2: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No predictions found.');
          }


          print('show images');
          final emotionWidgets = snapshot.data!.expand((data) {
            final isList = data is List<EmotionImage>;
            return isList ? (data).map(_buildEmotionWidget) : [_buildEmotionWidget(data as EmotionImage)];
          }).toList();

          return Column(
            children: emotionWidgets,
          );
        },
      );
    },
  );
}

Future<void> _openGallery() async {
  List<String>? pointers = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => GalleryScreen()), // nativeImagePickerScreen
  );

  if (pointers != null) {
      setState(() {
        _isGalleryLoading = false;
        // set imageManager Function to set pointerImages into UInt8List
        _imageManager.setPointersToBytesNotifier(pointers);
      });
  }
  print('here are pointers: $pointers');
}



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _openGallery();
   });
    albumManager.releaseCache(); // ✅ Clears cache on initialization
  }

  // @override
  // Widget build(BuildContext context) {
  //   return BaseScaffold(
  //     appBar: AppBar(
  //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //       title: Text('Scanning for Emotion'),
  //     ),
  //     body: SingleChildScrollView(
  //   physics: BouncingScrollPhysics(), // Optional: Makes scrolling smooth
  //   child: Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Center(
  //       // based on gllery loading show this until this...
  //       child: _isGalleryLoading ? const CircularProgressIndicator() 
  //       : Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           MaterialButton(
  //             onPressed: _openGallery,
  //             color: Colors.deepPurple,
  //             child: const Text('Muliple Images or one'),
  //           ),
  //           const SizedBox(height: 20),
  //           Switch(
  //             value: isPerFace.value,
  //             onChanged: (newValue) {
  //               isPerFace.value = newValue;
  //               setState(() {}); // Update UI when toggle changes
  //             }),
  //          Column(
  //         children: [ showEmotionsOnToggle() ],
  //       )
  
  //         ],
  //       ),
  //     ),
  //   )));
  // }


  @override
Widget build(BuildContext context) {
  return BaseScaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Scanning for Emotion'),
    ),
    body: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isGalleryLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: _openGallery,
                      color: Colors.deepPurple,
                      child: const Text('Multiple Images or One'),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: isPerFace,
                      builder: (context, value, child) {
                        return Switch(
                          value: value,
                          onChanged: (newValue) => isPerFace.value = newValue,
                        );
                      },
                    ),
                    showEmotionsOnToggle(),
                  ],
                ),
        ),
      ),
    ),
  );
}

  
}
