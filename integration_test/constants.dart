import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:moods_on_display/utils/constants.dart';

class DETECTION_TEST {
  static const emotion_test_album = 'test_album';
  static const emotion_test_album2 = 'test_album2';
  static const emotion_test_album3 = 'test_album3';
  static const emotion_test_album4 = 'test_album4';

  static Model_Benchmark benchmark1 = Model_Benchmark(
  // should be 23 Images
  albumName: emotion_test_album,
  anger: 1,
  disgust: 2, 
  fear: 3,
  happy: 10, 
  neutral: 4,
  sad: 1, 
  surprise: 2,
  
);

static Model_Benchmark benchmark2 = Model_Benchmark(
  // 37 faces
  albumName: emotion_test_album2,
  anger: 3,
  disgust: 2,
  fear: 9,
  happy: 14,
  neutral: 4,
  sad: 2,
  surprise: 3,
);

static Model_Benchmark benchmark3 = Model_Benchmark(
  // 29 Faces
  albumName: emotion_test_album3,
  anger: 1, // 2
  disgust: 4, // 4
  fear: 2, // 2
  happy: 11, // 11
  neutral: 4, // 4
  sad: 4, // 3
  surprise: 3, // 3
);

static Model_Benchmark benchmark4 = Model_Benchmark(
  // 29 Faces
  albumName: emotion_test_album4, // Will be Aff-Wild from internet,
  anger: 4,
  disgust: 0,
  fear: 1,
  happy: 6,
  neutral: 2,
  sad: 3,
  surprise: 1,
);


  
}
class BBOX_TEST {
  Future<img.Image> loadTestImage() async {
  // Load image from assets
  final ByteData data = await rootBundle.load('assets/test_images/sample.jpg');
  final Uint8List bytes = data.buffer.asUint8List();
  
  // Decode the image using the image package
  return img.decodeImage(bytes)!;
}
}


class Model_Benchmark {
  String albumName;
  int anger;
  int disgust;
  int fear;
  int happy;
  int neutral;
  int sad;
  int surprise;

  Model_Benchmark({
    required this.albumName,
    required this.anger,
    required this.disgust,
    required this.fear,
    required this.happy,
    required this.neutral,
    required this.sad,
    required this.surprise
  });

double compareAndAnalyzePredictions(Model_Benchmark pred_benchmark) {
  List<String> emotions = EMOTIONS.list;

  int totalCorrect = 0;
  int totalErrors = 0;

  print("📊 Emotion Prediction Accuracy Analysis:");

  for (var emotion in emotions) {
    int predictedValue = pred_benchmark.toMap()[emotion]!;
    int benchmarkValue = toMap()[emotion]!;

    int correctPredictions = predictedValue < benchmarkValue ? predictedValue : benchmarkValue;
    int missedPredictions = (benchmarkValue - correctPredictions).abs(); // faces you missed
    int extraPredictions = (predictedValue - correctPredictions).abs();  // faces you wrongly guessed

    int totalMistakes = missedPredictions + extraPredictions;

    double emotionAccuracy = 0.0;
    if (correctPredictions + totalMistakes > 0) {
      emotionAccuracy = (correctPredictions / (correctPredictions + totalMistakes)) * 100;
    }

    totalCorrect += correctPredictions;
    totalErrors += totalMistakes;

    print("Emotion: $emotion | Predicted: $predictedValue | Benchmark: $benchmarkValue | Accuracy: ${emotionAccuracy.toStringAsFixed(2)}%");
  }

  double overallAccuracy = (totalCorrect + totalErrors) > 0
      ? (totalCorrect / (totalCorrect + totalErrors)) * 100
      : 0.0;

  print("\n✅ Overall Prediction Accuracy: ${overallAccuracy.toStringAsFixed(2)}%");

  return overallAccuracy;
}





  // Convert Model_Benchmark properties to a Map for easier access
  Map<String, int> toMap() {
    return {
      EMOTIONS.angry: anger,
      EMOTIONS.disgust: disgust,
      EMOTIONS.fear: fear,
      EMOTIONS.happy: happy,
      EMOTIONS.neutral: neutral,
      EMOTIONS.sad: sad,
      EMOTIONS.surprise: surprise,
    };
  }
}
