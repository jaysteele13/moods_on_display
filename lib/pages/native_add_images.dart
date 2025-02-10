
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';              
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PaginatedPhotoPickerScreen extends StatefulWidget {
  @override
  _PaginatedPhotoPickerScreenState createState() => _PaginatedPhotoPickerScreenState();
}

class _PaginatedPhotoPickerScreenState extends State<PaginatedPhotoPickerScreen> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> images = [];
  List<AssetEntity> selectedImages = [];
  Map<String, AssetEntity> selectedImagesMap = {}; // Persist selections
  AssetPathEntity? selectedAlbum;
  int currentPage = 0;
  bool isLoading = false;
  static const int pageSize = 50;

  /// List to store final selected images as File objects
  List<File> selectedImageFiles = [];
  List<String> selectedImagePointers = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Future<void> fetchAlbums() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> fetchedAlbums = await PhotoManager.getAssetPathList(type: RequestType.image);
      setState(() {
        albums = fetchedAlbums;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> fetchImages(AssetPathEntity album, {bool isNewAlbum = true}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    if (isNewAlbum) {
      setState(() {
        selectedAlbum = album;
        images.clear();
        currentPage = 0;
      });
    }

    List<AssetEntity> media = await album.getAssetListPaged(page: currentPage, size: pageSize);

    setState(() {
      images.addAll(media);
      currentPage++;
      isLoading = false;
    });
  }

  void loadMoreImages() {
    if (!isLoading && selectedAlbum != null) {
      fetchImages(selectedAlbum!, isNewAlbum: false);
    }
  }

  void toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedImagesMap.containsKey(asset.id)) {
        selectedImagesMap.remove(asset.id);
      } else {
        selectedImagesMap[asset.id] = asset;
      }
      selectedImages = selectedImagesMap.values.toList();
    });
  }

  Future<void> saveSelectedImages() async {
    List<File> files = [];
    List<String> pointers = [];
    for (AssetEntity asset in selectedImages) {
      String pointerId = asset.id;
      print('here is pointer id: $pointerId');
      pointers.add(pointerId);
      File? file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }
    setState(() {
      selectedImageFiles = files;
      selectedImagePointers = pointers;
    });

    /// ✅ Return selected images to previous screen
    // Navigator.pop(context, selectedImageFiles);
    Navigator.pop(context, selectedImagePointers);
  }

  void resetAlbumSelection() {
    setState(() {
      selectedAlbum = null;
      images.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text(selectedAlbum == null ? "Select an Album" : selectedAlbum!.name),
        actions: [
          if (selectedAlbum != null)
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: resetAlbumSelection,
            ),
          if (selectedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: saveSelectedImages,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedAlbum == null
                ? ListView.builder(
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(albums[index].name),
                        onTap: () => fetchImages(albums[index]),
                      );
                    },
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        loadMoreImages();
                      }
                      return false;
                    },
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: images.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == images.length) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return FutureBuilder<Uint8List?>(
                          future: images[index].thumbnailDataWithSize(ThumbnailSize(200, 200)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              bool isSelected = selectedImagesMap.containsKey(images[index].id);
                              return GestureDetector(
                                onTap: () => toggleSelection(images[index]),
                                child: Stack(
                                  children: [
                                    Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(Icons.check_circle, color: Colors.green, size: 30),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        );
                      },
                    ),
                  ),
          ),
          if (selectedImages.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              width: double.infinity,
              child: Text(
                "Selected Images: ${selectedImages.length}",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
