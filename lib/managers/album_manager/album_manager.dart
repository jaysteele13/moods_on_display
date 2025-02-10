import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';



class AlbumManager {
  List<AssetEntity> images = []; // grab albums from db

Future<Uint8List?> getImageByPointer(String assetId) async {
  final PermissionState result = await PhotoManager.requestPermissionExtend();
  if (!result.isAuth) return null; // Check permission

  AssetEntity? asset = await AssetEntity.fromId(assetId);
  if (asset != null) {
    return asset.thumbnailDataWithSize(ThumbnailSize(200, 200)); // Return thumbnail
  }

  return null; // Image not found
}


}