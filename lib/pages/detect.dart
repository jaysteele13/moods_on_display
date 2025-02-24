
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/emotion_image.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';

import 'package:moods_on_display/utils/constants.dart';

/*
Amend this code so everytime a detection happens and an image is generated show the face and the progress
Should show the estimated time of model time prediction, as well as each face and emotion when detected.



*/

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => AddImageScreenState();
}

class AddImageScreenState extends State<AddImageScreen> {
  final ImageManager _imageManager = ImageManager();
  final ModelManager _modelManager = ModelManager();
  final ValueNotifier<List<EmotionImage>> detectedEmotions = ValueNotifier<List<EmotionImage>>([]);

  final List<String> faceJPEGs = [];

  bool _isGalleryLoading = false;
  List faceDetections = [];
 ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  

  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager();

  @override
  void dispose()  {
    albumManager.releaseCache(); // ✅ Ensures cache is cleared when screen is disposed
    // call function to delete all images based on 
    _imageManager.listAndDeleteFiles();
    _modelManager.dispose();
    super.dispose();
  }

  Color getEmotionColor(String emotion) {
  switch (emotion) {
    case EMOTIONS.happy:
      return Colors.yellow;
    case EMOTIONS.sad:
      return Colors.blue;
    case EMOTIONS.angry:
      return Colors.red;
    case EMOTIONS.fear:
      return Colors.purple;
    case EMOTIONS.disgust:
      return Colors.green;
    case EMOTIONS.neutral:
      return Colors.grey;
    case EMOTIONS.surprise:
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
          FutureBuilder<Uint8List?>(
            // here the emotions pointer is being used -> we could use filePath to get temporary face
        future: _imageManager.getImageByPointer(
          emotion.selectedFilePathPointer!.imagePointer,
          true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loader while waiting
          } else if (snapshot.hasError) {
            return const Icon(Icons.error, color: Colors.red); // Handle errors
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox(); // Handle null image
          }
          return ExtendedImage.file(
            File(emotion.selectedFilePathPointer!.filePath),
            fit: BoxFit.cover,
            width: 75,
            height: 75,
            clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
          );
         
        },
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



Future<void> _processImages(List<FilePathPointer> selectedImages) async {
  detectedEmotions.value = []; // Clear previous results
  int totalImages = selectedImages.length;

  for (int i = 0; i < totalImages; i++) {
    try {
      var result = await _modelManager.modelArchitectureV2(selectedImages[i]);

      // Ensure result is always a List
      List<EmotionImage> emotions = (result is List<EmotionImage>) ? result : [result];

      // Prepend new emotions so they appear at the top (newest first)
      detectedEmotions.value = [...emotions, ...detectedEmotions.value];

      // Update progress after each image is processed
      progressNotifier.value = (i + 1) / totalImages;
    } catch (error) {
      print("Error processing image: $error");
    }
  }

  // After processing all images, ensure progress is 1
  progressNotifier.value = 1.0;
}



  Widget showEmotionsFace() {
  return ValueListenableBuilder<List<FilePathPointer>?>(
    valueListenable: _imageManager.selectedMultiplePathsNotifier,
    builder: (context, selectedImages, child) {
      if (selectedImages == null || selectedImages.isEmpty) {
        return const Text('No selected images');
      }

      return FutureBuilder<void>(
        future: _processImages(selectedImages), // Process images automatically
        builder: (context, snapshot) {
          return Column(
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const CircularProgressIndicator(), // Show loader while processing
                
               ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, progress, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress, // Dynamically control progress
                      ),
                      // Display processed emotions
                      ...detectedEmotions.value.map(_buildEmotionWidget).toList(),
                    ],
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}



Future<void> _openGallery() async {
  List<String>? pointers = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => GalleryScreen()), // pops image pointers
  );

  if (pointers != null) {
      setState(() {
        _isGalleryLoading = false;
        // we then turn pointers into temporary files
         _imageManager.setPointersToFilePathPointer(pointers);
        // set imageManager Function to set pointerImages into UInt8List this won't work so pointers must be set to files
        // _imageManager.setPointersToBytesNotifier(pointers);
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
    detectedEmotions.value = [];
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
              onPressed: _openGallery,
              color: Colors.deepPurple,
              child: const Text('Muliple Images or one'),
            ),
            const SizedBox(height: 20),
    
           Column(
          children: [ showEmotionsFace() ],
        )
  
          ],
        ),
      ),
    )));
  }

  
}
