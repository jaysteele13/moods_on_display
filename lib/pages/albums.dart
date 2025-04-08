import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/album_manager/album_types.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/albums/albums_constant.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

class AlbumScreen extends StatelessWidget {
  final List<String> emotions = EMOTIONS.albumList; // Define emotions list for albums
  final AlbumManager albumManager = AlbumManager(assetEntityService: AssetEntityService(), photoManagerService: PhotoManagerService()); // Instance of AlbumManager


  Future<AlbumData> _fetchAlbumData(String albumName) async {
    // Grab first 1-5 images from database (image pointers)
    List<EmotionPointer> emotionPointers = await DatabaseManager.instance.getXImagesByEmotion(albumName, 4);

    // Map pointers to Uint8List
    List<Uint8List> images = [];
    for (EmotionPointer pointer in emotionPointers) {
      Uint8List? image = await albumManager.getImageByPointer(pointer.pointer, false);

      if (image == null) {
        continue; // Skip if image is null
      }
      images.add(image);
    }
    // Create AlbumData object
    AlbumData albumData = AlbumData(
      amount: emotionPointers.length,
      images: images,
    );
    // If the album has no images, return an empty AlbumData
    if (albumData.amount == 0) {
      return AlbumData(images: images, amount: 0);
    }

    // Return the album data
    return albumData;
  }


Future<Widget> _buildAlbum(String albumName, BuildContext context) async {
  AlbumData albumData = await _fetchAlbumData(albumName);

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagesScreen(emotion: albumName),
      ),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Album title and amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetUtils.buildTitle(
                    albumName,
                    fontSize: WidgetUtils.titleFontSize_75,
                    color: WidgetUtils.getColorByEmotion(albumName),
                  ),
                  SizedBox(height: 8),
                  WidgetUtils.buildParagraph(
                    "{color->G}${albumData.amount}{/color}",
                    fontSize: WidgetUtils.titleFontSize_75,
                    isCentered: false,
                  ),
                ],
              ),
            ),
            
            // Large first emoji
            WidgetUtils.buildTitle(
              WidgetUtils.getEmojiByText(albumName),
              fontSize: WidgetUtils.titleFontSize * 2,
            ),
            SizedBox(width: 4),

            // Right side: Only show images if available
            if (albumData.images != null && albumData.images!.isNotEmpty)
              SizedBox(
                width: 80,
                height: 70,
                child: Row(
                  children: [
                    

                    // Grid of smaller images
                    if (albumData.images!.isNotEmpty)
                      SizedBox(
                        width: 70,
                        height: 80,
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: albumData.images!.length > 5
                              ? 4
                              : albumData.images!.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ExtendedImage.memory(
                                albumData.images![index],
                                fit: BoxFit.fill,
                                width: 30,
                                height: 40,
                                clearMemoryCacheWhenDispose: true,
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
        SizedBox(height: 8),
        Divider(thickness: 1, color: DefaultColors.grey),
        SizedBox(height: 8),
      ],
    ),
  );
}

AppBar _buildAppBar (String title) {
  return Base.appBar(
  toolBarHeight: 100,
  backgroundColor: DefaultColors.background,
  title: Center( // Centers the content horizontally
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WidgetUtils.buildTitle(ALBUMS_CONSTANTS.title, fontSize: WidgetUtils.titleFontSize_75),
            SizedBox(height: 8),
            Divider(color: DefaultColors.grey),
          ],
        ),
      ),
  
  actions: [
    SizedBox(width: WidgetUtils.defaultToolBarHeight), // Invisible icon to take up space
    // Add actual action icons here if needed
  ],
);
}


@override
Widget build(BuildContext context) {
  return BaseScaffold(
    appBar: _buildAppBar(ALBUMS_CONSTANTS.title),
    key: const Key('album_body'),
    backgroundColor: DefaultColors.background,
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  width: WidgetUtils.containerWidth,
                  padding: EdgeInsets.all(WidgetUtils.defaultPadding),
                  decoration: WidgetUtils.containerDecoration,
                  child: ListView.builder(
                    itemCount: emotions.length,
                    itemBuilder: (context, index) {
                      String emotion = emotions[index];
                      return FutureBuilder<Widget>(
                        future: _buildAlbum(emotion.capitalize(), context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CupertinoActivityIndicator());
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return SizedBox(); // Gracefully handle errors or null data
                          } else {
                            return snapshot.data!;
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}


extension StringCapitalize on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}

