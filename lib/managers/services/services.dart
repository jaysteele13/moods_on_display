// Mock assetentity form ID as it is a static function and isolated
import 'package:photo_manager/photo_manager.dart';

class AssetEntityService {
  Future<AssetEntity?> fromId(String id) {
    return AssetEntity.fromId(id);
  }
}

class PhotoManagerService {
  Future<PermissionState> requestPermission() async {
    return PhotoManager.requestPermissionExtend();
  }
}