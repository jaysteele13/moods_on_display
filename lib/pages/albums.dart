import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';

class AlbumScreen extends StatelessWidget {
  final List<String> emotions = EMOTIONS.albumList; // Define emotions list for albums

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: Text("Albums")),
      body: ListView.builder(
        itemCount: emotions.length,
        itemBuilder: (context, index) {
          String emotion = emotions[index];
          // build albums based on constants list
          return ListTile(
            title: Text(emotion.capitalize()),
            leading: Icon(Icons.folder, color: Colors.amber),
            onTap: () {
              // based on context and emotion album send to the image screen, where pointers will load.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagesScreen(emotion: emotion),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}

