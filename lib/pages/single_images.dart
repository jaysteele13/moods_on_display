import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:image/image.dart' as img;

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
  final ImageManager _imageManager = ImageManager();
  List<EmotionBoundingBox> _emotionBoundingBoxes = [];
  bool _isLoading = false;
  bool _showBoundingBoxes = false; // Toggle state
  PageController controller = PageController();
  Uint8List currentEmotionImage = Uint8List(0);

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
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

Future<Uint8List> drawRectangleOnImage(
    String pointer, List<BoundingBox> boundingBoxes,
    int originalWidth, int originalHeight) async {

  // db call
  await _fetchEmotionBoundingBox(pointer);
  
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

  

  // Define the rectangle color (Orange)
  img.Color rectangleColor = img.ColorRgb8(255, 255, 0);

  // Draw all bounding boxes with adjusted scaling
  for (BoundingBox bbox in boundingBoxes) {
    // Original bounding box coordinates
  double originalX = bbox.x.toDouble();
  double originalY = bbox.y.toDouble();
  int originalWidth = bbox.width;
  int originalHeight = bbox.height;

  double boundingBoxLeft = bbox.x.toDouble();
  double boundingBoxTop = bbox.y.toDouble();
  double boundingBoxWidth = bbox.width.toDouble();
  double boundingBoxHeight = bbox.height.toDouble();

  int x = boundingBoxLeft.clamp(0.0, originalImageWidth).toInt();
  int y = boundingBoxTop.clamp(0.0, originalImageHeight).toInt();
  int width = boundingBoxWidth.clamp(0.0, originalImageWidth - x.toDouble()).toInt();
  int height = boundingBoxHeight.clamp(0.0, originalImageHeight - y.toDouble()).toInt();

  // Output the new scaled bounding box
  print("Scaled Bounding Box: ");
  print("bbx ${bbox.x}, ${bbox.y}, ${bbox.width}, ${bbox.height}");
    // img.drawRect(image, x1: newX.toInt(), y1: newY.toInt(), x2: newWidth.toInt(), y2: newHeight.toInt(), color: rectangleColor, thickness: 3);
    // img.drawRect(image, x1: bbox.x, y1: bbox.y, x2: bbox.width, y2: bbox.height, color: rectangleColor, thickness: 3);
    img.drawRect(image, x1: x, y1: y, x2: x + width,y2: y + height, color: rectangleColor, thickness: 3); 
  }

  // Encode the modified image back to Uint8List
  return Uint8List.fromList(img.encodeJpg(image));
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

Future<void> _toggleBoundingBoxes(int index, int width, int height) async {
    if (!_showBoundingBoxes) {
      Uint8List updatedImage = await drawRectangleOnImage(
        widget.images[index].pointer,
        _emotionBoundingBoxes.map((e) => e.boundingBox).toList(),
        width,
        height
      );
      setState(() {
        currentEmotionImage = updatedImage;
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
    Size screenSize = MediaQuery.of(context).size;

    return BaseScaffold(
      appBar: AppBar(title: Text(getEmojiByEmotion(widget.emotion))),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _toggleBoundingBoxes(index, screenSize.width.toInt(), screenSize.height.toInt()),
            child: Stack(
              children: [
                Center(
                  child: ExtendedImage.memory(
                    _showBoundingBoxes
                        ? currentEmotionImage
                        : widget.images[index].image,
                    fit: BoxFit.contain,
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

 
