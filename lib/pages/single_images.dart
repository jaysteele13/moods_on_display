import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/image_manager/staggered_container.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/page_text/single_image/single_image_constant.dart';
import 'package:moods_on_display/pages/images.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:image/image.dart' as img;
import 'package:moods_on_display/utils/utils.dart';
import 'package:flutter/cupertino.dart';

enum EmotionState {
  preReveal,
  midDraw,
  postDraw,
}


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

  int _currentPageIndex = 0;
  PageController controller = PageController();
  late List<EmotionState> _emotionStates;


  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);

    // Set all widgets to preReveal state
     _emotionStates = List.filled(widget.images.length, EmotionState.preReveal);
    _currentPageIndex = widget.initialIndex;
  }


   @override
  void dispose()  {
    // call function to delete all images based on
    _imageManager.releaseCache(); // Ensures cache is cleared when screen is disposed 
    _imageManager.listAndDeleteFiles();
    super.dispose();
  }

img.Color getEmotionColor(String emotion) {
  switch (emotion) {
    case EMOTIONS.happy:
      return DefaultColors.rgbYellow; // Yellow
    case EMOTIONS.sad:
      return DefaultColors.rgbBlue;
    case EMOTIONS.angry:
      return DefaultColors.rgbRed; // Red
    case EMOTIONS.fear:
      return DefaultColors.rgbPurple; // Purple
    case EMOTIONS.disgust:
      return DefaultColors.rgbGreen; // Green
    case EMOTIONS.neutral:
      return DefaultColors.rgbNeutral; // Grey
    case EMOTIONS.surprise:
      return DefaultColors.rgbOrange; // Orange
    default:
      return img.ColorRgb8(0, 0, 0); // Black (default)
  }
}

Color _getEmotionColor(String emotion) {
  switch (emotion) {
    case EMOTIONS.happy:
      return DefaultColors.yellow_rect;
    case EMOTIONS.sad:
      return DefaultColors.blue;
    case EMOTIONS.angry:
      return DefaultColors.red;
    case EMOTIONS.fear:
      return DefaultColors.purple;
    case EMOTIONS.disgust:
      return DefaultColors.lightGreen;
    case EMOTIONS.neutral:
      return DefaultColors.neutral;
    case EMOTIONS.surprise:
      return DefaultColors.orange;
    default:
      return Colors.black; // Fallback color
  }
}

double _generateBoxThickness(double imgWidth, double imgHeight) {

  // Calculate the thickness based on the image dimensions
  double total = imgWidth + imgHeight;
  
  if (total < 1000) {
    return 1; // Default thickness
  }
  else if (total < 2000) {
    return 5; // Medium thickness
  }
  else if (total < 3000) {
    return 10; // Thick
  }
  else if (total < 4000) {
    return 15; // Thicker
  }
  else if (total < 5000) {
    return 20; // Thickest
  }
  else if (total < 6000) {
    return 25; // Thickest
  }
  else if (total < 7000) {
    return 30; // Thickest
  }
  else if (total < 8000) {
    return 35; // Thickest
  }
  else if (total < 9000) {
    return 40; // Thickest
  }
  else if (total < 10000) {
    return 45; // Thickest
  }
  else {
    return 50; // Thickest
  }
}

double _generateFontSize(double thickness) {
  // Calculate the font size based on the thickness
  if (thickness < 5) {
    return 60; // Small font size
  } else if (thickness < 10) {
    return 80; // Medium font size
  } else if (thickness < 15) {
    return 100; // Large font size
  } else if (thickness < 20) {
    return 120; // Larger font size
  } else {
    return 150; // Largest font size
  }
}

