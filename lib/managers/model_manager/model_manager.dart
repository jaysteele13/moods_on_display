import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'emotion_image.dart';
import 'dart:math';

// CONSTANTS
import 'package:moods_on_display/utils/constants.dart';


class ModelManager {
  // this is to load and run the model using tflite_flutter
  late Interpreter interpreter;
  late FaceDetector faceDetector;
  bool _isModelLoaded = false;

  List<Face> detectedFaces = [];  // Store detected faces

  ModelManager() {
    // loadModel / (s) initially
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (_isModelLoaded) return; // Prevent reloading
    interpreter = await Interpreter.fromAsset('assets/models/model_jay_m3_ft.tflite');
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
      ),
    );
    _isModelLoaded = true;
  }
  // -------------------------- Architecture --------------------------------

  Future<dynamic> modelArchitectureV2(FilePathPointer selectedFilePathPointer) async {

  FilePointer filePointer = FilePointer(file: File(selectedFilePathPointer.filePath), imagePointer: selectedFilePathPointer.imagePointer);

  // perhaps grab coordinates through faceDetection in a type that holds List<img.Image> List<BoudningBox>
  List<ImageBoundingBox> faceDetect = await performFaceDetection(filePointer);
  List<EmotionImage> emotionData = [];
  List<EmotionBoundingBox> emotionBoundingBoxData = [];
  // If no faces are found, return an empty result ->

  if (faceDetect.isEmpty) {
    return emotionData;
  }


  for (ImageBoundingBox face in faceDetect) {
    // Detect emotions for the face
    EmotionImage emotion = await performEmotionDetection(face.image);
    // Get face-specific image file (used only for per-face results)
    String filePath = await getFaceDetectionJPEGPath(face.image);

    // adds electedFilePath here
    emotion.selectedFilePathPointer = FilePathPointer(filePath: filePath, imagePointer: selectedFilePathPointer.imagePointer); // find way to pass down pointer

    // Find most common highest emotion
    emotion.mostCommonEmotion = findMostCommonHighestEmotion(emotion);

    // Add emotion to dataset here - need check to ensure assetId isn't the same
    // Add bounding box at the same time
    emotionData.add(emotion);
    emotionBoundingBoxData.add(EmotionBoundingBox(emotion: emotion.mostCommonEmotion!, boundingBox: face.boundingBox));
  }

  // DB call for image table
  await formatEmotionImagesWithDB(emotionData, selectedFilePathPointer);

  // DB call to add EmotionBoudingBox entries
  await DatabaseManager.instance.insertBoundingBoxes(selectedFilePathPointer.imagePointer, emotionBoundingBoxData);

  // Return either a list of per-face emotions or a single formatted EmotionImage
  return emotionData;
}
  // -------------------------- Face Detection --------------------------------

   Future<List<ImageBoundingBox>> performFaceDetection(FilePointer selectedImage) async {
    // Load the input image
      InputImage inputImage = InputImage.fromFile(selectedImage.file);

      final List<ImageBoundingBox> facesList = [];
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
      return facesList;
    }

    // Load the image using the image package
    final imageBytes = await selectedImage.file.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception("Failed to load the image.");
    }

    // Get the first detected face's bounding box
    double highestConfidence = 0.01;
    Face bestFace = faces.first;
    // print("lenth of faces ${faces.length}");

    for (Face face in faces) {
        double confidenceScore = face.smilingProbability ?? 0.1; // Example confidence metric
        // print("here is confidence score initially: $confidenceScore");
      if (confidenceScore > highestConfidence) {
          // print(confidenceScore);
          bestFace = face;

          boundingBox = bestFace.boundingBox;

        // Crop the face region from the image
          x = boundingBox.left.clamp(0, originalImage.width).toInt();
          y = boundingBox.top.clamp(0, originalImage.height).toInt();
          width = boundingBox.width.clamp(0, originalImage.width - x).toInt();
          height = boundingBox.height.clamp(0, originalImage.height - y).toInt();

          croppedFace = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);

          // add image and bounding box per face for later usage.
          facesList.add(ImageBoundingBox(image: croppedFace, boundingBox: BoundingBox(x: x, y: y, width: width, height: height)));
      }
    }

    faceDetector.close();
    // print("Highest confidence face detected with score: $highestConfidence");
    // Return the cropped image file
    // print("facesList length: ${facesList.length}");
    
    return facesList;
  }
 
  Future<String> getFaceDetectionJPEGPath(img.Image selectedImage) async {
    // Encode the cropped face image back to a file
    if(selectedImage.isEmpty) print('no faces found');
    
      Uint8List croppedImageBytes = img.encodeJpg(selectedImage);
      Directory tempDir = await getTemporaryDirectory();

      // Create a temporary file in the directory
      Random random = Random();
      int randomNumber = random.nextInt(10000); // Generates a random number between 0 and 999999

      // Create a temporary file with a unique name, including a random number and timestamp
      String fileName = 'temp_image_${DateTime.now().millisecondsSinceEpoch}_$randomNumber.jpg';
      File tempFile = File('${tempDir.path}/$fileName');
      // print(tempFile);
      // Write the JPG data to the temporary file
      await tempFile.writeAsBytes(croppedImageBytes);

    return tempFile.path;

  }

  // way to clear files after add to db, include pointer in emotionImage
  Future<void> deleteTempFile(File file) async {
  if (await file.exists()) {
    await file.delete();
    print("Temporary file deleted: ${file.path}");
  }
}

  // -------------------------- Emotion Detection --------------------------------

   Future<EmotionImage> performEmotionDetection(img.Image image) async {
    // Resize the image to 224 for MobileNetv2

    // Resize for some fer plus models FERPLUS 48
    int img_size = 224;
    img.Image resizedImage = img.copyResize(image, width: img_size, height: img_size);

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

    EmotionImage emotionImage = parseIntoEmotionImage(output);

    // return as EmotionImage

    return emotionImage;
  }



