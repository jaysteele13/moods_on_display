// functions to test GetEmotionBoundingBoxes by Pointer, insert Image, init, onCreate

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:sqflite/sqflite.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../mocks/database_mock/database_mock.mocks.dart';
import '../constants.dart';


void main() {
  late MockDatabase mockDatabase;
  late DatabaseManager databaseManager;
  late MockGetDirectoryService mockGetDirectoryService;

  
   String testPath = 'fake_path.db'; // Your fake directory path

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockDatabase = MockDatabase();
    mockGetDirectoryService = MockGetDirectoryService();
    databaseManager = DatabaseManager(getDirectoryService: mockGetDirectoryService);

    // Mock the GetDirectoryService to avoid platform-specific code (getApplicationDocumentsDirectory)
    when(mockGetDirectoryService.getCurrentDirectory())
      .thenAnswer((_) async => Directory(testPath));  // Return a fake directory

    // Mock the database insert function
    when(mockDatabase.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
      .thenAnswer((_) async => 1);

    databaseFactory = databaseFactoryFfi;

    await databaseManager.database;
  });

  group('DatabaseManager Tests', () {
    group('insertImage', () {
      test('insertImage should return 1 on successful insert', () async {
        const String testId = '123';
        const String testEmotion = EMOTIONS.fear;

        try {
          // Perform the actual insertImage test
          final result = await databaseManager.insertImage(testId, testEmotion);
          expect(result, equals(1));
          UNIT_TEST.visualTestLogger('correct emotion given, adds to DB successfully', true);
        } catch (e) {
          UNIT_TEST.visualTestLogger('', false);
          rethrow;
        }
      });

    test('insertImage should throw exception for invalid emotion', () async {
      const String testId = '123';
      const String invalidEmotion = 'confused';

      try {
        expect(() => databaseManager.insertImage(testId, invalidEmotion), throwsException);
        UNIT_TEST.visualTestLogger('throws exception likely due to invalid emotion', true);
      } catch (e) {
        UNIT_TEST.visualTestLogger('', false);
        rethrow; // Ensure the error is still shown in test reports
      }

      
    });

    });
    
    group('getEmotionBoundingBoxesByPointer', () {
      test('should return a list of EmotionBoundingBoxes when data is fetched', () async {
      
      // Call method to add entries
      String pointer_id = 'id';

      // Fixture based off of query
      List<EmotionBoundingBox> test_list = [EmotionBoundingBox(emotion: EMOTIONS.happy, boundingBox: BoundingBox(x: 10, y: 20, width: 30, height: 40)),
      EmotionBoundingBox(emotion: EMOTIONS.sad, boundingBox: BoundingBox(x: 50, y: 60, width: 70, height: 80))];

      await databaseManager.deleteBoundingBoxRecords([pointer_id]);
      
      await databaseManager.insertBoundingBoxes(pointer_id, test_list);
      // call method to retrieve them
      final result = await databaseManager.getEmotionBoundingBoxesByPointer(pointer_id);

      try {
        // Check that the result is a list of EmotionBoundingBox objects
        expect(result.length, 2);  // Expect 2 items
        expect(result[0].emotion, EMOTIONS.happy);
        expect(result[0].boundingBox.x, 10);
        expect(result[0].boundingBox.y, 20);
        expect(result[0].boundingBox.width, 30);
        expect(result[0].boundingBox.height, 40);
        UNIT_TEST.visualTestLogger('Correct Bounding boxes were added in detail\n', true, logs: ['Result: $result']);

      } catch(e) {
        UNIT_TEST.visualTestLogger('Images were not added', false);
        rethrow; // Ensure the error is still shown in test reports
      }

      
    });

    });

    group('getAllImages', () {

      test('getAllImages should return list when images are available', () async {
        const String testId = '123';
        const String testEmotion = EMOTIONS.fear;
        // perform population
        await databaseManager.insertImage(testId, testEmotion);
        when(mockDatabase.query('images')).thenAnswer((_) async => []);

        final result = await databaseManager.getAllImages();

        try {
           expect(result, isNotEmpty);
           UNIT_TEST.visualTestLogger('returns all images', true,
        logs: ['images: $result']);
        } catch(e) {
           UNIT_TEST.visualTestLogger("", false);
           rethrow; // Ensure the error is still shown in test reports
        }

       
    });
      test('getAllImages should return empty list when no images are present', () async {
      when(mockDatabase.query('images')).thenAnswer((_) async => []);
      await databaseManager.deleteImageRecords(['123']);

      final result = await databaseManager.getAllImages();

      try {
        expect(result, isEmpty);
        UNIT_TEST.visualTestLogger('throws exception likely due to invalid emotion', true,
        logs: ['Clear DB then check for empty list']);
      } catch (e) {
        UNIT_TEST.visualTestLogger("123 pointer didn't get deleted or DB is still populated", false);
        rethrow; // Ensure the error is still shown in test reports
      }
    
    });

    });


    group('deleteImageRecords', () {

       test('deleteImageRecords should delete existing records', () async {
        const String testId = '123';
      when(mockDatabase.query('images')).thenAnswer((_) async => []);
      
      await databaseManager.deleteImageRecords([testId]);

      final result = await databaseManager.getAllImages();

      try {
        
        expect(result, isEmpty);
        UNIT_TEST.visualTestLogger('deletes records on command', true,
        logs: ['Should delete  selected image with 123 pointer. Result: $result']);
      } catch (e) {
        UNIT_TEST.visualTestLogger("123 pointer didn't get deleted or DB is still populated", false);
        rethrow; // Ensure the error is still shown in test reports
      }
    
    });


    });
    
  });
}
