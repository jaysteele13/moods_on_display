import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';

class ImageLibraryScreen extends StatefulWidget {
  @override
  _ImageLibraryScreenState createState() => _ImageLibraryScreenState();
}

class _ImageLibraryScreenState extends State<ImageLibraryScreen> {
  List<AssetEntity> images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchGalleryImages();
  }

  // Fetch images from the Photos library
  Future<void> fetchGalleryImages() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    
    if (result.isAuth) {
      // Get image albums
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);

      if (albums.isNotEmpty) {
        // Get images from the first album
        List<AssetEntity> media = await albums.first.getAssetListPaged(page: 0, size: 30);

        setState(() {
          images = media;
        });
      }
    } else {
      // Handle permission denied
      PhotoManager.openSetting();
    }
  }

  // Pick image using Image Picker
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      print("Picked Image Path: ${pickedFile.path}"); // This gives the image filename
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Picked: ${pickedFile.path}")));
    }
  }

  // Get image filename from AssetEntity
  Future<String?> getImageTitle(AssetEntity asset) async {
    return await asset.titleAsync;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Library")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickImage,
            child: Text("Pick Image with ImagePicker"),
          ),
          Expanded(
            child: images.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: images[index].thumbnailDataWithSize(ThumbnailSize(200, 200)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return Column(
                              children: [
                                Image.memory(snapshot.data as Uint8List, fit: BoxFit.cover),
                                FutureBuilder<String?>(
                                  future: getImageTitle(images[index]),
                                  builder: (context, titleSnapshot) {
                                    return Text(
                                      titleSnapshot.data ?? "Unknown",
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                          return CircularProgressIndicator();
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