Future<Uint8List> drawRectangleOnImage(
    String pointer, List<EmotionBoundingBox> boundingBoxes) async {
  // Get the original image file
  File emotionFile = await _imageManager.getFilefromPointer(pointer);
  Uint8List imageBytes = await emotionFile.readAsBytes();

  // Decode to ui.Image
  ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  ui.Image originalImage = frameInfo.image;

  final width = originalImage.width;
  final height = originalImage.height;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

  // Draw original image as base
  canvas.drawImage(originalImage, Offset.zero, Paint());

  double thickness = _generateBoxThickness(width.toDouble(), height.toDouble());
  double fontSize = _generateFontSize(thickness);

  // Draw rectangles and emotion text
  for (EmotionBoundingBox bbox in boundingBoxes) {
    final paint = Paint()
      ..color = _getEmotionColor(bbox.emotion)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final rect = Rect.fromLTWH(
      bbox.boundingBox.x.toDouble(),
      bbox.boundingBox.y.toDouble(),
      bbox.boundingBox.width.toDouble(),
      bbox.boundingBox.height.toDouble(),
    );

    canvas.drawRect(rect, paint);

   Color rectangleColor = _getEmotionColor(bbox.emotion);

    // Draw text with TextPainter
    final textSpan = TextSpan(
      text: bbox.emotion,
      style: TextStyle(
        color: rectangleColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 20, rect.top - 250)); // draw text above box
  }

  // Finalize
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  await emotionFile.delete(); // Clean up

  img.dispose();

  return pngBytes;
}

// Future<Uint8List> drawRectangleOnImage(
//     String pointer, List<EmotionBoundingBox> boundingBoxes,) async {


//   // db call
  
//   // Get the image file from the pointer
//   File emotionFile = await _imageManager.getFilefromPointer(pointer);
  
//   // Read the file as bytes
//   Uint8List imageBytes = await emotionFile.readAsBytes();
  
//   // Decode the image
//   img.Image? image = img.decodeImage(imageBytes);
//   if (image == null) {
//     throw Exception("Could not decode image");
//   }


//   // Original image and current image dimensions
//   double originalImageWidth = image.width.toDouble();
//   double originalImageHeight = image.height.toDouble();

//   // Draw all bounding boxes with adjusted scaling
//   for (EmotionBoundingBox bbox in boundingBoxes) {
//     // Original bounding box coordinates

//   img.Color rectangleColor = getEmotionColor(bbox.emotion);

//   double boundingBoxLeft = bbox.boundingBox.x.toDouble();
//   double boundingBoxTop = bbox.boundingBox.y.toDouble();
//   double boundingBoxWidth = bbox.boundingBox.width.toDouble();
//   double boundingBoxHeight = bbox.boundingBox.height.toDouble();

//   int x = boundingBoxLeft.clamp(0.0, originalImageWidth).toInt();
//   int y = boundingBoxTop.clamp(0.0, originalImageHeight).toInt();
//   int width = boundingBoxWidth.clamp(0.0, originalImageWidth - x.toDouble()).toInt();
//   int height = boundingBoxHeight.clamp(0.0, originalImageHeight - y.toDouble()).toInt();

//   print('bbox: x: $x, y: $y, height: $height, width: $width');

//   int thickness = _generateBoxThickness(originalImageWidth, originalImageHeight);

//   img.drawRect(image, x1: x, y1: y, x2: x + width,y2: y + height, color: rectangleColor, thickness: thickness); 
//   img.drawString(image, bbox.emotion, font: img.arial48, x: x, y: y-100, color: rectangleColor);
//   }

//   // Encode the modified image back to Uint8List
//   Uint8List modifiedImageBytes = Uint8List.fromList(img.encodeJpg(image));

//   // After processing, delete the original file if it's no longer needed
//   await emotionFile.delete(); // This will delete the image file from disk

//   // Return the modified image bytes
//   return modifiedImageBytes;
// }



  Future<void> _fetchEmotionBoundingBox(String pointer) async {
    try {
      
  
      List<EmotionBoundingBox> ebbx =
          await DatabaseManager.instance.getEmotionBoundingBoxesByPointer(pointer);
      if (!mounted) return;
      setState(() {
        _emotionBoundingBoxes = ebbx;
      });
    } catch (e) {
      print("Error fetching bounding boxes: $e");
    }
  }

