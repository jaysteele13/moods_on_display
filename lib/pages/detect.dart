
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/emotion_image.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'dart:io';

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
  
  // have local image holder? use 

 

  // have functions to call other functions - dart common standard
  void _pickImageFromGallery() async {
    setState(() { _isGalleryLoading = true;});
    await _imageManager.pickImageFromGallery();
    setState(() { _isGalleryLoading = false;});
    
     
  }

  // void _pickImageFromCamera() async {
  //   await _imageManager.pickImageFromCamera();
  //   setState(() {
  //     _isGalleryLoading = false;
  //   });
  // }

  void _clearFiles() async {
    await _imageManager.listAndDeleteFiles();
    setState(() {
      _isGalleryLoading = false;
    });
  }

  void _pickMultipleImagesFromCamera() async {
    await _imageManager.pickMultipleImagesFromGallery();
    setState(() {
      _isGalleryLoading = false;
    });
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
            Image.file(
              emotion.selectedImage!,
              width: isPerFace.value ? 75: 200,
              height:isPerFace.value ? 75: 200,
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
  return ValueListenableBuilder<List<File>?>(
    valueListenable: _imageManager.selectedMultipleImagesNotifier,
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



Widget showEmotionPerFace() {
  return ValueListenableBuilder<File?>(
    valueListenable: _imageManager.selectedImageNotifier,
    builder: (context, selectedImage, child) {
      if (selectedImage == null) {
        return const Text('No selected image');
      }

      return FutureBuilder<List<EmotionImage>?>(
        future: _modelManager.modelArchitectureEmotionPerFace(selectedImage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error - emotion per face: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No predictions found.');
          }

          List<EmotionImage> emotionImages = snapshot.data!;

          return Column(
            children: emotionImages.map((emotion) {
              if (emotion.emotions.isEmpty) {
                return Column( // Wrap both widgets in a Column
                  children: [
                    Image.file(
                      emotion.selectedImage!,
                      width: 75,
                      height: 75,
                    ),
                    const Text('No emotions detected.'),
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (emotion.selectedImage != null)
                      Image.file(
                        emotion.selectedImage!,
                        width: 75,
                        height: 75,
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
            }).toList(),
          );
        },
      );
    },
  );
}


Widget showEmotionsOnToggle() {
  return ValueListenableBuilder<List<File>?>(
    valueListenable: _imageManager.selectedMultipleImagesNotifier,
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
            return Text('Error - emotion detection: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No predictions found.');
          }



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



  @override
  void initState() {
    super.initState();
    _pickMultipleImagesFromCamera();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Scanning for Emotion'),
      ),
      body: SingleChildScrollView(
    physics: BouncingScrollPhysics(), // Optional: Makes scrolling smooth
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        // based on gllery loading show this until this...
        child: _isGalleryLoading ? const CircularProgressIndicator() 
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: _pickImageFromGallery,
              color: Colors.blue,
              child: const Text('Gallery'),
            ),
            MaterialButton(
              onPressed: _clearFiles,
              color: Colors.red,
              child: const Text('Clear Files'),
            ),
            MaterialButton(
              onPressed: _pickMultipleImagesFromCamera,
              color: Colors.deepPurple,
              child: const Text('Muliple Images or one'),
            ),
            const SizedBox(height: 20),
            Switch(
              value: isPerFace.value,
              onChanged: (newValue) {
                isPerFace.value = newValue;
                setState(() {}); // Update UI when toggle changes
              }),
           Column(
          children: [ showEmotionsOnToggle() ],
        )
  
          ],
        ),
      ),
    )));
  }
  
}
