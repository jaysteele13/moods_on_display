// Mock assetentity form ID as it is a static function and isolated
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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

class GetDirectoryService {
  Future<Directory> getCurrentDirectory() async {
    return getApplicationDocumentsDirectory();
  }
}

