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


Future<List<File>> displayFaceDetectedImage(File selectedImage) async {
  List<img.Image> images =  await performFaceDetection(selectedImage);
  List<File> jpgImages = (await getFaceDetectionJPEG(images));
  return jpgImages;
}


// return image array of faces
Future<List<img.Image>> performFaceDetection(File selectedImage) async {
  // Load the input image
    InputImage inputImage = InputImage.fromFile(selectedImage);

    final List<img.Image> facesList = [];
  // Detect faces in the image
    final List<Face> faces = await faceDetector.processImage(inputImage);

    // vars for face cropping
    Rect boundingBox;

  // Crop the face region from the image
    int x;
    int y;
    int width;
    int height;
    img.Image croppedFace;


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
  double highestConfidence = 0.0005;
  Face bestFace = faces.first;
  print("lenth of faces ${faces.length}");

   for (Face face in faces) {
      double confidenceScore = face.smilingProbability ?? 0.1; // Example confidence metric
      print("here is confidence score initially: ${confidenceScore}");
    if (confidenceScore > highestConfidence) {
        print(confidenceScore);
        bestFace = face;

        boundingBox = bestFace.boundingBox;

      // Crop the face region from the image
        x = boundingBox.left.clamp(0, originalImage.width).toInt();
        y = boundingBox.top.clamp(0, originalImage.height).toInt();
        width = boundingBox.width.clamp(0, originalImage.width - x).toInt();
        height = boundingBox.height.clamp(0, originalImage.height - y).toInt();

        croppedFace = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);

        facesList.add(croppedFace);
    }
  }

  faceDetector.close();
  // print("Highest confidence face detected with score: $highestConfidence");
  // Return the cropped image file
  print("facesList length: ${facesList.length}");
  return facesList;
}

Future<List<File>> getFaceDetectionJPEG(List<img.Image> selectedImages) async {
  // Encode the cropped face image back to a file
  List<File> files = [];
  int uniqueCounter = 0;
  if(selectedImages.isEmpty) print('no faces found');
  for (img.Image selectedImage in selectedImages) {
    Uint8List croppedImageBytes = img.encodeJpg(selectedImage);
  // final croppedFilePath = "${selectedImage.parent.path}/cropped_face.jpg";
  // final croppedFile = File(croppedFilePath);
  // await croppedFile.writeAsBytes(croppedImageBytes);
    Directory tempDir = await getTemporaryDirectory();

    // Create a temporary file in the directory
    File tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}_$uniqueCounter.jpg');
    uniqueCounter++;
    // Write the JPG data to the temporary file
    await tempFile.writeAsBytes(croppedImageBytes);

    files.add(tempFile);

  }
  return files;

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
