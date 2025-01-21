// lib/image_manager.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageManager {
  File? _selectedImage;

  // managing the slectedImage (may have to change to mulitple)
  File? get selectedImage => _selectedImage;

  // Code to get image from user's galery
  Future<void> pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    _selectedImage = File(pickedImage.path);
  }

  // Code to take a picture and save it using camera
  Future<void> pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;
    _selectedImage = File(pickedImage.path);
  }

  // code to load and preprocess and image if coming from a path
  Future<img.Image?> loadAndProcessImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image != null) {
      return image;
    }
    return null;
  }
}
