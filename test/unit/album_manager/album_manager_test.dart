import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/managers/album_manager/album_manager.dart';
import 'package:photo_manager/photo_manager.dart';


import '../../mocks/album_mock/album_mock.mocks.dart';



void main() {
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

  group('ImageManager', () {

      test('getImageByPointer should return Uint8List when permission granted and image exists', () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;
    final mockThumbnailData = Uint8List(10); // Mock image data

    // Mock permission check
    when(mockPhotoManagerService.requestPermission()).thenAnswer((_) async => PermissionState.authorized);
    
    // Mock AssetEntity methods
    when(mockAssetEntity.thumbnailDataWithSize(any)).thenAnswer((_) async => mockThumbnailData);
    when(mockAssetEntityService.fromId(assetId)).thenAnswer((_) async => mockAssetEntity);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    expect(result, isA<Uint8List>());
    expect(result!.length, equals(mockThumbnailData.length));
  });

  test('getImageByPointer should return Uint8List when permission limited and image exists', () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;
    final mockThumbnailData = Uint8List(10); // Mock image data

    // Mock permission check
    when(mockPhotoManagerService.requestPermission()).thenAnswer((_) async => PermissionState.limited);
    
    // Mock AssetEntity methods
    when(mockAssetEntity.thumbnailDataWithSize(any)).thenAnswer((_) async => mockThumbnailData);
    when(mockAssetEntityService.fromId(assetId)).thenAnswer((_) async => mockAssetEntity);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    expect(result, isA<Uint8List>());
    expect(result!.length, equals(mockThumbnailData.length));
  });

  test('getImageByPointer should return null when permission is not granted', () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;

    // Mock permission check to return no permission
    when(mockPhotoManagerService.requestPermission()).thenAnswer((_) async => PermissionState.denied);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    expect(result, isNull);
  });

  test('getImageByPointer should return null when image not found', () async {
    // Arrange
    const String assetId = '123';
    const bool lowRes = true;

    // Mock permission check -> // must now Mock Static instance with dependency injection for PhotoManager
    when(mockPhotoManagerService.requestPermission()).thenAnswer((_) async => PermissionState.denied);
    
    // Mock AssetEntity not found
    when(mockAssetEntityService.fromId(assetId)).thenAnswer((_) async => null);

    // Act
    final result = await albumManager.getImageByPointer(assetId, lowRes);

    // Assert
    expect(result, isNull);
  });
 });
}
