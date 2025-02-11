import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';   
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/album_manager/album_view.dart';
import 'package:extended_image/extended_image.dart';

class AlbumScreen extends StatefulWidget {
  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<String> selectedPointers = [];
  final AlbumManager albumManager = AlbumManager();

  @override
  void initState() {
    super.initState();
    albumManager.releaseCache(); // ✅ Clears cache on initialization
  }

  @override
  void dispose() {
    albumManager.releaseCache(); // ✅ Ensures cache is cleared when screen is disposed
    super.dispose();
  }

  Future<void> openImagePickerForPointers() async {
    List<String>? pointers = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlbumViewScreen()),
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
      appBar: AppBar(title: const Text("Main Screen")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: openImagePickerForPointers,
            child: const Text("Select Images"),
          ),
          const SizedBox(height: 20),
          Text("Selected Images: ${selectedPointers.length}"),
          Expanded(
            child: ListView.builder(
  itemCount: (selectedPointers.length / 5).ceil(), // ✅ Groups images into rows of 4
  itemBuilder: (context, rowIndex) {
    int startIndex = rowIndex * 4;
    int endIndex = (startIndex + 4).clamp(0, selectedPointers.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: selectedPointers.sublist(startIndex, endIndex).map((pointer) {
        return FutureBuilder<Uint8List?>(
          future: albumManager.getImageByPointer(pointer, false), // ✅ Low-res mode
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
                width: 100,
                height: 100,
                child: Center(child: Text('Error', textAlign: TextAlign.center)),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
               return ExtendedImage.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
                clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
              );
            }
            return const SizedBox(
              width: 100,
              height: 100,
              child: Center(child: Text('Skip', textAlign: TextAlign.center)),
            );
          },
        );
      }).toList(),
    );
  },
),
          ),
        ],
      ),
    );
  }
}
