import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/album_manager/selectedImagesManager.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/page_text/images/images_constants.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:moods_on_display/pages/single_images.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/utils/utils.dart';

class ImagesScreen extends StatefulWidget {
  final String emotion;
  final bool? allowHistory;

  const ImagesScreen({Key? key, required this.emotion, this.allowHistory} ) : super(key: key);

  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  List<EmotionPointer> _loadedImages = [];
  final AlbumManager albumManager = AlbumManager(assetEntityService: AssetEntityService(), photoManagerService: PhotoManagerService());
  late List<String> pointersToDelete = [];
  bool isSelectionMode = false;
  bool _isLoading = false;

  void _fetchImages() async {
  List<EmotionPointer> images = await DatabaseManager.instance.getImagesByEmotion(widget.emotion);
    setState(() {
      _loadedImages = images;
      _isLoading = false;
    });
  }

 

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

Map<String, Uint8List?> imageCache = {}; // Cache images

Widget _buildImageItem(EmotionPointer pointer) {
  return Padding(
    padding: const EdgeInsets.all(5),
      child: FutureBuilder<Uint8List?>(
    future: _getCachedImage(pointer.pointer),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting && !imageCache.containsKey(pointer.pointer)) {
        return CupertinoActivityIndicator();
      }
      if (snapshot.hasError) {
        return const SizedBox(
          width: 70,
          height: 70,
          child: Center(child: Icon(Icons.error, color: DefaultColors.red)),
        );
      }
      if (snapshot.hasData && snapshot.data != null) {
        return GestureDetector(
          key: const Key('single_image'),
          onTap: () => _onImageTap(pointer),
          onLongPress: () => _onImageLongPress(pointer.pointer),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ExtendedImage.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: 58,
                  height: 80,
                  clearMemoryCacheWhenDispose: true,
                ),
              ),
              if (pointersToDelete.contains(pointer.pointer))
                Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: DefaultColors.tickColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
            ],
          ),
        );
      }
      return const SizedBox(); // Handle if image is deleted.
    },
  ),
  );
}

Future<Uint8List?> _getCachedImage(String pointer) async {
  if (imageCache.containsKey(pointer)) {
    return imageCache[pointer];
  } else {
    Uint8List? imageData = await albumManager.getImageByPointer(pointer, false);
    imageCache[pointer] = imageData;
    return imageData;
  }
}

void _onImageLongPress(String pointer) {
  setState(() {
    isSelectionMode = true;
    toggleDeleteSelection(pointer);
  });
}

void _onImageTap(EmotionPointer pointer) async {
  if (isSelectionMode) {
    // If in selection mode, just toggle the selection
    toggleDeleteSelection(pointer.pointer);
  } else {
    // Otherwise, open the image in full view
    List<ImagePointer> imageDataList = [];
    for (var ptr in _loadedImages) {
      if (!imageCache.containsKey(ptr.pointer)) {
        Uint8List? imageData = await albumManager.getImageByPointer(ptr.pointer, false);
        imageCache[ptr.pointer] = imageData; // Cache for later use
      }
      if (imageCache[ptr.pointer] != null) {
        imageDataList.add(ImagePointer(image: imageCache[ptr.pointer]!, pointer: ptr.pointer));
      }
    }

    // send to single image view
    if (imageDataList.isNotEmpty) {
      int selectedIndex = _loadedImages.indexOf(pointer);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleImageView(
            images: imageDataList,
            initialIndex: selectedIndex,
            emotion: widget.emotion
          ),
        ),
      );
    }
  }
}

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
  // function that is a for loop that looks through local database and selectivly removes pointers in toDelete
  await DatabaseManager.instance.deleteImageRecords(pointersToDelete);

  setState(() {
    selectedPointers.removeWhere((p) => pointersToDelete.contains(p.pointer));
    pointersToDelete.clear();
    isSelectionMode = false;
  });
  
}

void toggleSelectionMode() {
  setState(() {
    // pointersToDelete.clear();
    isSelectionMode = true;
  });
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

// Works based around selection mode state
Widget _buildSelectButton() {
  return  Padding (
    padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
  child: Container(
    padding: EdgeInsets.all(4),
    constraints: BoxConstraints(maxWidth: 55, maxHeight: 25),
    decoration: BoxDecoration(
      color: !isSelectionMode ? DefaultColors.selectButtonColor : DefaultColors.red,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: GestureDetector(
            onTap: !isSelectionMode ? toggleSelectionMode : cancelSelection, // clear selection and go back to select
            child: WidgetUtils.buildParagraph(!isSelectionMode ? IMAGE_CONSTANTS.select : IMAGE_CONSTANTS.cancel,
            fontSize: WidgetUtils.paragraphFontSize_875,
            isCentered: true,)
          )
  ),
  );
}

AppBar _buildAppBar(BuildContext context) {
    return Base.appBar(
      toolBarHeight: WidgetUtils.defaultToolBarHeight,
      backgroundColor: DefaultColors.background,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
       
            WidgetUtils.buildTitle(widget.emotion, fontSize: WidgetUtils.titleFontSize_75),
            
            
          ],
        ),
      ),
      actions: [
        //SizedBox(width: WidgetUtils.defaultToolBarHeight), // Invisible icon to take up space
        // Add actual action icons here if needed
         _buildSelectButton(),
         if (widget.allowHistory != null && widget.allowHistory == true)
            IconButton(
              icon: Icon(Icons.folder_copy_outlined),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
      ],
      leading: WidgetUtils.buildBackButton(context, AlbumScreen())
    );
  }

@override
Widget build(BuildContext context) {
  return BaseScaffold(
    backgroundColor: DefaultColors.background,
    appBar: _buildAppBar(context),
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              WidgetUtils.defaultPadding, 0, WidgetUtils.defaultPadding, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadedImages.isEmpty
                        ? Center(child: WidgetUtils.buildParagraph("{color->D,b,u}No images{/color} found for this emotion"))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: DefaultColors.grey),
                              SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: (_loadedImages.length / 5).ceil(),
                                  itemBuilder: (context, rowIndex) {
                                    int startIndex = rowIndex * 5;
                                    int endIndex = (startIndex + 5 > _loadedImages.length)
                                        ? _loadedImages.length
                                        : startIndex + 5;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: _loadedImages
                                          .sublist(startIndex, endIndex)
                                          .map((pointer) => _buildImageItem(pointer))
                                          .toList(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              // You can add `buildSelectionActions(_loadedImages)` here if needed
                            ],
                          ),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: DatabaseManager.instance.deleteDatabaseFile,
              //   child: const Text("Delete Database"),
              // ),
            ],
          ),
        ),
        if (pointersToDelete.isNotEmpty)
          AnimatedSelectedImagesNotification(
            isVisible: pointersToDelete.isNotEmpty,
            selectedCount: pointersToDelete.length,
            onFunctionButtonText: IMAGE_CONSTANTS.delete,
            onDelete: () async => await deleteSelectedImages(_loadedImages),
          ),
      ],
    ),
  );
}

}
