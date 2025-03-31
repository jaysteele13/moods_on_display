import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';              
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:ui';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> images = [];
  List<String> selectedPointers = [];
  AssetPathEntity? selectedAlbum;
  int currentPage = 0;
  bool isLoading = false;
  static const int pageSize = 50;

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Future<void> fetchAlbums() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> fetchedAlbums = await PhotoManager.getAssetPathList(type: RequestType.image);
      setState(() => albums = fetchedAlbums);
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

  /// **Efficiently stores only asset ID in memory**
  void toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedPointers.contains(asset.id)) {
        selectedPointers.remove(asset.id);
      } else {
        selectedPointers.add(asset.id);
      }
    });
  }


  /// **Returns selected image IDs instead of loading files into memory**
  void saveSelectedImages() {
    List<String> result = List.from(selectedPointers); // Copy pointers before clearing

  // Clear memory before closing the page
  setState(() {
    images.clear();
    selectedPointers.clear();
  });
  PhotoManager.releaseCache(); // 🔹 Force cache release
  if (mounted) {
    Navigator.pop(context, result); // Ensure the widget is still mounted before popping. This pops the pointers to the page that is calling gallery.
  }
}

  void resetAlbumSelection() {
    setState(() {
      selectedAlbum = null;
      images.clear();
    });
  }

void triggerGC() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PlatformDispatcher.instance.onBeginFrame; 
  });
}

@override
void dispose() {
  images.clear(); // Clear the loaded images
  selectedPointers.clear(); // Clear selected image pointers
  PhotoManager.releaseCache(); // 🔹 Release asset cache
  triggerGC();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text(selectedAlbum == null ? "Select an Album" : selectedAlbum!.name),
        key: const Key('gallery_body'),
        leading: selectedAlbum == null
      ? WidgetUtils.buildBackButton(context, AddImageScreen())
      : SizedBox(),
        actions: [
          if (selectedAlbum != null)
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: resetAlbumSelection,
            ),
          if (selectedPointers.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: saveSelectedImages,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // based on the selected album I will show each image in memory
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
                  // if album not null then an album has been selected
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
                          // here we grab what image the users selects
                          future: images[index].thumbnailDataWithSize(ThumbnailSize(200, 200)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              bool isSelected = selectedPointers.contains(images[index].id);
                              
                              return GestureDetector(
                                // per rendered image, per tap and image is selected
                                onTap: () => toggleSelection(images[index]),
                                child: Stack(
                                  children: [
                                
                                      ExtendedImage.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          clearMemoryCacheWhenDispose: true, // Clears memory when widget is removed
                                        ),
                                  
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
                            return SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ),
          ),
          // have a notification displaying the amount of selected images
          if (selectedPointers.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              width: double.infinity,
              child: Text(
                "Selected Images: ${selectedPointers.length}",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
