/*
View the selected images by a function which gets the images byte code

*/
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';   
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/pages/native_add_images.dart'; // Import the photo picker screen

class AlbumScreen extends StatefulWidget {
  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<File> selectedImages = [];
  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager();

  Future<void> openImagePicker() async {
    List<File>? images = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaginatedPhotoPickerScreen()),
    );

    if (images != null) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<void> openImagePickerForPointers() async {
    List<String>? pointers = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaginatedPhotoPickerScreen()),
    );

    if (pointers != null) {
      setState(() {
        selectedPointers = pointers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: Text("Main Screen")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: openImagePickerForPointers,
            child: Text("Select Images"),
          ),
          SizedBox(height: 20),
          Text("Selected Images: ${selectedPointers.length}"),
          Expanded(
            child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: selectedPointers.length,
            itemBuilder: (context, index) {
            return FutureBuilder<Uint8List?>(
              future: albumManager.getImageByPointer(selectedPointers[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading while fetching
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                } else {
                  return Center(child: Text('Skip', textAlign: TextAlign.center));
                }
              },
            );
            },
            ),
          ),
        ],
      ),
    );
  }
}
