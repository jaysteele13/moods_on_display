import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';

class SingleImageView extends StatefulWidget {
  final List<ImagePointer> images;
  final int initialIndex;
  final String emotion;

  const SingleImageView({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.emotion,
  }) : super(key: key);

  @override
  _SingleImageViewState createState() => _SingleImageViewState();
}

class _SingleImageViewState extends State<SingleImageView> {
  List<EmotionBoundingBox> _emotionBoundingBoxes = [];
  bool isSelectionMode = false;
  bool _isLoading = false;

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
        return '❓';
    }
  }

  Future<void> _fetchEmotionBoundingBox(String pointer) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<EmotionBoundingBox> ebbx =
          await DatabaseManager.instance.getEmotionBoundingBoxesByPointer(pointer);
      setState(() {
        _emotionBoundingBoxes = ebbx;
      });
    } catch (e) {
      print("Error fetching bounding boxes: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: widget.initialIndex);

    return Scaffold(
      appBar: AppBar(title: Text(getEmojiByEmotion(widget.emotion))),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _fetchEmotionBoundingBox(widget.images[index].pointer),
            child: Stack(
              children: [
                Center(
                  child: ExtendedImage.memory(
                    widget.images[index].image,
                    fit: BoxFit.contain,
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ..._emotionBoundingBoxes.map((bbox) => Positioned(
                  left: bbox.boundingBox.x.toDouble(),
                  top: bbox.boundingBox.y.toDouble(),
                  child: Container(
                    width: bbox.boundingBox.width.toDouble(),
                    height: bbox.boundingBox.height.toDouble(),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ))
              ],
            ),
          );
        },
      ),
    );
  }
}
