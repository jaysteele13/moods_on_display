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
  late Future<List<EmotionPointer>> _images;
  final AlbumManager albumManager = AlbumManager();
  late List<String> pointersToDelete = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // Fetch images matching the selected emotion
    _images = DatabaseManager.instance.getImagesByEmotion(widget.emotion);
  }

// Psuedo Code
/*
- on hold an image is selected (similar to gallery)
- button at the bottom to select images to delete


*/

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
  setState(() {
    selectedPointers.removeWhere((p) => pointersToDelete.contains(p.pointer));
    pointersToDelete.clear();
    isSelectionMode = false;
  });
  // function that is a for loop that looks through local database and selectivly removes pointers in toDelete

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
  child: FutureBuilder<List<EmotionPointer>>(
    future: _images,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error with database: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("No images found for this emotion"));
      }

      List<EmotionPointer> selectedPointers = snapshot.data!;
      print('pointer: ${selectedPointers[0].pointer}');

      return Column(
        children: [
            Expanded(
              child: ListView.builder(
                itemCount: (selectedPointers.length / 4).ceil(),
                itemBuilder: (context, rowIndex) {
                  int startIndex = rowIndex * 4;
                  int endIndex = (startIndex + 4 > selectedPointers.length)
                      ? selectedPointers.length
                      : startIndex + 4;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: selectedPointers.sublist(startIndex, endIndex).map((pointer) {
                      return FutureBuilder<Uint8List?>(
                        future: albumManager.getImageByPointer(pointer.pointer, false),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 70,
                              height: 70,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (imageSnapshot.hasError) {
                            return const SizedBox(
                              width: 70,
                              height: 70,
                              child: Center(child: Icon(Icons.error, color: Colors.red)),
                            );
                          }
                          if (imageSnapshot.hasData && imageSnapshot.data != null) {
                            return GestureDetector(
                              onTap: () async {
                                if (isSelectionMode) {
                                  toggleDeleteSelection(pointer.pointer);
                                } else {
                                  List<Uint8List> imageDataList = [];
                                  for (var ptr in selectedPointers) {
                                    Uint8List? imageData =
                                        await albumManager.getImageByPointer(ptr.pointer, false);
                                    if (imageData != null) {
                                      imageDataList.add(imageData);
                                    }
                                  }

                                  if (imageDataList.isNotEmpty) {
                                    int selectedIndex = selectedPointers.indexOf(pointer);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SingleImageView(
                                          images: imageDataList,
                                          initialIndex: selectedIndex,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  isSelectionMode = true;
                                  toggleDeleteSelection(pointer.pointer);
                                });
                              },
                              child: Stack(
                                children: [
                                  ExtendedImage.memory(
                                    imageSnapshot.data!,
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
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20), // Adds spacing before the button
            buildSelectionActions(selectedPointers),
          ],
        );
      },
    ),
  ),
  const SizedBox(height: 20), // Adds spacing before the button
  ElevatedButton(
    onPressed: DatabaseManager.instance.deleteDatabaseFile,
    child: const Text("Delete Database"),
  ),
      ],
    ),
  );
}
}
