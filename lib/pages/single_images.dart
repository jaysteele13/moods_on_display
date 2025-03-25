import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:image/image.dart' as img;
import 'package:moods_on_display/widgets/utils/utils.dart';

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
  final ImageManager _imageManager = ImageManager(assetEntityService: AssetEntityService());
  List<EmotionBoundingBox> _emotionBoundingBoxes = [];
  bool _isLoading = false;
  bool _showBoundingBoxes = false; // Toggle state
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
  }


   @override
  void dispose()  {
    // call function to delete all images based on
    _imageManager.releaseCache(); // ✅ Ensures cache is cleared when screen is disposed 
    _imageManager.listAndDeleteFiles();
    super.dispose();
  }

  

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

img.Color getEmotionColor(String emotion) {
  switch (emotion) {
    case EMOTIONS.happy:
      return img.ColorRgb8(255, 255, 0); // Yellow
    case EMOTIONS.sad:
      return img.ColorRgb8(0, 0, 255); // Blue
    case EMOTIONS.angry:
      return img.ColorRgb8(255, 0, 0); // Red
    case EMOTIONS.fear:
      return img.ColorRgb8(128, 0, 128); // Purple
    case EMOTIONS.disgust:
      return img.ColorRgb8(0, 128, 0); // Green
    case EMOTIONS.neutral:
      return img.ColorRgb8(128, 128, 128); // Grey
    case EMOTIONS.surprise:
      return img.ColorRgb8(255, 165, 0); // Orange
    default:
      return img.ColorRgb8(0, 0, 0); // Black (default)
  }
}


Future<Uint8List> drawRectangleOnImage(
    String pointer, List<EmotionBoundingBox> boundingBoxes,) async {

  // db call
  
  // Get the image file from the pointer
  File emotionFile = await _imageManager.getFilefromPointer(pointer);
  
  // Read the file as bytes
  Uint8List imageBytes = await emotionFile.readAsBytes();
  
  // Decode the image
  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) {
    throw Exception("Could not decode image");
  }


  // Original image and current image dimensions
  double originalImageWidth = image.width.toDouble();
  double originalImageHeight = image.height.toDouble();

  // Draw all bounding boxes with adjusted scaling
  for (EmotionBoundingBox bbox in boundingBoxes) {
    // Original bounding box coordinates

  img.Color rectangleColor = getEmotionColor(bbox.emotion);

  double boundingBoxLeft = bbox.boundingBox.x.toDouble();
  double boundingBoxTop = bbox.boundingBox.y.toDouble();
  double boundingBoxWidth = bbox.boundingBox.width.toDouble();
  double boundingBoxHeight = bbox.boundingBox.height.toDouble();

  int x = boundingBoxLeft.clamp(0.0, originalImageWidth).toInt();
  int y = boundingBoxTop.clamp(0.0, originalImageHeight).toInt();
  int width = boundingBoxWidth.clamp(0.0, originalImageWidth - x.toDouble()).toInt();
  int height = boundingBoxHeight.clamp(0.0, originalImageHeight - y.toDouble()).toInt();

  print('bbox: x: $x, y: $y, height: $height, width: $width');

    img.drawRect(image, x1: x, y1: y, x2: x + width,y2: y + height, color: rectangleColor, thickness: 6); 
    img.drawString(image, bbox.emotion, font: img.arial48, x: x, y: y-100, color: rectangleColor);
  }

  // Encode the modified image back to Uint8List
  // Encode the modified image back to Uint8List
  Uint8List modifiedImageBytes = Uint8List.fromList(img.encodeJpg(image));

  // After processing, delete the original file if it's no longer needed
  await emotionFile.delete(); // This will delete the image file from disk

  // Return the modified image bytes
  return modifiedImageBytes;
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
        _showBoundingBoxes = true; // Show bounding boxes after loading
      });
    } catch (e) {
      print("Error fetching bounding boxes: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _toggleBoundingBoxes(int index) async {
    if (!_showBoundingBoxes) {
      await _fetchEmotionBoundingBox(widget.images[index].pointer);
      Uint8List updatedImage = await drawRectangleOnImage(
        widget.images[index].pointer,
        _emotionBoundingBoxes,
      );
      setState(() {
         widget.images[index].image = updatedImage;
        _showBoundingBoxes = true;
      });
    } else {
      setState(() {
        _showBoundingBoxes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return BaseScaffold(
      appBar: Base.appBar(title: Text(getEmojiByEmotion(widget.emotion)), leading: WidgetUtils.buildBackButton(context, ImagesScreen(emotion: widget.emotion))),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _toggleBoundingBoxes(index),
            child: Stack(
              children: [
                Center(
                  child: ExtendedImage.memory(
                    _showBoundingBoxes
                        ? widget.images[index].image
                        : widget.images[index].image,
                    fit: BoxFit.contain,
                    key: Key('single_image_view'),
                    width: 800,
                    height: 500,
                  ),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}

 
