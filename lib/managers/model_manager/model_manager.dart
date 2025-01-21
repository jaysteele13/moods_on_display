import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelManager {
  // this is to load and run the model using tflite_flutter
  late Interpreter interpreter;

  ModelManager() {
    // loadModel / (s) initially
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
  }

  // returns a 2d list of emotions (results) on a singular image
  Future<List<Map<String, dynamic>>?> performDetection(File selectedImage) async {
    
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
