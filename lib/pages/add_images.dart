
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'dart:io';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => AddImageScreenState();
}

class AddImageScreenState extends State<AddImageScreen> {
  final ImageManager _imageManager = ImageManager();
  final ModelManager _modelManager = ModelManager();
  bool _isGalleryLoading = false;
  List faceDetections = [];
  
  // have local image holder? use 

 

  // have functions to call other functions - dart common standard
  void _pickImageFromGallery() async {
    setState(() { _isGalleryLoading = true;});
    await _imageManager.pickImageFromGallery();
    setState(() { _isGalleryLoading = false;});
    
     
  }

  void _pickImageFromCamera() async {
    await _imageManager.pickImageFromCamera();
    setState(() {
      _isGalleryLoading = false;
    });
  }



Widget showPredictions() {
  try {
    return ValueListenableBuilder<File?>(
      valueListenable: _imageManager.selectedImageNotifier,
      builder: (context, selectedImage, child) {
        if (_imageManager.selectedImage == null) {
          return const Text('No selected image');
        }

        return FutureBuilder<List<File>>(
          future: _modelManager.displayFaceDetectedImage(_imageManager.selectedImage!),
          builder: (context, snapshot) {
            try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Show error message
            } else if (snapshot.hasData) {
              print(snapshot.data);
              List<File> predictions = snapshot.data!;
              
             List<Widget> imageWidgets = [];

              for (File images in predictions) {
                print('Reassign predictions');
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await _modelManager.deleteTempFile(images); // Delete temp file after it's displayed
                });
                imageWidgets.add(
                  Image.file(
                    images,
                    width: 150,
                    height: 150,
                  ),
                );
              }

             return imageWidgets.isNotEmpty
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    mainAxisSpacing: 10, // Spacing between rows
                    crossAxisSpacing: 10, // Spacing between columns
                  ),
                  shrinkWrap: true, // Ensures the grid takes up only as much space as needed
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling if inside another scrollable widget
                  itemCount: imageWidgets.length,
                  itemBuilder: (context, index) {
                    return imageWidgets[index];
                  },
                )
              : Text('No Predictions');

              
              
             
            } else {
              return const Text('No predictions available.');
            }
            }
            catch (e) {
              print(e);
              return const Text('Issue with Face detection!');
            }
          },
        );
      },
    );
  } catch (e) {
    print('Error in showPredictions: $e');
    return const Text('An error occurred while loading predictions.'); // Return a fallback widget
  }
}






  @override
  void initState() {
    super.initState();
    _pickImageFromGallery();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Scanning for Emotion'),
      ),
      body: Center(
        // based on gllery loading show this until this...
        child: _isGalleryLoading ? const CircularProgressIndicator() 
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: _pickImageFromGallery,
              color: Colors.blue,
              child: const Text('Gallery'),
            ),
            MaterialButton(
              onPressed: _pickImageFromCamera,
              color: Colors.red,
              child: const Text('Camera'),
            ),
            const SizedBox(height: 20),
           Column(
          children: [ showPredictions() ],
        )
  
          ],
        ),
      ),
    );
  }
}