EmotionImage parseIntoEmotionImage(List<dynamic> data) {

  // // Affwild labels
  //   List<String> emotionLabels = [
  //   'neutral',
  //   'angry',
  //   'disgust',
  //   'fear',
  //   'happy',
  //   'sad',
  //   'surprise'
  // ];


  // FER labels (should match the data length)
  List<String> emotionLabels = [
    EMOTIONS.angry,
    EMOTIONS.disgust,
    EMOTIONS.fear,
    EMOTIONS.happy,
    EMOTIONS.neutral,
    EMOTIONS.sad,
    EMOTIONS.surprise
  ];

  // Check if data is empty or the inner lists have the wrong length
  if (data.isEmpty || data[0].length != emotionLabels.length) {
    print("Error: Data length does not match the number of emotion labels.");
    throw Exception("Data length does not match the number of emotion labels.");
  }

  // Sum of all the percentages from each nested list
  Map<String, double> totalEmotions = {};

  for (var row in data) {
    double totalSum = row.fold(0, (sum, value) => sum + value); // Sum each inner list

    for (int i = 0; i < row.length; i++) {
      double percentage = (row[i] / totalSum) * 100;
      totalEmotions[emotionLabels[i]] = (totalEmotions[emotionLabels[i]] ?? 0) + percentage;
    }
  }

  // Normalize the values to ensure they add up to 100% (if necessary)
  double total = totalEmotions.values.fold(0, (sum, value) => sum + value);
  if (total > 0) {
    totalEmotions.updateAll((key, value) => (value / total) * 100);
  }

  return EmotionImage(
    emotions: totalEmotions,
    valid: true,
  );
}


Future<EmotionImage> formatEmotionImagesWithDB(List<EmotionImage> emotionImages, FilePathPointer selectedFilePathPointer,) async{
  if (emotionImages.isEmpty) {
    throw Exception("Emotion image list is empty.");
  }

  Map<String, double> totalEmotions = {};
  Map<String, int> emotionCount = {};

  // Sum all emotion percentages
  for (var emotionImage in emotionImages) {
    String highest = emotionImage.highestEmotion;
    emotionCount[highest] = (emotionCount[highest] ?? 0) + 1;
    for (var entry in emotionImage.emotions.entries) {
      totalEmotions[entry.key] = (totalEmotions[entry.key] ?? 0) + entry.value;
    }
  }

  // Normalize to ensure total sums to 100%
  double sum = totalEmotions.values.reduce((a, b) => a + b);
  if (sum > 0) {
    totalEmotions.updateAll((key, value) => (value / sum) * 100);
  }

  String mostCommonEmotion = emotionCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // DATABASE
  // print('add to database this pointer: ${selectedFilePathPointer.imagePointer}');
  await DatabaseManager.instance.insertImage(selectedFilePathPointer.imagePointer, mostCommonEmotion);
  

  return EmotionImage(
    selectedFilePathPointer: selectedFilePathPointer,
    emotions: totalEmotions,
    valid: true,
    mostCommonEmotion: mostCommonEmotion
  );
}


String findMostCommonHighestEmotion(EmotionImage emotionImage) {
  Map<String, int> emotionCount = {};
  // Count occurrences of each highest emotion
    String highest = emotionImage.highestEmotion;
    emotionCount[highest] = (emotionCount[highest] ?? 0) + 1;
  // Find the emotion with the highest count
  String mostCommonEmotion = emotionCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  return mostCommonEmotion;
}

void dispose() {
  interpreter.close();
  // await faceDetector.close();
}


}
