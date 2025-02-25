// import 'dart:io';
// import 'dart:typed_data';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:moods_on_display/managers/image_manager/image_manager.dart';
// import 'package:moods_on_display/utils/types.dart';
// import 'package:image/image.dart' as img;

// class EmotionBoundingBoxWidget extends StatefulWidget {
//   final String pointer;
//   final List<EmotionBoundingBox> boundingBoxes;

//   const EmotionBoundingBoxWidget({
//     Key? key,
//     required this.pointer,
//     required this.boundingBoxes,
//   }) : super(key: key);

//   @override
//   _EmotionBoundingBoxWidgetState createState() => _EmotionBoundingBoxWidgetState();
// }

// class _EmotionBoundingBoxWidgetState extends State<EmotionBoundingBoxWidget> {
//   Uint8List? imageBytes;
//   List<BoundingBox> correctedBoundingBoxes = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCorrectedImage();
//   }

//   Future<void> _loadCorrectedImage() async {
//     var result = await getCorrectedBoundariesAndImage(widget.pointer, widget.boundingBoxes.map(toElement).toList());
//     setState(() {
//       imageBytes = result["imageBytes"];
//       correctedBoundingBoxes = List<BoundingBox>.from(result["correctedBoundingBoxes"]);
//     });
//   }

//   Future<Map<String, dynamic>> getCorrectedBoundariesAndImage(
//       String pointer, List<BoundingBox> boundingBoxes) async {
//     ImageManager imageManager = ImageManager();

//     // Get the image file from the pointer
//     File emotionFile = await imageManager.getFilefromPointer(pointer);
//     Uint8List imageBytes = await emotionFile.readAsBytes();

//     // Decode the image
//     img.Image? image = img.decodeImage(imageBytes);
//     if (image == null) {
//       throw Exception("Could not decode image");
//     }

//     // Define high-definition scaling factor (2x resolution)
//     int targetWidth = (image.width * 2).clamp(0, 4000);
//     int targetHeight = (image.height * 2).clamp(0, 4000);

//     // Resize the image for HD quality
//     img.Image hdImage = img.copyResize(image, width: targetWidth, height: targetHeight);

//     // Scaling factors
//     double scaleX = targetWidth / image.width;
//     double scaleY = targetHeight / image.height;

//     // Define the rectangle color (Orange)
//     img.Color rectangleColor = img.ColorRgb8(255, 165, 0);

//     // Corrected bounding boxes
//     List<BoundingBox> correctedBoundingBoxes = [];

//     for (BoundingBox bbox in boundingBoxes) {
//       double newX = bbox.x * scaleX;
//       double newY = bbox.y * scaleY;
//       double newWidth = bbox.width * scaleX;
//       double newHeight = bbox.height * scaleY;

//       correctedBoundingBoxes.add(
//         BoundingBox(
//           x: newX.toInt(),
//           y: newY.toInt(),
//           width: newWidth.toInt(),
//           height: newHeight.toInt(),
//         ),
//       );

//       img.drawRect(
//         hdImage,
//         x1: newX.toInt(),
//         y1: newY.toInt(),
//         x2: (newX + newWidth).toInt(),
//         y2: (newY + newHeight).toInt(),
//         color: rectangleColor,
//         thickness: 6,
//       );
//     }

//     // Encode the high-definition modified image back to Uint8List
//     Uint8List modifiedImageBytes = Uint8List.fromList(img.encodeJpg(hdImage, quality: 100));

//     // Optional: Delete the original file (commented for debugging)
//     // await emotionFile.delete();

//     return {
//       "imageBytes": modifiedImageBytes,
//       "correctedBoundingBoxes": correctedBoundingBoxes,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (imageBytes == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Stack(
//       children: [
//         ExtendedImage.memory(imageBytes!, fit: BoxFit.cover),
//         ...correctedBoundingBoxes.map((box) => Positioned(
//               left: box.x.toDouble(),
//               top: box.y.toDouble(),
//               child: CustomPaint(
//                 painter: BoundingBoxPainter(box),
//               ),
//             )),
//       ],
//     );
//   }
// }

// class BoundingBoxPainter extends CustomPainter {
//   final BoundingBox box;

//   BoundingBoxPainter(this.box);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.orange
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke;

//     Rect rect = Rect.fromLTWH(box.x.toDouble(), box.y.toDouble(), box.width.toDouble(), box.height.toDouble());
//     canvas.drawRect(rect, paint);

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: "Emotion", // Modify this if you have a label
//         style: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//       textDirection: TextDirection.ltr,
//     );

//     textPainter.layout();
//     textPainter.paint(canvas, Offset(box.x.toDouble(), box.y - 20));
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
