// lib/image_manager.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class ImageManager {
  // managing the slectedImage (may have to change to mulitple)
 final ValueNotifier<File?> selectedImageNotifier = ValueNotifier<File?>(null);
File? get selectedImage => selectedImageNotifier.value;

final ValueNotifier<List<File>?> selectedMultipleImagesNotifier = ValueNotifier<List<File>?>(null);
List<File>? get selectedImages => selectedMultipleImagesNotifier.value;


  // Setter for selectedImage
  set selectedImage(File? value) {
    selectedImageNotifier.value = value; // Notify listeners when value changes
  }

// Setter for selectedImages with duplication check
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


  // Code to get image from user's galery
  Future<void> pickImageFromGallery() async {
    //clearImage(); // clear cache
    selectedImage = null;
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
   
    if (pickedImage == null) return null;
    print('here is image path: ${pickedImage.name}');
    selectedImage = File(pickedImage.path);
    
  }

  // Code to take a picture and save it using camera
  Future<void> pickImageFromCamera() async {
    clearImage(); // clear cache
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;
    selectedImage = File(pickedImage.path);
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

  void clearImage() {
    selectedImage = null;
  }
}
