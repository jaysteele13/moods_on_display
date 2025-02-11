import 'dart:typed_data';
import 'dart:ui';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';

class AlbumManager {
  List<AssetEntity> images = []; // grab albums from db

Future<Uint8List?> getImageByPointer(String assetId, bool lowRes) async {
  final PermissionState result = await PhotoManager.requestPermissionExtend();
  if (!result.isAuth) return null; // Check permission

  AssetEntity? asset = await AssetEntity.fromId(assetId);
  if (asset != null) {
  ThumbnailSize size = lowRes ? const ThumbnailSize(100, 100) : const ThumbnailSize(250, 250);
  return asset.thumbnailDataWithSize(size);
  }

  return null; // Image not found
  }

  void triggerGC() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlatformDispatcher.instance.onBeginFrame; 
    });
  }

  void releaseCache() {
    triggerGC();
    PhotoManager.releaseCache(); // 🔹 Force cache release
  }
}