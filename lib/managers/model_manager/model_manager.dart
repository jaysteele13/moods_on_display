import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'emotion_image.dart';


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
  // -------------------------- Architecture --------------------------------

   Future<EmotionImage> modelArchitecture(File selectedImage) async {
    // Load image through Face Detection
    List<img.Image> faceDetect = await performFaceDetection(selectedImage);

    // Check if there are faces, if yes proceed to next step... if not return an empty object
    if(faceDetect.isEmpty) {
        return EmotionImage(
        selectedImage: selectedImage,
        // this is Map<String, double> 
        emotions: {
        },
        valid: false
      );
    } else {

    List<EmotionImage> emotionData = [];
    // predict emotions per face
    for (img.Image faces in faceDetect) {
      EmotionImage emotion =  await performEmotionDetection(faces);
      emotionData.add(emotion);
    }

    /*
    if showEmotionPerFace = true
      List<EmotionImage>
     */

    // We now iterate through this list and compare the highest emotions, whichever emotion appears the most, select that emotion
    EmotionImage finalDetection = formatEmotionImages(emotionData, selectedImage);
    // face_detect is a list of img.Images

    return finalDetection;

    }

  } 

   Future<List<EmotionImage>?> modelArchitectureEmotionPerFace(File selectedImage) async {
    // Load image through Face Detection
    List<img.Image> faceDetect = await performFaceDetection(selectedImage);

    // Check if there are faces, if yes proceed to next step... if not return an empty object
    if(faceDetect.isEmpty) {
        return null;
    } else {

    List<EmotionImage> emotionData = [];
    // predict emotions per face
    for (img.Image faces in faceDetect) {
    // get file for face
      File faceDetectionJPEG = await getFaceDetectionJPEG(faces);
      EmotionImage emotion =  await performEmotionDetection(faces);

      emotion.selectedImage = faceDetectionJPEG;

      // function to get most common emotion
      String commonEmotion = findMostCommonHighestEmotion(emotion);

      emotion.mostCommonEmotion = commonEmotion;

      emotionData.add(emotion);
    }

    return emotionData;

    }

  } 

  Future<dynamic> modelArchitectureV2(File selectedImage, {bool perFace = false}) async {
  // Load image through Face Detection
  List<img.Image> faceDetect = await performFaceDetection(selectedImage);

  // If no faces are found, return an empty result
  if (faceDetect.isEmpty) {
    return perFace ? <EmotionImage>[] : EmotionImage(selectedImage: selectedImage, emotions: {}, valid: false);
  }

  List<EmotionImage> emotionData = [];

  for (img.Image face in faceDetect) {
    // Get face-specific image file (used only for per-face results)
    File faceDetectionJPEG = await getFaceDetectionJPEG(face);
    
    // Detect emotions for the face
    EmotionImage emotion = await performEmotionDetection(face);
    emotion.selectedImage = faceDetectionJPEG;

    // Find most common highest emotion
    emotion.mostCommonEmotion = findMostCommonHighestEmotion(emotion);
    
    emotionData.add(emotion);
  }

  // Return either a list of per-face emotions or a single formatted EmotionImage
  return perFace ? emotionData : formatEmotionImages(emotionData, selectedImage);
}


  // -------------------------- Face Detection --------------------------------

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

  Future<File> displayFaceDetectedImage(img.Image images) async {
    File jpgImage = (await getFaceDetectionJPEG(images));
    return jpgImage;
  }


  // return image array of faces
 

  Future<File> getFaceDetectionJPEG(img.Image selectedImage) async {
    // Encode the cropped face image back to a file
    int uniqueCounter = 0;
    if(selectedImage.isEmpty) print('no faces found');
    
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

    
    return tempFile;

  }

  Future<void> deleteTempFile(File file) async {
  if (await file.exists()) {
    await file.delete();
    print("Temporary file deleted: ${file.path}");
  }
}

  // -------------------------- Emotion Detection --------------------------------

   Future<EmotionImage> performEmotionDetection(img.Image image) async {

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

    EmotionImage emotionImage = parseIntoEmotionImage(output);

    // return as EmotionImage

    return emotionImage;
  }



EmotionImage parseIntoEmotionImage(List<dynamic> data) {
  // FER labels (should match the data length)
  List<String> emotionLabels = [
    'angry',
    'disgust',
    'fear',
    'happy',
    'neutral',
    'sad',
    'surprise'
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


EmotionImage formatEmotionImages(List<EmotionImage> emotionImages, File selectedImage,) {
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

  return EmotionImage(
    selectedImage: selectedImage,
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

}
