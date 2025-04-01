// import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';              
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:moods_on_display/pages/detect.dart';
// import 'package:moods_on_display/widgets/utils/utils.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:extended_image/extended_image.dart';
// import 'dart:ui';

// class GalleryScreen extends StatefulWidget {
//   @override
//   _GalleryScreenState createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   List<AssetPathEntity> albums = [];
//   List<AssetEntity> images = [];
//   List<String> selectedPointers = [];
//   AssetPathEntity? selectedAlbum;
//   int currentPage = 0;
//   bool isLoading = false;
//   static const int pageSize = 50;

//   @override
//   void initState() {
//     super.initState();
//     fetchAlbums();
//   }

//   Future<void> fetchAlbums() async {
//     final PermissionState result = await PhotoManager.requestPermissionExtend();
//     if (result.isAuth) {
//       List<AssetPathEntity> fetchedAlbums = await PhotoManager.getAssetPathList(type: RequestType.image);
//       setState(() => albums = fetchedAlbums);
//     } else {
//       PhotoManager.openSetting();
//     }
//   }

//   Future<void> fetchImages(AssetPathEntity album, {bool isNewAlbum = true}) async {
//     if (isLoading) return;
//     setState(() => isLoading = true);

//     if (isNewAlbum) {
//       setState(() {
//         selectedAlbum = album;
//         images.clear();
//         currentPage = 0;
//       });
//     }

//     List<AssetEntity> media = await album.getAssetListPaged(page: currentPage, size: pageSize);

//     setState(() {
//       images.addAll(media);
//       currentPage++;
//       isLoading = false;
//     });
//   }

//   void loadMoreImages() {
//     if (!isLoading && selectedAlbum != null) {
//       fetchImages(selectedAlbum!, isNewAlbum: false);
//     }
//   }

//   /// ✅ **Efficiently stores only asset ID in memory**
//   void toggleSelection(AssetEntity asset) {
//     setState(() {
//       if (selectedPointers.contains(asset.id)) {
//         selectedPointers.remove(asset.id);
//       } else {
//         selectedPointers.add(asset.id);
//       }
//     });
//   }


//   /// ✅ **Returns selected image IDs instead of loading files into memory**
//   void saveSelectedImages() {
//     List<String> result = List.from(selectedPointers); // Copy pointers before clearing

//   // ✅ Clear memory before closing the page
//   setState(() {
//     images.clear();
//     selectedPointers.clear();
//   });
//   PhotoManager.releaseCache(); // 🔹 Force cache release
//   if (mounted) {
//     Navigator.pop(context, result); // Ensure the widget is still mounted before popping. This pops the pointers to the page that is calling gallery.
//   }
// }

//   void resetAlbumSelection() {
//     setState(() {
//       selectedAlbum = null;
//       images.clear();
//     });
//   }

// void triggerGC() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     PlatformDispatcher.instance.onBeginFrame; 
//   });
// }

// @override
// void dispose() {
//   images.clear(); // Clear the loaded images
//   selectedPointers.clear(); // Clear selected image pointers
//   PhotoManager.releaseCache(); // 🔹 Release asset cache
//   triggerGC();
//   super.dispose();
// }


//   @override
//   Widget build(BuildContext context) {
//     return BaseScaffold(
//       appBar: AppBar(
//         title: Text(selectedAlbum == null ? "Select an Album" : selectedAlbum!.name),
//         key: const Key('gallery_body'),
//         leading: selectedAlbum == null
//       ? WidgetUtils.buildBackButton(context, AddImageScreen())
//       : SizedBox(),
//         actions: [
//           if (selectedAlbum != null)
//             IconButton(
//               icon: Icon(Icons.folder_open),
//               onPressed: resetAlbumSelection,
//             ),
//           if (selectedPointers.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.check),
//               onPressed: saveSelectedImages,
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             // based on the selected album I will show each image in memory
//             child: selectedAlbum == null
//                 ? ListView.builder(
//                     itemCount: albums.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(albums[index].name),
//                         onTap: () => fetchImages(albums[index]),
//                       );
//                     },
//                   )
//                   // if album not null then an album has been selected
//                 : NotificationListener<ScrollNotification>(
//                     onNotification: (ScrollNotification scrollInfo) {
//                       if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
//                         loadMoreImages();
//                       }
//                       return false;
//                     },
//                     child: GridView.builder(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//                       itemCount: images.length + (isLoading ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index == images.length) {
//                           return Center(child: CircularProgressIndicator());
//                         }
//                         return FutureBuilder<Uint8List?>(
//                           // here we grab what image the users selects
//                           future: images[index].thumbnailDataWithSize(ThumbnailSize(200, 200)),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                               bool isSelected = selectedPointers.contains(images[index].id);
                              
