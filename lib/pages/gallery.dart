import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_types.dart';
import 'package:moods_on_display/managers/album_manager/selectedImagesManager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/gallery/gallery_constants.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';

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

  void toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedPointers.contains(asset.id)) {
        selectedPointers.remove(asset.id);
      } else {
        selectedPointers.add(asset.id);
      }
    });
  }

  void saveSelectedImages() {
    List<String> result = List.from(selectedPointers);
    setState(() {
      images.clear();
      selectedPointers.clear();
    });
    PhotoManager.releaseCache();
    if (mounted) {

      Navigator.pop(context, result);

    }
  }

  void resetImageSelection() {
    setState(() {
      selectedPointers.clear();
    });
  }

  void resetAlbumSelection() {
    setState(() {
      selectedAlbum = null;
      images.clear();
    });
  }


// Gallery Screen
Future<AlbumData> fetchAlbumData(AssetPathEntity album) async {
  try {
    // Get the total number of images
    int imageCount = await album.assetCountAsync;

    // Fetch up to 5 images
    List<AssetEntity> media = await album.getAssetListPaged(page: 0, size: 5);
    
    // Convert to thumbnails (Uint8List)
    List<Uint8List> thumbnails = [];
    for (var asset in media) {
      final Uint8List? thumb = await asset.thumbnailDataWithSize(ThumbnailSize(200, 200));
      if (thumb != null) {
        thumbnails.add(thumb);
      }
    }

    return AlbumData(
      images: thumbnails,
      amount: imageCount,
    );
  } catch (e) {
    print('Error fetching album data: $e');
    return AlbumData(images: [], amount: 0);
  }
}
     
            


// Gallery Screen
Future<Widget> buildAlbum(String albumName, int idx) async {
  AlbumData albumData = await fetchAlbumData(albums[idx]);

  // If the album has no images, return an empty container
  if (albumData.amount == 0) {
    return SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () => fetchImages(albums[idx]),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  WidgetUtils.buildTitle(albumName, fontSize: WidgetUtils.titleFontSize_75),
                  SizedBox(height: 8),
                  WidgetUtils.buildParagraph(
                    "{color->G}${albumData.amount}{/color}",
                    fontSize: WidgetUtils.titleFontSize_75,
                    isCentered: false,
                  ),
                ],
              ),
            ),
            if (albumData.images != null && albumData.images!.isNotEmpty)
              SizedBox(
                width: 140, // Total width for the images
                height: 70,
                child: Row(
                  children: [
                    // Large first image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      child: ExtendedImage.memory(
                        albumData.images![0],
                        fit: BoxFit.fill,
                        width: 60,
                        height: 80,
                        clearMemoryCacheWhenDispose: true
                      ),
                    ),
                    SizedBox(width: 4), // Small spacing between big and small images

                    // Grid for the next 4 images
                    if (albumData.images!.length > 1)
                      SizedBox(
                        width: 70, // Remaining width for small images
                        height: 80,
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside grid
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2x2 grid for 4 images
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: albumData.images!.length > 5 ? 4 : albumData.images!.length - 1,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ExtendedImage.memory(
                                albumData.images![index + 1], // Skip the first image
                                fit: BoxFit.fill,
                                width: 30,
                                height: 40,
                                clearMemoryCacheWhenDispose: true
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8), // Add some space before the divider
        Divider(thickness: 1, color: DefaultColors.grey), // Divider between albums
        SizedBox(height: 8), // Add some space after the divider
      ],
    ),
  );
}


Widget selectedImageWidget(int amount) {
  return // Moved outside ListView.builder
          Container(
            padding: EdgeInsets.all(WidgetUtils.defaultPadding),
            
            width: double.infinity,
            decoration: BoxDecoration(
              color: DefaultColors.blue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              "Selected Images: $amount",
              style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
}



  @override
  void dispose() {
    images.clear();
    selectedPointers.clear();
    PhotoManager.releaseCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: DefaultColors.background,
      appBar: Base.appBar(
  toolBarHeight: selectedAlbum == null ? 100 : WidgetUtils.defaultToolBarHeight,
  title: selectedAlbum == null
      ? Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  WidgetUtils.buildTitle(GALLERY_CONSTANTS.title),
                  SizedBox(height: 8),
                  WidgetUtils.buildParagraph(
                    GALLERY_CONSTANTS.subTitle,
                    fontSize: WidgetUtils.titleFontSize_75,
                  ),
                  Divider(color: DefaultColors.grey),
                ],
              ),
            ),
          ],
        )
      : Center(child: WidgetUtils.buildTitle(selectedAlbum!.name)), // Centered title when album is selected
  leading: selectedAlbum == null
      ? WidgetUtils.buildBackButton(context, AddImageScreen())
      : IconButton(
          icon: Icon(Icons.folder_open),
          onPressed: resetAlbumSelection,
        ),
  actions: [
    // Invisible icon to take up space when no check icon is needed
    if (selectedPointers.isEmpty)
      IconButton(
        icon: Icon(Icons.check, color: Colors.transparent), // Invisible icon
        onPressed: () {},
      ),
    // Actual check icon when pointers are selected
    if (selectedPointers.isNotEmpty)
      IconButton(
        icon: Icon(Icons.check),
        onPressed: saveSelectedImages,
      ),
  ],
),


// BODY OF GALLERY SCREEN
body: Stack(
  children: [
    Padding(
      padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: selectedAlbum == null
                ? Container(
                    width: WidgetUtils.containerWidth,
                    padding: EdgeInsets.all(WidgetUtils.defaultPadding),
                    decoration: WidgetUtils.containerDecoration,
                    child: ListView.builder(
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: buildAlbum(albums[index].name, index),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return SizedBox();
                            } else {
                              return snapshot.data as Widget;
                            }
                          },
                        );
                      },
                    ),
                  )
                : Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels >=
                                    scrollInfo.metrics.maxScrollExtent - 200) {
                                  loadMoreImages();
                                }
                                return false;
                              },
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                                itemCount: images.length + (isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == images.length) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  return FutureBuilder<Uint8List?>(
                                    future: images[index].thumbnailDataWithSize(
                                        ThumbnailSize(200, 200)),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done &&
                                          snapshot.hasData) {
                                        bool isSelected = selectedPointers.contains(images[index].id);

                                        return Padding(
                                          padding: const EdgeInsets.all(
                                              WidgetUtils.defaultPadding / 2),
                                          child: GestureDetector(
                                            onTap: () => toggleSelection(images[index]),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: ExtendedImage.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    clearMemoryCacheWhenDispose: true,
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: DefaultColors.tickColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle_outline_rounded,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
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
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),

    // Overlay widget for selected images
 if (selectedPointers.isNotEmpty)
    AnimatedSelectedImagesNotification(selectedCount: selectedPointers.length, onClearSelection: resetImageSelection,),


  ],
),

    );
  }
}