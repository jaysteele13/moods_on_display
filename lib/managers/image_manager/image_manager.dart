// lib/image_manager.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';


class ImageManager {
  // managing the slectedImage (may have to change to mulitple)
  final ValueNotifier<File?> selectedImageNotifier = ValueNotifier<File?>(null);
  File? get selectedImage => selectedImageNotifier.value;

  // Setter for selectedImage
  set selectedImage(File? value) {
    selectedImageNotifier.value = value; // Notify listeners when value changes
  }

  // Code to get image from user's galery
  Future<void> pickImageFromGallery() async {
    //clearImage(); // clear cache
    selectedImage = null;
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return null;
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
