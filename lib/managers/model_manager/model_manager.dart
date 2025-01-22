import 'dart:io';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ModelManager {
  // this is to load and run the model using tflite_flutter

  // run yunet using onnx model loader, more efficient - follow documentation, gbt and video for this! you got this
  late Interpreter mbv2;
  late Interpreter yunet;
  late OrtSession yunetSession;

  ModelManager() {
    // loadModel / (s) initially
    loadModels();
  }

  Future<void> loadModels() async {
    mbv2 = await Interpreter.fromAsset('assets/models/mbntv2/model.tflite');
    // yunet isn't feasable try mk google kit
    // yunet = await Interpreter.fromAsset('assets/models/yunet/yunet.tflite');
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    const assetFileName = 'assets/models/yunet/yunet.onnx';
    final rawAssetFile = await rootBundle.load(assetFileName);
    final bytes = rawAssetFile.buffer.asUint8List();
    yunetSession = OrtSession.fromBuffer(bytes, sessionOptions);
  }

Future<List<Map<String, dynamic>>?> performInfrastructure(File selectedImage) async {
  // Await the result of face detection
  File? faceDetectedImage = await performFaceDetection(selectedImage);

  // Check if the face detection returned a non-null file
  if (faceDetectedImage != null) {
    // Perform emotion detection on the face-detected image
    return await performEmotionDetection(faceDetectedImage);
  } else {
    // If face detection fails, return null
    return null;
  }
}

// convert file to tensor?

Future<List<dynamic>?> fileToFloatTensor1(File selectedImage) async {
  // File to image
  Uint8List bytes = await selectedImage.readAsBytes();
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

  if (image == null) return null;

  // Resize for yunet (640x640)
  img.Image resizedImage = img.copyResize(image, width: 640, height: 640);

  // Prepare the tensor
  final List<dynamic> imageMatrix = List.generate(
    3, // Channels (RGB)
    (channel) {
      // For each channel, create a list of Float32Lists (rows)
      List<Float32List> rows = List.generate(
        640, // Height
        (y) {
          Float32List row = Float32List(640); // Row of 640 float32 numbers
          for (int x = 0; x < 640; x++) {
            final pixel = resizedImage.getPixel(x, y);
            row[x] = _toFloat32(pixel, channel); // Assign float32 value
          }
          return row;
        },
      );
      return rows;
    },
  );

  // Add the batch dimension
  return [imageMatrix];
}

// Helper function to extract and convert to float32 using ColorFloat32
double _toFloat32(img.Pixel pixel, int channel) {
  // Convert the pixel to ColorFloat32
  final color = img.ColorFloat32.rgb(
    pixel.r.toDouble(),
    pixel.g.toDouble(),
    pixel.r.toDouble(),
  );

  switch (channel) {
    case 0: // Red channel
      return color.r.toDouble();
    case 1: // Green channel
      return color.g.toDouble();
    case 2: // Blue channel
      return color.b.toDouble();
    default:
      throw ArgumentError('Invalid channel: $channel');
  }
}

// convert file to tensor32
Future<List<dynamic>> fileToFloatTensor(File selectedImage) async {
  // File to image
  Uint8List bytes = await selectedImage.readAsBytes();
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));


  // Resize for yunet (640x640)
  img.Image resizedImage = img.copyResize(image!, width: 640, height: 640);

  // Prepare the tensor
  final imageMatrix = List<dynamic>.generate(
    3, // Channels (RGB)
    (channel) => List<dynamic>.generate(
      640, // Height
      (y) => List<dynamic>.generate(
        640, // Width
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          if (channel == 0) return pixel.r.toDouble(); // Red
          if (channel == 1) return pixel.g.toDouble(); // Green
          return pixel.b.toDouble(); // Blue
          //  img.ColorFloat32 rgb = img.ColorFloat32.rgb();
        },
      ),
    ),
  );

  // Add the batch dimension
  return [imageMatrix];
}



Future<File?> performFaceDetection1(File selectedImage) async {
  // make options for score etc
  final sessionOptions = OrtSessionOptions();

  // get image
  Uint8List bytes = await selectedImage.readAsBytes();
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

  if (image == null) return null;

  final runOptions = OrtRunOptions();

   // input must be float32[1,3,640,640]
  final inputInit = await fileToFloatTensor1(selectedImage);
  final inputOrt = OrtValueTensor.createTensorWithDataList(inputInit!);
  // final inputOrt = fileToFloatTensor(selectedImage);
  final inputs = {'input': inputOrt};

  // output should be this float32[1,1600,4]


  final outputs = yunetSession.run(runOptions, inputs);

  inputOrt.release();
  runOptions.release();
  sessionOptions.release();
  OrtEnv.instance.release();

  print(outputs.shape);

  // if outputs print then return box perhaps
  return null;

}


 Future<File?> performFaceDetection(File selectedImage) async {
  List<int> bytes = await selectedImage.readAsBytes();
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
  print("take image");
  if (image == null) return null;
  print("passed first null image");

  // Resize the image to match the input size expected by YuNet
  // img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  // Prepare input
  final imageMatrix = List.generate(
    image.height,
    (y) => List.generate(
      image.width,
      (x) {
        final pixel = image.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      },
    ),
  );
  print("get input");
  final input = [imageMatrix];
  
  // YuNet model typically outputs many rows of detections.
  // Each row might contain [x, y, width, height, confidence]
  // var output = List.filled(1000, 0).reshape([200, 5]); // Assuming 200 detections max
  var outputTensor = yunet.getOutputTensor(0);
  var outputShape = outputTensor.shape;
  var output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0)).reshape(outputShape);

  print("try model");

  if (outputShape.isEmpty) {
    print('Output shape is not available.');
    return null;
  }

  yunet.run(input, output);
  print("ran the model");
  // Process the output
  for (var detection in output) {
    double confidence = detection[4];
    if (confidence > 0.5) { // Adjust the confidence threshold as needed
      int x = detection[0].toInt();
      int y = detection[1].toInt();
      int width = detection[2].toInt();
      int height = detection[3].toInt();
      
      // Draw the rectangle on the original image
      print("drawing rectanglke");
      img.drawRect(image, x1: x, y1: y, x2: (x + width), y2: (y + height), color: img.ColorFloat16(130));
    }
  }

  // Save the modified image back to a file (optional)
  print("try the image");
  try {
    File predictedImage = File(selectedImage.path)..writeAsBytesSync(img.encodeJpg(image));
    return predictedImage;
  } catch (e) {
    print('Error encoding or writing the image: $e');
    return null;
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
    mbv2.run(input, output);

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
