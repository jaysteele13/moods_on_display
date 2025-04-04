import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/emotion_image.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';

import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/utils.dart';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => AddImageScreenState();
}

class AddImageScreenState extends State<AddImageScreen> {
  final ImageManager _imageManager = ImageManager(assetEntityService: AssetEntityService());
  final ModelManager _modelManager = ModelManager();
  final ValueNotifier<List<EmotionImage>> detectedEmotions = ValueNotifier<List<EmotionImage>>([]);

  bool _isGalleryLoading = false;
  List faceDetections = [];
 ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  

  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager(assetEntityService: AssetEntityService(), photoManagerService: PhotoManagerService());

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
      return DefaultColors.yellow;
    case EMOTIONS.sad:
      return DefaultColors.blue;
    case EMOTIONS.angry:
      return DefaultColors.red;
    case EMOTIONS.fear:
      return DefaultColors.purple;
    case EMOTIONS.disgust:
      return DefaultColors.green;
    case EMOTIONS.neutral:
      return DefaultColors.neutral;
    case EMOTIONS.surprise:
      return DefaultColors.orange;
    default:
      return DefaultColors.black;
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
  print('length of selcted images: ${selectedImages.length}---------------------');
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
                // add text waiting to progress images
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GalleryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Apply a fade transition animation
          return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            );
        },
        transitionDuration: Duration(milliseconds: 500), // Apply animation duration
      ),
    );


  if (pointers != null) {
    setState(() {
      _isGalleryLoading = true; // Show loading state while processing new batch
    });

    // ✅ Clear old data BEFORE starting a new detection
    detectedEmotions.value = [];
    progressNotifier.value = 0.0;

    // Convert pointers to FilePathPointer
    await _imageManager.setPointersToFilePathPointer(pointers);

    setState(() {
      _isGalleryLoading = false; // Hide loading state after processing
    });
  }
}




  @override
  void initState() {
    super.initState();
    albumManager.releaseCache(); // ✅ Clears cache on initialization
    detectedEmotions.value = [];
  }

@override
  Widget build(BuildContext context) {
    
    return BaseScaffold(
      appBar: Base.appBar(title: Text('Scanning for Emotion'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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