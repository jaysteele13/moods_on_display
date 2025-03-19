import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';


import '../../mocks/image_mock/imageManagerMock.mocks.dart';
import '../constants.dart';


void main() {
  late MockAssetEntityService mockAssetEntityService;
  late MockAssetEntity mockAssetEntity;
  late MockFile mockFile;
  late ImageManager imageManager;

  setUp(() {
    mockAssetEntityService = MockAssetEntityService();
    mockAssetEntity = MockAssetEntity();
    mockFile = MockFile();
    imageManager = ImageManager(assetEntityService: mockAssetEntityService);
  });

  group('ImageManager', () {

      String testCaseA = "getFileFromPointer should return File from correct pointer";
      test(testCaseA, () async {
      // Call the mocked method
      const String pointer = '123';
      const String filePath = '/path/to/file.jpg';

      // Mock Arrange file to return from fromId static call
      when(mockAssetEntityService.fromId(pointer)).thenAnswer((_) async => mockAssetEntity);
      
        // Mock AssetEntity to return a valid file
      when(mockAssetEntity.file).thenAnswer((_) async => mockFile);
      when(mockFile.path).thenReturn(filePath);
      when(mockFile.exists()).thenAnswer((_) async => true);
  

      File result = await imageManager.getFilefromPointer(pointer);

       try {
        // Debugging output
        List<String> logs = ['Result File Path: ${result.path}', 'Expected: $filePath Actual: ${result.path}'];

        // Should return a valid file
        expect(result, isA<File>());
        expect(await result.exists(), isTrue);
        expect(result.path, equals(filePath));
        UNIT_TEST.visualTestLogger(testCaseA, true, logs: logs);
      } catch (e) {
        UNIT_TEST.visualTestLogger(testCaseA, false);
        rethrow; // Ensure the error is still shown in test reports
      }
    });

  String testCaseB = "getFileFromPointer should throw exception if file cannot be found from correct pointer";
  test(testCaseB, () async {
      // Call the mocked method
      const String pointer = 'unknown_pointer';

      // Mock Arrange file to return from fromId static call
      when(mockAssetEntityService.fromId(pointer)).thenAnswer((_) async => null);
      
        // Mock AssetEntity to return a valid file
      when(mockAssetEntity.file).thenAnswer((_) async => null);
      when(mockFile.exists()).thenAnswer((_) async => false);

      try {
        // Debugging output
        String exception_message = "Can't retrieve the file or file does not exist";
        List<String> logs = ['should throw exception message: $exception_message'];
        expect(
          () async => await imageManager.getFilefromPointer(pointer),
          throwsA(isA<Exception>().having((e) => e.toString(), 'exception message', contains(exception_message))),
        );
        UNIT_TEST.visualTestLogger(testCaseB, true, logs: logs);
      } catch (e) {
        UNIT_TEST.visualTestLogger(testCaseB, false);
        rethrow; // Ensure the error is still shown in test reports
      }
    });

  String testCaseC = 'setPointersToFilePathPointer adds valid FilePathPointer to notifier';
  test(testCaseC, () async {
    const String pointer = '123';
    const String filePath = '/path/to/file.jpg';
    FilePathPointer expected_result = FilePathPointer(filePath: filePath, imagePointer: pointer);

    // Arrange
    when(mockAssetEntityService.fromId(pointer)).thenAnswer((_) async => mockAssetEntity);
    when(mockAssetEntity.file).thenAnswer((_) async => mockFile);
    when(mockFile.path).thenReturn(filePath);
    when(mockFile.exists()).thenAnswer((_) async => true);

    // Act
    await imageManager.setPointersToFilePathPointer([pointer]);

    // Assert
    try {
      
      List<String> logs = ['Expected: $expected_result Actual: ${imageManager.selectedMultiplePathsNotifier.value!.first}',
      'FilePathPointer.file: ${expected_result.filePath} Actual: ${imageManager.selectedMultiplePathsNotifier.value![0].filePath}'];

      expect(imageManager.selectedMultiplePathsNotifier.value!.length, equals(1));
      expect(imageManager.selectedMultiplePathsNotifier.value!.first, isA<FilePathPointer>());
      expect(imageManager.selectedMultiplePathsNotifier.value!.first.filePath, filePath);
      expect(imageManager.selectedMultiplePathsNotifier.value!.first.imagePointer, pointer);

      UNIT_TEST.visualTestLogger(testCaseC, true, logs: logs);      
    } catch (e) {
      UNIT_TEST.visualTestLogger(testCaseC, false);
      rethrow; 
    }
   
  });

  String testCaseD = 'setPointersToFilePathPointer throws exception when file does not exist';
  test(testCaseD, () async {
    const String pointer = '123';

    // Arrange
    when(mockAssetEntityService.fromId(pointer)).thenAnswer((_) async => mockAssetEntity);

    when(mockAssetEntity.file).thenAnswer((_) async => mockFile);
    when(mockFile.path).thenReturn('');
    when(mockFile.exists()).thenAnswer((_) async => false);

    try {
      String exception_message = "Can't retrieve the file or file does not exist";
      print('should throw exception message: $exception_message');
      expect(
        () async => await imageManager.setPointersToFilePathPointer([pointer]),
        throwsA(isA<Exception>().having((e) => e.toString(), 'exception message', contains(exception_message))),
      );
      UNIT_TEST.visualTestLogger(testCaseD, true, logs: [exception_message]);      
    } catch (e) {
      UNIT_TEST.visualTestLogger(testCaseD, false);
      rethrow; 
    }
  });

  String testCaseE = 'etPointersToFilePathPointer throws exception when asset is null';
  test('setPointersToFilePathPointer throws exception when asset is null', () async {
    const String pointer = '123';

    // Arrange
    when(mockAssetEntityService.fromId(pointer)).thenAnswer((_) async => null);

    try {
      expect(
      () async => await imageManager.setPointersToFilePathPointer([pointer]),
      throwsException,
    );
    UNIT_TEST.visualTestLogger(testCaseE, true,);   

    }
    catch(e) {
      UNIT_TEST.visualTestLogger(testCaseE, false);   
      rethrow;
    }
  });
 });
}
