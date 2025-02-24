import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/constants.dart';

class SingleImageView extends StatelessWidget {
  final List<Uint8List> images;
  final int initialIndex;
  final String emotion;

  const SingleImageView({Key? key, required this.images, required this.initialIndex, required this.emotion}) : super(key: key);

  String getEmojiByEmotion(String emotion) {
  switch (emotion) {
    case EMOTIONS.angry:
      return '😡';
    case EMOTIONS.disgust:
      return '🤢';
    case EMOTIONS.fear:
      return '😱';
    case EMOTIONS.happy:
      return '😊';
    case EMOTIONS.neutral:
      return '😐';
    case EMOTIONS.sad:
      return '😢';
    case EMOTIONS.surprise:
      return '😮';
    default:
      return '❓'; // Default case for unknown emotions
  }
}


  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      appBar: AppBar(title: Text(getEmojiByEmotion(emotion))),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: ExtendedImage.memory(
              images[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
