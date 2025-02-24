import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/pages/single_images.dart';
import 'package:moods_on_display/utils/types.dart';

class ImagesScreen extends StatefulWidget {
  final String emotion;

  const ImagesScreen({Key? key, required this.emotion}) : super(key: key);

  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  List<EmotionPointer> _loadedImages = [];
  final AlbumManager albumManager = AlbumManager();
  late List<String> pointersToDelete = [];
  bool isSelectionMode = false;
  bool _isLoading = false;

  void _fetchImages() async {
  List<EmotionPointer> images = await DatabaseManager.instance.getImagesByEmotion(widget.emotion);
    setState(() {
      _loadedImages = images;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

Map<String, Uint8List?> imageCache = {}; // Cache images

Widget _buildImageItem(EmotionPointer pointer) {
  return FutureBuilder<Uint8List?>(
    future: _getCachedImage(pointer.pointer),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting && !imageCache.containsKey(pointer.pointer)) {
        return const SizedBox(
          width: 70,
          height: 70,
          child: Center(child: Text("Loading...")),
        );
      }
      if (snapshot.hasError) {
        return const SizedBox(
          width: 70,
          height: 70,
          child: Center(child: Icon(Icons.error, color: Colors.red)),
        );
      }
      if (snapshot.hasData && snapshot.data != null) {
        return GestureDetector(
          onTap: () => _onImageTap(pointer),
          onLongPress: () => _onImageLongPress(pointer.pointer),
          child: Stack(
            children: [
              ExtendedImage.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
                clearMemoryCacheWhenDispose: true,
              ),
              if (pointersToDelete.contains(pointer.pointer))
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
            ],
          ),
        );
      }
      return const SizedBox(
        width: 70,
        height: 70,
        child: Center(child: Text('No Image')),
      );
    },
  );
}

Future<Uint8List?> _getCachedImage(String pointer) async {
  if (imageCache.containsKey(pointer)) {
    return imageCache[pointer];
  } else {
    Uint8List? imageData = await albumManager.getImageByPointer(pointer, false);
    imageCache[pointer] = imageData;
    return imageData;
  }
}

void _onImageLongPress(String pointer) {
  setState(() {
    isSelectionMode = true;
    toggleDeleteSelection(pointer);
  });
}

void _onImageTap(EmotionPointer pointer) async {
  if (isSelectionMode) {
    // If in selection mode, just toggle the selection
    toggleDeleteSelection(pointer.pointer);
  } else {
    // Otherwise, open the image in full view
    List<Uint8List> imageDataList = [];
    for (var ptr in _loadedImages) {
      if (!imageCache.containsKey(ptr.pointer)) {
        Uint8List? imageData = await albumManager.getImageByPointer(ptr.pointer, false);
        imageCache[ptr.pointer] = imageData; // Cache for later use
      }
      if (imageCache[ptr.pointer] != null) {
        imageDataList.add(imageCache[ptr.pointer]!);
      }
    }

    // send to single image view
    if (imageDataList.isNotEmpty) {
      int selectedIndex = _loadedImages.indexOf(pointer);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleImageView(
            images: imageDataList,
            initialIndex: selectedIndex,
            emotion: widget.emotion
          ),
        ),
      );
    }
  }
}

void toggleDeleteSelection(String pointer) {
    setState(() {
      if (pointersToDelete.contains(pointer)) {
        pointersToDelete.remove(pointer);
        if (pointersToDelete.isEmpty) {
        isSelectionMode = false; // Exit selection mode if no images are selected
      }
      } else {
        pointersToDelete.add(pointer);
      }
    });
  }

// Function to delete selected images
Future<void> deleteSelectedImages( List<EmotionPointer> selectedPointers) async {
  // function that is a for loop that looks through local database and selectivly removes pointers in toDelete
  await DatabaseManager.instance.deleteImageRecords(pointersToDelete);

  setState(() {
    selectedPointers.removeWhere((p) => pointersToDelete.contains(p.pointer));
    pointersToDelete.clear();
    isSelectionMode = false;
  });
  
}

// Function to cancel selection mode
void cancelSelection() {
  setState(() {
    pointersToDelete.clear();
    isSelectionMode = false;
  });
}

// Buttons for delete and cancel (should be placed in the UI)
Widget buildSelectionActions(List<EmotionPointer> selectedPointers) {
  return isSelectionMode
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () async {
                await deleteSelectedImages(selectedPointers);
              },
              child: Text("Delete"),
            ),
            ElevatedButton(
              onPressed: cancelSelection,
              child: Text("Cancel"),
            ),
          ],
        )
      : Container();
}

@override
Widget build(BuildContext context) {
  return BaseScaffold(
    // Grab title of image baed off of context.
    appBar: AppBar(title: Text("Gallery: ${widget.emotion}")),
    body: Column(
      children: [
        Expanded(
  child: _isLoading
      ? const Center(child: CircularProgressIndicator()) // Show loading indicator initially
      : _loadedImages.isEmpty
          ? const Center(child: Text("No images found for this emotion"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: (_loadedImages.length / 4).ceil(),
                    itemBuilder: (context, rowIndex) {
                      int startIndex = rowIndex * 4;
                      int endIndex = (startIndex + 4 > _loadedImages.length)
                          ? _loadedImages.length
                          : startIndex + 4;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _loadedImages.sublist(startIndex, endIndex).map((pointer) {
                          return _buildImageItem(pointer);
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Adds spacing before the button
                buildSelectionActions(_loadedImages),
              ],
            ),
)

  //  SizedBox(height: 20), // Adds spacing before the button
  // ElevatedButton(
  //   onPressed: DatabaseManager.instance.deleteDatabaseFile,
  //   child: const Text("Delete Database"),
  // ),
      ],
    ),
  );
}
}
