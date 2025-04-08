import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/albums/albums_constant.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

class AlbumEmotionAmount {
  final String emotion;
  final int amount;

  AlbumEmotionAmount(this.emotion, this.amount);
}

class AlbumScreen extends StatelessWidget {
  final List<String> emotions = EMOTIONS.albumList; // Define emotions list for albums
  final AlbumManager albumManager = AlbumManager(
    assetEntityService: AssetEntityService(),
    photoManagerService: PhotoManagerService(),
  ); // Instance of AlbumManager

  // Fetch albums and sort by the image count
  Future<List<AlbumEmotionAmount>> _fetchAndSortAlbums() async {
    List<AlbumEmotionAmount> albumData = [];

    for (String emotion in emotions) {
      int amount = await DatabaseManager.instance.getAmountOfImagesByEmotion(emotion);
      albumData.add(AlbumEmotionAmount(emotion, amount));
    }

    // Sort albums by amount in descending order
    albumData.sort((a, b) => b.amount.compareTo(a.amount));

    return albumData;
  }

  

  // Building individual album widget
  Widget _buildAlbum(String albumName, int amount, BuildContext context) {
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
              // Album title and count
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
                      "{color->G}$amount{/color}",
                      fontSize: WidgetUtils.titleFontSize_75,
                      isCentered: false,
                    ),
                  ],
                ),
              ),
              // Emoji
              WidgetUtils.buildTitle(
                WidgetUtils.getEmojiByText(albumName),
                fontSize: WidgetUtils.titleFontSize * 2,
              ),
              SizedBox(width: 4),
            ],
          ),
          SizedBox(height: 8),
          Divider(thickness: 1, color: DefaultColors.grey),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  // AppBar for AlbumScreen
  AppBar _buildAppBar(String title) {
    return Base.appBar(
      toolBarHeight: 70,
      backgroundColor: DefaultColors.background,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
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
                    child: FutureBuilder<List<AlbumEmotionAmount>>(
                      // snapshot data is AlbumEmotionAmount that is return which is used to sort folders.
                      future: _fetchAndSortAlbums(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CupertinoActivityIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return SizedBox(); // or an error message
                        }

                        List<AlbumEmotionAmount> sortedAlbums = snapshot.data!;

                        return ListView.builder(
                          itemCount: sortedAlbums.length,
                          itemBuilder: (context, index) {
                            final album = sortedAlbums[index];
                            return _buildAlbum(album.emotion.capitalize(), album.amount, context);
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
