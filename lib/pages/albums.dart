import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/page_text/albums/albums_constant.dart';
import 'package:moods_on_display/pages/alert.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/utils.dart';


class AlbumEmotionAmount {
  final String emotion;
  final int amount;

  AlbumEmotionAmount(this.emotion, this.amount);
}

class AlbumScreen extends StatefulWidget {
  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}


class _AlbumScreenState extends State<AlbumScreen> {
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
 void _onAlbumTap(String albumName, BuildContext context) {
    print('Album tapped: $albumName');
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagesScreen(emotion: albumName),
      ));
    // Here, you can perform any action you need when an album is tapped.
  }

  // Building individual album widget with tap area detection
 // Building individual album widget with tap area detection
  Widget _buildAlbum(String albumName, int amount, BuildContext context) {
    return GestureDetector(
      onTap: () => _onAlbumTap(albumName, context),  // Handle tap event for the entire album container
      child: Container(  // Wrap the entire album section in a Container that can be tapped
        padding: EdgeInsets.all(WidgetUtils.defaultPadding / 2),  // Optional padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),  // Optional rounded corners
          color: Colors.white,  // Background color for the album
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
                GestureDetector(
                  onTap: () => _onAlbumTap(albumName, context),  // Optional to add specific tap action for emoji
                  child: WidgetUtils.buildTitle(
                    WidgetUtils.getEmojiByText(albumName),
                    fontSize: WidgetUtils.titleFontSize * 2,
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
            SizedBox(height: 8),
            Divider(thickness: 1, color: DefaultColors.grey),
            
          ],
        ),
      ),
    );
  }

   void _openInfo() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => AlertScreen(title: ALBUMS_CONSTANTS.infoTitle, paragraph: ALBUMS_CONSTANTS.infoParagraphs, icons: false,),
    );
  }

  // AppBar for AlbumScreen
  AppBar _buildAppBar(String title) {
    return Base.appBar(
      toolBarHeight: WidgetUtils.defaultToolBarHeight,
      backgroundColor: DefaultColors.background,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            WidgetUtils.buildTitle(ALBUMS_CONSTANTS.title, fontSize: WidgetUtils.titleFontSize_75),
            IconButton(onPressed: _openInfo, icon: Icon(Icons.info_outline,), padding: EdgeInsets.zero,),
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
