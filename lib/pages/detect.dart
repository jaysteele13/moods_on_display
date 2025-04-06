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
import 'package:moods_on_display/widgets/detect/detect_constants.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

/// Define the states for the prediction process
enum PredictionState {
  prePrediction,
  midPrediction,
  postPrediction,
  error
}

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

  ValueNotifier<PredictionState> currentPredictionState = ValueNotifier<PredictionState>(PredictionState.prePrediction); // Set the initial state before hand
  

  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager(assetEntityService: AssetEntityService(), photoManagerService: PhotoManagerService());

  bool _hasProcessedImages = false; // Guard variable

  @override
  void dispose()  {
    albumManager.releaseCache(); // ✅ Ensures cache is cleared when screen is disposed
    // call function to delete all images based on 
    _imageManager.listAndDeleteFiles();
    _modelManager.dispose();
    super.dispose();
  }


@override
  void initState() {
    super.initState();
    albumManager.releaseCache(); // ✅ Clears cache on initialization
    detectedEmotions.value = [];

    _imageManager.selectedMultiplePathsNotifier.addListener(() {
    final selected = _imageManager.selectedMultiplePathsNotifier.value;

    // Start processing when new images are selected and not processed yet
    if (selected != null && selected.isNotEmpty && !_hasProcessedImages) {
      _hasProcessedImages = true;
      currentPredictionState.value = PredictionState.midPrediction;
      _processAndUpdateState(selected);
    }
  });
  }

  Future<void> _processAndUpdateState(List<FilePathPointer> selectedImages) async {
  try {
    if (detectedEmotions.value.isNotEmpty) {
      currentPredictionState.value = PredictionState.postPrediction;
    } 
  } catch (e) {
    // Handle processing error if needed
    currentPredictionState.value = PredictionState.error;
  }
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



  Widget showEmotionsFaceV2(PredictionState state) {

      switch (state) {
        case PredictionState.prePrediction:
          return const SizedBox(); // No images selected yet
          // build pre prediction screen
          // return buildPrePredictionScreen();

        case PredictionState.midPrediction:
          // Check if images are selected
          if (_imageManager.selectedMultiplePathsNotifier.value == null ||
              _imageManager.selectedMultiplePathsNotifier.value!.isEmpty) {
            return const SizedBox(); // No images selected
          }

          return FutureBuilder<void>(
            future: _processImages(_imageManager.selectedMultiplePathsNotifier.value!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    const CircularProgressIndicator(), // Show loader while processing
                    ValueListenableBuilder<double>(
                      valueListenable: progressNotifier,
                      builder: (context, progress, child) {
                        return Column(
                          children: [
                            LinearProgressIndicator(value: progress),
                            ...detectedEmotions.value.map(_buildEmotionWidget),
                          ],
                        );
                      },
                      
                    ),
                    
                  ],
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                WidgetsBinding.instance.addPostFrameCallback((_) { // needed during future builder
                  if (currentPredictionState.value != PredictionState.postPrediction) {
                    currentPredictionState.value = PredictionState.postPrediction;
                  }
                });
                return const SizedBox(); // Hide the loader when done

              }
              return const SizedBox(); // You can show an error state if needed
            },
          );

        case PredictionState.postPrediction:
          return Column(
            children: [
              ...detectedEmotions.value.map(_buildEmotionWidget),
            ],
          );
        case PredictionState.error:
          return const Text('An error occurred during processing. Try Again.');
      }
    }

//   Widget showEmotionsFace() {
//   return ValueListenableBuilder<List<FilePathPointer>?>(
//     valueListenable: _imageManager.selectedMultiplePathsNotifier,
//     builder: (context, selectedImages, child) {

//       // What to do if no images are selected (e.g. no images in the gallery)

//       // For now this will return nothing until a state system is configured
//       if (selectedImages == null || selectedImages.isEmpty) {
//         return const SizedBox(); // No images selected
//       }
      
//       currentPredictionState.value = PredictionState.midPrediction;
     
      
//       return FutureBuilder<void>(
//         future: _processImages(selectedImages), // Process images automatically
//         builder: (context, snapshot) {
//           return Column(
//             children: [
//               if (snapshot.connectionState == ConnectionState.waiting)
//                 // add text waiting to progress images
//                 const CircularProgressIndicator(), // Show loader while processing
                
//                ValueListenableBuilder<double>(
//                 valueListenable: progressNotifier,
//                 builder: (context, progress, child) {
//                   return Column(
//                     children: [
//                       LinearProgressIndicator(
//                         value: progress, // Dynamically control progress
//                       ),
//                       // Display processed emotions
//                       ...detectedEmotions.value.map(_buildEmotionWidget).toList(),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }



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


AppBar _buildAppBar (String title, String subTitle) {
  return Base.appBar(
  toolBarHeight: 100,
  backgroundColor: DefaultColors.background,
  title:Center( // Centers the content horizontally
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            WidgetUtils.buildTitle(title, isUnderlined: true),
            const SizedBox(height: 8),
            WidgetUtils.buildParagraph(
              subTitle,
              fontSize: WidgetUtils.titleFontSize_75,
            ),
            const Divider(color: DefaultColors.grey),
          ],
        ),
      ),
  
  actions: [
    SizedBox(width: WidgetUtils.defaultToolBarHeight), // Invisible icon to take up space
    // Add actual action icons here if needed
  ],
);
}

AppBar _appBar(PredictionState state) {
  if(state == PredictionState.prePrediction) {
    return _buildAppBar(DETECT_CONSTANTS.prePredTitle, DETECT_CONSTANTS.prePredSubTitle);
  } else if(state == PredictionState.midPrediction) {
    return _buildAppBar(DETECT_CONSTANTS.midPredPredTitle, DETECT_CONSTANTS.midPredPredSubTitle);
  }
  else {
    return _buildAppBar(DETECT_CONSTANTS.postPredTitle, DETECT_CONSTANTS.postPredSubTitle);
  }
}

Widget buildPrePredictionScreen() {
  return const Center(
    child: Text('pre screen'),
  );

}

Widget buildMidPredictionScreen() {
  return const Center(
    child: Text('Predicting emotions...'),
  );
}

Widget buildPostPredictionScreen() {
  return const Center(
    child: Text('Prediction complete!'),
  );
}

@override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<PredictionState>(
    valueListenable: currentPredictionState,
    builder: (context, state, _) {
      return BaseScaffold(
      appBar: _appBar(state),
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
          children: [ showEmotionsFaceV2(state) ],
        )
  
          ],
        ),
      ),
    )));
      // return Scaffold(
      //   appBar: _appBar(state),
      //   body: showEmotionsFace(), // or wherever your main UI is
      // );
    },
  );
    
    
  } 
}


