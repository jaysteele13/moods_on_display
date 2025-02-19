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

  @override
  void initState() {
    super.initState();
    // Fetch images matching the selected emotion
    _images = DatabaseManager.instance.getImagesByEmotion(widget.emotion);
  }

// Psuedo Code
/*
- be able to select one image at a time, when an image is selected, amend the view so we can now view each image and scroll
- this view will be a new alternative view called single-image-view
- 



*/
@override
Widget build(BuildContext context) {
  return BaseScaffold(
    // Grab title of image baed off of context.
    appBar: AppBar(title: Text("Gallery: ${widget.emotion}")),
    body: Column(
      children: [
        Expanded(
          // Custom object passed containing pointer and emotion.
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

              return ListView.builder(
                itemCount: (selectedPointers.length / 4).ceil(), // ✅ Groups images into rows of 4
                itemBuilder: (context, rowIndex) {
                  int startIndex = rowIndex * 4;
                  int endIndex = (startIndex + 4).clamp(0, selectedPointers.length);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: selectedPointers.sublist(startIndex, endIndex).map((pointer) {
                      return FutureBuilder<Uint8List?>(
                        future: albumManager.getImageByPointer(pointer.pointer, false), // ✅ Load image
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 70,
                              height: 70,
                              child: Center(child: CircularProgressIndicator()),
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
                              onTap: () async {
                                List<Uint8List> imageDataList = [];
                                for (var pointer in selectedPointers) {
                                  Uint8List? imageData = await albumManager.getImageByPointer(pointer.pointer, false);
                                  if (imageData != null) {
                                    imageDataList.add(imageData);
                                  }
                                }

                                if (imageDataList.isNotEmpty) {
                                  int selectedIndex = selectedPointers.indexOf(pointer); // Find tapped image index
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SingleImageView(images: imageDataList, initialIndex: selectedIndex),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  ExtendedImage.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                    clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
                                  )
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
