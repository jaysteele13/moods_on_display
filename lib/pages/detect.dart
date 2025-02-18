
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
          if (isPerFace.value) {
          // If isPerFace is true, return the ExtendedImage.memory widget
          return ExtendedImage.file(
            File(emotion.selectedFilePathPointer!.filePath),
            fit: BoxFit.cover,
            width: 75,
            height: 75,
            clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
          );
         
        } else {
          // If isPerFace is false, return the ExtendedImage.file widget
           return ExtendedImage.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: 150,
            height: 150,
            clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
          );
        }
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

Widget showEmotionsOnToggle() {
  return ValueListenableBuilder<List<FilePathPointer>?>(
    valueListenable: _imageManager.selectedMultiplePathsNotifier,
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
            Switch(
              value: isPerFace.value,
              onChanged: (newValue) { // this causes the function to run twice
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
