import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:photo_manager/photo_manager.dart';


import '../../mocks/album_mock/album_mock.mocks.dart';
import '../constants.dart';



void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockAssetEntityService mockAssetEntityService;
  late MockAssetEntity mockAssetEntity;
  late MockPhotoManagerService mockPhotoManagerService;
  late AlbumManager albumManager;

  setUp(() {
    mockAssetEntityService = MockAssetEntityService();
    mockPhotoManagerService = MockPhotoManagerService();
    mockAssetEntity = MockAssetEntity();
    albumManager = AlbumManager(assetEntityService: mockAssetEntityService, photoManagerService: mockPhotoManagerService);
  });

  group('AlbumManager', () {

  String testCaseA = "getImageByPointer should return Uint8List when permission granted and image exists";
  test(testCaseA, () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;
    final mockThumbnailData = Uint8List(10); 

    when(mockPhotoManagerService.requestPermission())
        .thenAnswer((_) async => PermissionState.authorized);

    when(mockAssetEntity.thumbnailDataWithSize(any))
        .thenAnswer((_) async => mockThumbnailData);
    when(mockAssetEntityService.fromId(assetId))
        .thenAnswer((_) async => mockAssetEntity);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    try {
      expect(result, isA<Uint8List>());
      expect(result!.length, equals(mockThumbnailData.length));
      UNIT_TEST.visualTestLogger(testCaseA, true);
    } catch (e) {
      UNIT_TEST.visualTestLogger(testCaseA, false);
      rethrow; // Ensure the error is still shown in test reports
    }
  });


  String testCaseB = "getImageByPointer should return null when image not found";
  test(testCaseB, () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;
    final mockThumbnailData = Uint8List(10); 

    when(mockPhotoManagerService.requestPermission())
        .thenAnswer((_) async => PermissionState.denied);

    when(mockAssetEntity.thumbnailDataWithSize(any))
        .thenAnswer((_) async => mockThumbnailData);
    when(mockAssetEntityService.fromId(assetId))
        .thenAnswer((_) async => mockAssetEntity);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    try {
      expect(result, isNull);
      UNIT_TEST.visualTestLogger(testCaseB, true);
    } catch (e) {
      UNIT_TEST.visualTestLogger(testCaseB, false);
      rethrow; // Ensure the error is still shown in test reports
    }
  
  });
 });
}
