import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:moods_on_display/managers/image_manager/filePointer.dart';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';



class ImageManager {

  final AssetEntityService assetEntityService;
  ImageManager({required this.assetEntityService});
 

  // file object array
  final ValueNotifier<List<File>?> selectedMultipleImagesNotifier = ValueNotifier<List<File>?>(null);
  List<File>? get selectedImages => selectedMultipleImagesNotifier.value;

  // file path object array
  final ValueNotifier<List<FilePathPointer>?> selectedMultiplePathsNotifier = ValueNotifier<List<FilePathPointer>?>(null);
  List<FilePathPointer>? get selectedPaths => selectedMultiplePathsNotifier.value;


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

  // setting unique objects
   set selectedPaths(List<FilePathPointer>? newPaths) {
    if (newPaths != null) {
      // Remove duplicates by comparing file paths or other criteria (e.g., if file already exists)
      List<FilePathPointer> uniquePaths = [];
      for (var path in newPaths) {
        if (!uniquePaths.any((existingPath) => existingPath.filePath == path.filePath)) {
          uniquePaths.add(FilePathPointer(filePath: path.filePath, imagePointer: path.imagePointer)); // Add the image if it's not already in the list
        }
      }
      selectedMultiplePathsNotifier.value = uniquePaths; // Set the unique list of images
    } else {
      selectedMultiplePathsNotifier.value = null; // If null, clear the selected images
    }
  }
Future<File> getFilefromPointer(String pointer) async {
  // sets fileImages based off of selected images for model detection
    AssetEntity? asset = await assetEntityService.fromId(pointer);

    // Retrieve the file from the asset
    File? assetFile = await asset?.file;

    if (assetFile != null && await assetFile.exists()) {
       return assetFile;
    } else {
      throw Exception("Can't retrieve the file or file does not exist");
    }
}
  

Future<void> setPointersToFilePathPointer(List<String> pointers) async {
  // sets fileImages based off of selected images for model detection
  List<FilePathPointer> result = [];

  for (String point in pointers) {
    // Get the asset by pointer
    AssetEntity? asset = await assetEntityService.fromId(point);

    // Retrieve the file from the asset
    File? assetFile = await asset?.file;

    // Grab file path
    String? assetFilePath = assetFile?.path;

    if (assetFile != null && await assetFile.exists()) {
      result.add(FilePathPointer(filePath: assetFilePath!, imagePointer: point));
    } else {
      throw Exception("Can't retrieve the file or file does not exist");
    }
  }

  selectedMultiplePathsNotifier.value = result;
}
  
  List<AssetEntity> images = []; // grab albums from db

  Future<Uint8List?> getImageByPointer(String assetId, bool lowRes) async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) return null; // Check permission
    AssetEntity? asset = await assetEntityService.fromId(assetId);
    if (asset != null) {
      ThumbnailSize size = lowRes ? const ThumbnailSize(100, 100) : const ThumbnailSize(250, 250);
      return asset.thumbnailDataWithSize(size);
    }

    return null; // Image not found
  }



Future<bool> pickImageFromCamera(BuildContext context) async {
  try {
    // Request camera permission
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      // Ask for permission
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      // Show alert to guide user to settings
      if (context.mounted) {
        await WidgetUtils.showPermissionDialog(context: context, title: "Enable Camera Access", message: "To take a photo, please allow camera access in your settings.");
      }

      return false;
    }

    // Continue with image picking
    selectedPaths = []; // Clear cache

    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // Max quality
    );

    if (pickedImage == null) return false;

    final file = File(pickedImage.path);
    final filePath = file.path;

    // Save to gallery so PhotoManager can find it
    AssetEntity? asset = await PhotoManager.editor.saveImageWithPath(filePath);

    // if (asset == null) return false;

    // Retrieve file from asset
    File? assetFile = await asset.file;
    String? assetFilePath = assetFile?.path;

    if (await asset.exists && assetFilePath?.isNotEmpty == true) {
      final assetId = asset.id;

      selectedMultiplePathsNotifier.value = [
        FilePathPointer(
          filePath: assetFilePath!,
          imagePointer: assetId,
        )
      ];

      print("Saved Asset ID: $assetId");
      return true;
    } else {
      print("Failed to save image to gallery");
      return false;
    }
  } catch (e) {
    print('Error picking image from camera: $e');
  }
  return false;
}


Future<void> shareImage(Uint8List imageBytes) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/shared_image.png').create();
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Wow, you soo emotional!');
  } catch (e) {
    print("Error sharing image: $e");
  }
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
