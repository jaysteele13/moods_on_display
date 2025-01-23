import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';


class ModelManager {
  // this is to load and run the model using tflite_flutter
  late Interpreter interpreter;
  late FaceDetector faceDetector;

  List<Face> detectedFaces = [];  // Store detected faces

  ModelManager() {
    // loadModel / (s) initially
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
    // google face detector
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate, enableClassification: true);
    faceDetector = FaceDetector(options: options);
  }


Future<File> DisplayFaceDetectedImage(File selectedImage) async {
  img.Image image =  await performFaceDetection(selectedImage);
  File jpgImage = await getFaceDetectionJPEG(image);
  return jpgImage;
}


Future<img.Image> performFaceDetection(File selectedImage) async {
  // Load the input image
    InputImage inputImage = InputImage.fromFile(selectedImage);

  // Detect faces in the image
    final List<Face> faces = await faceDetector.processImage(inputImage);

  if (faces.isEmpty) {
    throw Exception("No faces detected in the image.");
  }

  // Load the image using the image package
  final imageBytes = await selectedImage.readAsBytes();
  img.Image? originalImage = img.decodeImage(imageBytes);

  if (originalImage == null) {
    throw Exception("Failed to load the image.");
  }

  // have confidence system, make more accurate, then include more faces

  // Get the first detected face's bounding box
  Face bestFace = faces.first;
  double highestConfidence = 0.0;

   for (Face face in faces) {
    if (face.trackingId != null && face.headEulerAngleY != null) {
      double confidenceScore = face.smilingProbability ?? 0.1; // Example confidence metric
      if (confidenceScore > highestConfidence) {
        highestConfidence = confidenceScore;
        bestFace = face;
      }
    }
  }

  final Rect boundingBox = bestFace.boundingBox;

  // Crop the face region from the image
  final int x = boundingBox.left.clamp(0, originalImage.width).toInt();
  final int y = boundingBox.top.clamp(0, originalImage.height).toInt();
  final int width = boundingBox.width.clamp(0, originalImage.width - x).toInt();
  final int height = boundingBox.height.clamp(0, originalImage.height - y).toInt();
  // final int x = boundingBox.left.toInt();
  // final int y = boundingBox.top.toInt();
  // final int width = boundingBox.width.toInt();
  // final int height = boundingBox.height.toInt();

  final img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);
  

  // Close the face detector
  faceDetector.close();
  print("Highest confidence face detected with score: $highestConfidence");
  // Return the cropped image file
  return croppedFace;
}

Future<File> getFaceDetectionJPEG(img.Image selectedImage) async {
  // Encode the cropped face image back to a file
  final croppedImageBytes = img.encodeJpg(selectedImage);
  // final croppedFilePath = "${selectedImage.parent.path}/cropped_face.jpg";
  // final croppedFile = File(croppedFilePath);
  // await croppedFile.writeAsBytes(croppedImageBytes);
  Directory tempDir = await getTemporaryDirectory();

  // Create a temporary file in the directory
  final timestamp = DateTime.now().millisecondsSinceEpoch; 
  File tempFile = File('${tempDir.path}/temp_image_$timestamp.jpg');

  // Write the JPG data to the temporary file
  await tempFile.writeAsBytes(croppedImageBytes);

  return tempFile;
}

Future<void> deleteTempFile(File file) async {
  if (await file.exists()) {
    await file.delete();
    print("Temporary file deleted: ${file.path}");
  }
}

  // returns a 2d list of emotions (results) on a singular image
  Future<List<Map<String, dynamic>>?> performEmotionDetection(File selectedImage) async {
    
    List<int> bytes = await selectedImage.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return null;

    // Resize the image to 224 for MobileNetv2
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Prepare input
    final imageMatrix = List.generate(
      resizedImage.height,
      (y) => List.generate(
        resizedImage.width,
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final input = [imageMatrix];
    var output = List.filled(7, 0).reshape([1, 7]);

    // Run inference
    interpreter.run(input, output);

    var percentages = calculateEmotionPercentages(output);

    return percentages;
  }

  List<Map<String, dynamic>> calculateEmotionPercentages(List<dynamic> data) {
    // FER labels for now, will be loading in labels.txt when othe rmodels are experiemented with
    List<String> emotionLabels = [
      'angry',
      'disgust',
      'fear',
      'happy',
      'neutral',
      'sad',
      'surprise'
    ];

    List<Map<String, dynamic>> result = [];

    for (var row in data) {
      double totalSum = row.fold(0, (sum, value) => sum + value);
      for (int i = 0; i < row.length; i++) {
        double percentage = (row[i] / totalSum) * 100;
        result.add({
          'emotion': emotionLabels[i],
          'percentage': percentage.toStringAsFixed(2),
        });
      }
    }

    return result;
  }
}
