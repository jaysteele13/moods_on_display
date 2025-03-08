class DETECTION_TEST {
  static const emotion_test_album = 'test_album';
  
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
    // Emotion names
    List<String> emotions = ['anger', 'disgust', 'fear', 'happy', 'neutral', 'sad', 'surprise'];

    // Create a map to store the accuracies based on predicted and benchmark values
    Map<String, double> accuracies = {};

    // Calculate the accuracy for each emotion
    emotions.forEach((emotion) {
      int predictedValue = pred_benchmark.toMap()[emotion]!;
      int benchmarkValue = toMap()[emotion]!;

      // Calculate accuracy based on the amount of predicted vs benchmark values
      double accuracy = 0.0;
      if (predictedValue != 0) {
        accuracy = (benchmarkValue / predictedValue) * 100; // benchmark vs predicted
      } 
      
      if (accuracy > 100) {
        accuracy = (predictedValue / benchmarkValue) * 100; // If both are zero, it's 100% accurate
      }

      accuracies[emotion] = accuracy;
    });

    // Calculate the overall accuracy by averaging the accuracies of all emotions
    double overallAccuracy = accuracies.values.reduce((a, b) => a + b) / accuracies.length;

    // Print the differences and the analysis
    print("📊 Emotion Prediction Accuracy Analysis:");

    // Print accuracy for each emotion
    emotions.forEach((emotion) {
      print("Emotion: $emotion | Predicted: ${pred_benchmark.toMap()[emotion]} | Benchmark: ${this.toMap()[emotion]} | Accuracy: ${accuracies[emotion]}%");
    });

    print("\n✅ Overall Prediction Accuracy: ${overallAccuracy}%");
    return overallAccuracy;
  }


  // Convert Model_Benchmark properties to a Map for easier access
  Map<String, int> toMap() {
    return {
      'anger': anger,
      'disgust': disgust,
      'fear': fear,
      'happy': happy,
      'neutral': neutral,
      'sad': sad,
      'surprise': surprise,
    };
  }
}
