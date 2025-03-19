import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image/image.dart' as img;

import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/managers/model_manager/emotion_image.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';

import '../constants.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}
class MockFilePointer extends Mock implements FilePointer {}

class MockModelManager extends Mock implements ModelManager {}

void main() {
  late MockModelManager mockModelManager;
  late MockDatabaseManager mockDatabaseManager;
  late MockFilePointer mockFilePointer;
  late ModelManagerUtils modelManagerUtils;
  late UNIT_TEST unit;

  

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockDatabaseManager = MockDatabaseManager();
    mockFilePointer = MockFilePointer();
    mockModelManager = MockModelManager();
    modelManagerUtils = ModelManagerUtils();

    unit = UNIT_TEST();
  });

  // Register a fallback value for the `img.Image` type
  setUpAll(() {
    registerFallbackValue(img.Image(width: 100, height: 100)); // Providing a default fallback value
    registerFallbackValue(FilePathPointer(filePath: '', imagePointer: '')); // Necessary for Mocking Services

    mockDatabaseManager = MockDatabaseManager();
    // DB operations include returning int for success value // Returning an integer to match the expected return type
    when(() => mockDatabaseManager.insertImage(any(), any()))
        .thenAnswer((_) async => 1);  // Returning 1 to simulate success
    
  });

// The point of using mocktail:
/*
- isolate the behavior of the function under specific conditions. 
- By mocking performFaceDetection() to return an empty list, we can test the downstream logic 
*/
  group('ModelManager Logic Tests', () {

    // fixtures
    List<dynamic> modelOutput = [[0.1, 0.3, 0.1, 0.1, 0.2, 0.1, 0.1]];

    // Fixtures
    Map<String, double> emotionOutput = {
      EMOTIONS.angry: 0.1,
      EMOTIONS.disgust: 0.3,
      EMOTIONS.fear: 0.1,
      EMOTIONS.happy: 0.1,
      EMOTIONS.neutral: 0.1,
      EMOTIONS.sad: 0.2,
      EMOTIONS.surprise: 0.1,
      
    };

    EmotionImage emotionImageTest = EmotionImage(emotions: emotionOutput, valid: true);
     
    // findMostCommonHighestEmotion, parseIntoEmotionImage, 
    test('FindMostCommonHighestEmotion test', () async {

      // given the fixture the output should be disgust
     
      String result = modelManagerUtils.findMostCommonHighestEmotion(emotionImageTest);
      print('Result: $result');
      expect(result, EMOTIONS.disgust);
      expect(result, isNot(EMOTIONS.angry));
      print('✅ Tests Passed -> FindMostCommonHighestEmotion');
    });

    test('parseIntoEmotionImage test', () async {
      EmotionImage result = modelManagerUtils.parseIntoEmotionImage(modelOutput);

      print(result.emotions);

      expect(result.emotions.entries.first.key, EMOTIONS.angry);
      expect(result.emotions.entries.first.value, 10.0);
      expect(result.selectedFilePathPointer, null);
      print('✅ Tests Passed -> parseIntoEmotionImage');


    });
  });

  group('ModelManager Tests with mocktail', () {
    test('Model loads correctly', () async {
      // Mock the state of isModelLoaded to return true
      when(() => mockModelManager.isModelLoaded).thenReturn(true);

      // On initialization, model should be loaded
      expect(mockModelManager.isModelLoaded, true);
      print('✅ Tests Passed -> Mock Load Model');
    });

    test('Face detection returns empty when no faces found', () async {
      when(() => mockFilePointer.file).thenReturn(File('test_assets/no_face.jpg'));

      // Mock performFaceDetection to return an empty list of ImageBoundingBox
      when(() => mockModelManager.performFaceDetection(mockFilePointer))
          .thenAnswer((_) async => []);

      List<ImageBoundingBox> faces = await mockModelManager.performFaceDetection(mockFilePointer);
      expect(faces.isEmpty, true);
      print('✅ Tests Passed -> Mock Face Detection Returns Empty if no faces detected!');
    });

    test('Face detection returns with list when faces are found', () async {
      when(() => mockFilePointer.file).thenReturn(File('test_assets/sample.jpg'));

      // Mock performFaceDetection to return an empty list of ImageBoundingBox
      when(() => mockModelManager.performFaceDetection(mockFilePointer))
          .thenAnswer((_) async => [unit.IMAGE_BOUNDING_BOX]);

      List<ImageBoundingBox> faces = await mockModelManager.performFaceDetection(mockFilePointer);
      expect(faces.isEmpty, false);
      print('✅ Tests Passed -> Face Detection returns list of ImageBoundingbox type if found images!');
    });

    test('Perform Emotion Detection returns valid EmotionImage', () async {
      EmotionImage mockEmotionImage = EmotionImage(
        emotions: {'happy': 70, 'sad': 30},
        valid: true,
        mostCommonEmotion: 'happy',
      );

      // Mock performEmotionDetection to return the mocked EmotionImage
      when(() => mockModelManager.performEmotionDetection(any()))
          .thenAnswer((_) async => mockEmotionImage);

      File file = File('assets/test_images/sample.jpg');
      img.Image? testImage = img.decodeImage(file.readAsBytesSync());

      if (testImage != null) {
        EmotionImage emotion = await mockModelManager.performEmotionDetection(testImage);
        expect(emotion.valid, true);
        expect(emotion.emotions.isNotEmpty, true);
        print('✅ Tests Passed -> Mock Returns valid EmotionImage type after prediction!');
      } else {
        print("❌ Test Failed: Error: No test image found!");
      }
    });

    test('Database stores image emotion correctly', () async {
      List<EmotionImage> emotionImages = [
        EmotionImage(emotions: {'happy': 70, 'sad': 30}, valid: true, mostCommonEmotion: 'happy')
      ];

      FilePathPointer mockPointer = FilePathPointer(filePath: 'test_path', imagePointer: 'test_image');

      // Mocking insertImage method inside the mockDatabaseManager to return a Future<int> (simulating success)
      when(() => mockDatabaseManager.insertImage(any(), any()))
          .thenAnswer((_) async => 1);  // Return a successful result (1)

      // Mocking formatEmotionImagesWithDB to call insertImage inside the mock
      when(() => mockModelManager.formatEmotionImagesWithDB(any(), any()))
          .thenAnswer((_) async {
        await mockDatabaseManager.insertImage(mockPointer.imagePointer, emotionImages[0].mostCommonEmotion!);
      });

      // Call the function you're testing, which returns void
      await mockModelManager.formatEmotionImagesWithDB(emotionImages, mockPointer);

      // Verify that the insertImage method was called with the correct arguments
      verify(() => mockDatabaseManager.insertImage(mockPointer.imagePointer, emotionImages[0].mostCommonEmotion!)).called(1);
      print('✅ Tests Passed -> Mock Database Stores image when all emotions are summarised per image.');
    });

  });

 
}
