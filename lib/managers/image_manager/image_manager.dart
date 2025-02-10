// lib/image_manager.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';


class ImageManager {
 
  final ValueNotifier<List<File>?> selectedMultipleImagesNotifier = ValueNotifier<List<File>?>(null);
  List<File>? get selectedImages => selectedMultipleImagesNotifier.value;

  final ValueNotifier<List<Uint8List>?> selectedByteImagesNotifier = ValueNotifier<List<Uint8List>?>(null);
  List<Uint8List>? get selectedByteImages => selectedByteImagesNotifier.value;


  set selectedImages(List<File>? newImages) {
    if (newImages != null) {
      // Remove duplicates by comparing file paths or other criteria (e.g., if file already exists)
      List<File> uniqueImages = [];
      for (var image in newImages) {
        if (!uniqueImages.any((existingImage) => existingImage.path == image.path)) {
          uniqueImages.add(image); // Add the image if it's not already in the list
        }
      }
      selectedMultipleImagesNotifier.value = uniqueImages; // Set the unique list of images
    } else {
      selectedMultipleImagesNotifier.value = null; // If null, clear the selected images
    }
  }

  // may be to much computation
  set selectedByteImages(List<Uint8List>? newImages) {
    if (newImages != null) {
      // Remove duplicates by comparing file paths or other criteria (e.g., if file already exists)
      List<Uint8List> uniqueImages = [];
      final equality = const ListEquality<int>();

      for (var image in newImages) {
        if (!uniqueImages.any((existingImage) => equality.equals(existingImage, image))) {
          uniqueImages.add(image);
        }
      }
      print('setting images');
      selectedByteImagesNotifier.value = uniqueImages; // Set the unique list of images
    } else {
      selectedByteImagesNotifier.value = null; // If null, clear the selected images
    }
  }

  // Here this could be ammended to create a new object, that creates a file, then the object holds the [file path and the pointer path]!
  // this way the pointer image can be referenced and added to the DB
  Future<void> setPointersToFiles(List<String> pointers) async {
  // sets fileImages based off of selected images for model detection
  List<File> result = [];

  for (String point in pointers) {
    // Get the asset by pointer
    AssetEntity? asset = await AssetEntity.fromId(point);

    // Retrieve the file from the asset
    File? assetFile = await asset?.file;

    if (assetFile != null && await assetFile.exists()) {
      result.add(assetFile);
    } else {
      throw Exception("Can't retrieve the file or file does not exist");
    }
  }

  // Update the selectedMultipleImagesNotifier with the list of File objects
  selectedMultipleImagesNotifier.value = result;
}

  Future<void> setPointersToBytesNotifier(List<String> pointers) async {
    // sets byteImages based off of selected images for model detection
    List<Uint8List> result = [];

    for(String point in pointers) {
      // get uint by pointer
      AssetEntity? asset = await AssetEntity.fromId(point);
      Uint8List? assetBytes = await asset?.originBytes;
      if(assetBytes != null && assetBytes.isNotEmpty) {
        result.add(assetBytes);
      }
      else {
        throw Exception("Can't retrieve image bytes");
      }
      selectedByteImagesNotifier.value = result;
    }

  }

  
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

   Future<img.Image?> loadAndProcessByteImage(Uint8List bytePath) async {
    img.Image? image = img.decodeImage(bytePath);
    if (image != null) {
      return img.copyResize(image, width: 224, height: 224);
    }
    return null;
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


Future<void> listAndDeleteFiles() async {
  // Get the temporary directory where files are stored
  Directory tempDir = await getTemporaryDirectory();
  
  // List all files in the directory
  List<FileSystemEntity> files = tempDir.listSync();

  // Print all the file names for debugging
  for (var file in files) {
    if (file is File) {
      print('File found: ${file.path}');
    }
  }

  // Optionally delete files (example: delete all files in the temp directory)
  for (var file in files) {
    if (file is File) {
      try {
        await file.delete();
        print('Deleted: ${file.path}');
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }
}


  Future<void> pickMultipleImagesFromGallery() async {
  // Pick multiple images from the gallery
  final pickedImages = await ImagePicker().pickMultiImage(); 

  // Check if any images were picked
  if (pickedImages.isEmpty) return;

  // Convert the picked images into a list of File objects
  // Map each picked image to a File using its path
  List<File> newSelectedImages = pickedImages
      .map((image) => File(image.path))
      .toList();

  // Ensure uniqueness (optional, to prevent duplicates)
  newSelectedImages = newSelectedImages.toSet().toList();

   

  // Update the ValueNotifier with the new list of selected images
  selectedMultipleImagesNotifier.value = newSelectedImages;
}

  // code to load and preprocess and image if coming from a path
  Future<img.Image?> loadAndProcessImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image != null) {
      return img.copyResize(image, width: 224, height: 224);
    }
    return null;
  }
}
