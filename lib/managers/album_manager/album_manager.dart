import 'dart:typed_data';
import 'dart:ui';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';

class AlbumManager {
  List<AssetEntity> images = []; // grab albums from db

  final AssetEntityService assetEntityService;
  final PhotoManagerService photoManagerService;
  AlbumManager({required this.assetEntityService, required this.photoManagerService});

Future<Uint8List?> getImageByPointer(String assetId, bool lowRes) async {
  final PermissionState result = await photoManagerService.requestPermission();
  if (!result.isAuth) return null; // Check permission

  AssetEntity? asset = await assetEntityService.fromId(assetId);
  if (asset != null) {
  ThumbnailSize size = lowRes ? const ThumbnailSize(100, 100) : const ThumbnailSize(800, 600);
  return asset.thumbnailDataWithSize(size);
  }

  return null; // Image not found
  }

  // getAlbumDetails
  // use photoManager to retrieve amount of assets and a list of assets stop (5)
  



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