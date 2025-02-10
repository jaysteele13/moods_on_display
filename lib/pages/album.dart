import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';

class PaginatedPhotoPickerScreen extends StatefulWidget {
  @override
  _PaginatedPhotoPickerScreenState createState() => _PaginatedPhotoPickerScreenState();
}

class _PaginatedPhotoPickerScreenState extends State<PaginatedPhotoPickerScreen> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> images = [];
  List<AssetEntity> selectedImages = [];
  AssetPathEntity? selectedAlbum;
  int currentPage = 0;
  bool isLoading = false;
  static const int pageSize = 50; // Load 50 images per page

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  /// Fetch albums from the Photos Library
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

  /// Fetch paginated images from the selected album
  Future<void> fetchImages(AssetPathEntity album, {bool isNewAlbum = true}) async {
    if (isLoading) return; // Prevent duplicate requests
    setState(() => isLoading = true);

    if (isNewAlbum) {
      setState(() {
        selectedAlbum = album;
        images.clear();
        selectedImages.clear();
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

  /// Load more images when user scrolls down
  void loadMoreImages() {
    if (!isLoading && selectedAlbum != null) {
      fetchImages(selectedAlbum!, isNewAlbum: false);
    }
  }

  /// Toggle image selection
  void toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedImages.contains(asset)) {
        selectedImages.remove(asset);
      } else {
        selectedImages.add(asset);
      }
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
              icon: Icon(Icons.check),
              onPressed: () {
                if (selectedImages.isNotEmpty) {
                  print("Selected ${selectedImages.length} images.");
                }
              },
            ),
        ],
      ),
      body: selectedAlbum == null
          ? // Show album selection first
          ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(albums[index].name),
                  onTap: () => fetchImages(albums[index]),
                );
              },
            )
          : // Show paginated images
          NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  loadMoreImages();
                }
                return false;
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: images.length + (isLoading ? 1 : 0), // Show loading indicator
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return FutureBuilder<Uint8List?>(
                    future: images[index].thumbnailDataWithSize(ThumbnailSize(200, 200)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return GestureDetector(
                          onTap: () => toggleSelection(images[index]),
                          child: Stack(
                            children: [
                              Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              if (selectedImages.contains(images[index]))
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
    );
  }
}