Future<void> _toggleBoundingBoxes(int index) async {
    if (_emotionStates[index] == EmotionState.preReveal) {
      if (!mounted) return;
      setState(() {
        _emotionStates[index] = EmotionState.midDraw;
      });
      // Fetch bounding boxes and draw them on the image
      await _fetchEmotionBoundingBox(widget.images[index].pointer);
      Uint8List updatedImage = await drawRectangleOnImage(
        widget.images[index].pointer,
        _emotionBoundingBoxes,
      );
      if (!mounted) return;
      setState(() {
         widget.images[index].image = updatedImage;
        _emotionStates[index] = EmotionState.postDraw;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _emotionStates[index] = EmotionState.preReveal;
      });
      // Optionally, you can revert the image to its original state here
      // For example, by reloading the original image from the pointer
      File originalImage = await _imageManager.getFilefromPointer(widget.images[index].pointer);
      Uint8List originalImageBytes = await originalImage.readAsBytes();

      // Erase file from memory after getting bytes
      await originalImage.delete();
      
      if (!mounted) return;
      setState(() {
        widget.images[index].image = originalImageBytes;
      });
    }
  }


String _textForStateButton(int index) {
  switch (_emotionStates[index]) {
    case EmotionState.preReveal:
      return SINGLE_IMAGE_CONSTANTS.reveal;
    case EmotionState.midDraw:
      return SINGLE_IMAGE_CONSTANTS.drawing;
    case EmotionState.postDraw:
      return SINGLE_IMAGE_CONSTANTS.hide;
  }
}


Widget _buildRevealEmotionsButton(int index) {

  bool _isDisabled =_emotionStates[index] == EmotionState.midDraw ? true:false;
     
  
  return ElevatedButton(
    onPressed: () => _isDisabled ? null : _toggleBoundingBoxes(index),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero, // remove default padding so gradient fills full area
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      backgroundColor: Colors.transparent, // important: let gradient show through
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    child: Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DefaultColors.green,
            DefaultColors.blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        alignment: Alignment.center,
        child: WidgetUtils.buildParagraph(
          _textForStateButton(index),
          fontSize: WidgetUtils.titleFontSize,
        ),
      ),
    ),
  );
}


  AppBar _buildAppBar() {
    return Base.appBar(
      toolBarHeight: WidgetUtils.defaultToolBarHeight,
      backgroundColor: DefaultColors.background,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WidgetUtils.buildTitle(WidgetUtils.getEmojiByText(widget.emotion), fontSize: WidgetUtils.titleFontSize),
          ],
        ),
      ),
      actions: [
        SizedBox(width: WidgetUtils.defaultToolBarHeight), // Invisible icon to take up space
        // Add actual action icons here if needed
      ],
      leading: WidgetUtils.buildBackButton(context, ImagesScreen(emotion: widget.emotion))
    );
  }


Widget _buildImage(int index) {

  return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ExtendedImage.memory(
                      _emotionStates[index] == EmotionState.midDraw
                          ? widget.images[index].image
                          : widget.images[index].image,
                      fit: BoxFit.cover,
                      key: const Key('single_image_view'),
                      width: 800,
                      height: 450,
                    ),
                  ),
                ],)));
}



@override
Widget build(BuildContext context) {
  return BaseScaffold(
    backgroundColor: DefaultColors.background,
    appBar: _buildAppBar(),
    body: Stack(
  children: [
    Padding(
      padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Viewer (swipable)
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final state = _emotionStates[index];

                Widget content;

                switch (state) {
                  case EmotionState.preReveal:
                    content = _buildImage(index); // default image
                    break;
                  case EmotionState.midDraw:
                    content = StaggeredContainer(); //_loadingBoundingBoxes(index);
                    break;
                  case EmotionState.postDraw:
                    content = _buildImage(index);  // image with drawn emotions
                    break;
                }

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: content,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed Row below the image viewer
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRevealEmotionsButton(_currentPageIndex),
              Container(height: 50, width: 1, color: DefaultColors.grey),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                iconSize: 48,
                onPressed: () {
                  // share logic here
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ],
),
  );
}
}