
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

  void _pickImageFromCamera() async {
    await _imageManager.pickImageFromCamera();
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
              width: isPerFace.value ? 75: 300,
              height:isPerFace.value ? 75: 300,
            ),
          Icon(
            Icons.mood,
            color: getEmotionColor(emotion.mostCommonEmotion ?? ""),
          ),
          const SizedBox(width: 8),
          Text(
            "Emotion: ${emotion.mostCommonEmotion ?? 'Unknown'}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }



Widget showAverageEmotion() {
  return ValueListenableBuilder<File?>(
    valueListenable: _imageManager.selectedImageNotifier,
    builder: (context, selectedImage, child) {
      if (selectedImage == null) return const Text('No selected image');

      return FutureBuilder<EmotionImage>(
        future: _modelManager.modelArchitecture(selectedImage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.emotions.isEmpty) {
            return const Text('No predictions found.');
          }

          final emotionImage = snapshot.data!;
          final emotionWidgets = emotionImage.emotions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.mood, color: getEmotionColor(entry.key)),
                  const SizedBox(width: 8),
                  Text("${entry.key}: ${entry.value.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList();

          return Column(
            children: [
              Text("Highest average emotion: ${emotionImage.highestEmotion}"),
              Text("Most common emotion in faces: ${emotionImage.mostCommonEmotion}"),
              if (emotionImage.selectedImage != null)
                Image.file(emotionImage.selectedImage!, width: 150, height: 150),
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
                        width: 75,
                        height: 75,
                      ),
                    Icon(
                      Icons.mood,
                      color: getEmotionColor(emotion.mostCommonEmotion ?? ""),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Emotion: ${emotion.mostCommonEmotion ?? 'Unknown'}",
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
  return ValueListenableBuilder<File?>(
    valueListenable: _imageManager.selectedImageNotifier,
    builder: (context, selectedImage, child) {
      if (selectedImage == null) {
        return const Text('No selected image');
      }

      return FutureBuilder<dynamic>(
        future: _modelManager.modelArchitectureV2(selectedImage, perFace: isPerFace.value),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error - emotion detection: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('No predictions found.');
          }

          final isList = snapshot.data is List<EmotionImage>;

          return isList
              ? Column(
                  children: (snapshot.data as List<EmotionImage>).map(_buildEmotionWidget).toList(),
                )
              : _buildEmotionWidget(snapshot.data as EmotionImage);
        },
      );
    },
  );
}



  @override
  void initState() {
    super.initState();
    _pickImageFromGallery();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Scanning for Emotion'),
      ),
      body: Center(
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
              onPressed: _pickImageFromCamera,
              color: Colors.red,
              child: const Text('Camera'),
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
    );
  }
}