//                               return GestureDetector(
//                                 // per rendered image, per tap and image is selected
//                                 onTap: () => toggleSelection(images[index]),
//                                 child: Stack(
//                                   children: [
                                
//                                       ExtendedImage.memory(
//                                           snapshot.data!,
//                                           fit: BoxFit.cover,
//                                           width: double.infinity,
//                                           height: double.infinity,
//                                           clearMemoryCacheWhenDispose: true, // ✅ Clears memory when widget is removed
//                                         ),
                                  
//                                     if (isSelected)
//                                       Positioned(
//                                         top: 8,
//                                         right: 8,
//                                         child: Icon(Icons.check_circle, color: Colors.green, size: 30),
//                                       ),
//                                   ],
//                                 ),
//                               );
//                             }
//                             return SizedBox.shrink();
//                           },
//                         );
//                       },
//                     ),
//                   ),
//           ),
//           // have a notification displaying the amount of selected images
//           if (selectedPointers.isNotEmpty)
//             Container(
//               padding: EdgeInsets.all(16),
//               color: Colors.blue,
//               width: double.infinity,
//               child: Text(
//                 "Selected Images: ${selectedPointers.length}",
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_types.dart';
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

  void resetAlbumSelection() {
    setState(() {
      selectedAlbum = null;
      images.clear();
    });
  }


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
        title:  WidgetUtils.buildTitle(selectedAlbum == null ? GALLERY_CONSTANTS.title : selectedAlbum!.name),
        leading: WidgetUtils.buildBackButton(context, AddImageScreen()),
        // actions: [
        //   if (selectedAlbum != null)
        //     IconButton(
        //       icon: Icon(Icons.folder_open),
        //       onPressed: resetAlbumSelection,
        //     ),
        //   if (selectedPointers.isNotEmpty)
        //     IconButton(
        //       icon: Icon(Icons.check),
        //       onPressed: saveSelectedImages,
        //     ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
        child: Stack(
          children: [
            // White card
            Container(
              width: 350,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Subtitle
                  WidgetUtils.buildParagraph(
                    //selectedAlbum == null ? "Albums" : selectedAlbum!.name,
                    GALLERY_CONSTANTS.subTitle,
                    fontSize: WidgetUtils.titleFontSize_75,
                  
                  ),
                  Divider(color: DefaultColors.grey),
                  SizedBox(height: 16),
                  
                  
                  Expanded(
                    child: selectedAlbum == null
                        ? ListView.builder(
                            itemCount: albums.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                future: buildAlbum(albums[index].name, index), // Call the async function
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator()); // Loading indicator
                                  } else if (snapshot.hasError) {
                                    return SizedBox(); // Don't show album if no images
                                  } else {
                                    return snapshot.data as Widget; // Render the album widget
                                  }
                                },
                              );
                            },
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
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
                                    if (snapshot.connectionState == ConnectionState.done &&
                                        snapshot.hasData) {
                                      bool isSelected =
                                          selectedPointers.contains(images[index].id);

                                      return GestureDetector(
                                        onTap: () => toggleSelection(images[index]),
                                        child: Stack(
                                          children: [
                                            ExtendedImage.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              clearMemoryCacheWhenDispose: true,
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 30,
                                                ),
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
                  if (selectedPointers.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue,
                      width: double.infinity,
                      child: Text(
                        "Selected Images: ${selectedPointers.length}",
                        style: TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
