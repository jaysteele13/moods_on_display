
import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/image_manager/image_manager.dart';
import 'package:moods_on_display/managers/model_manager/model_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => AddImageScreenState();
}

class AddImageScreenState extends State<AddImageScreen> {
  final ImageManager _imageManager = ImageManager();
  final ModelManager _modelManager = ModelManager();
  bool _isGalleryLoading = false;

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

  // shows predictions baed on mbnv2 model currently, return list of emotions per image
  Widget showPredictions() {
  if (_imageManager.selectedImage == null) {
    return const Text('Please select an image first.');
  }
  else {

  return FutureBuilder<List<Map<String, dynamic>>?>(
    future: _modelManager.performDetection(_imageManager.selectedImage!),
    builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        // Display the predictions
        List<Map<String, dynamic>> predictions = snapshot.data!;
        return Column(
          children: predictions.map((prediction) {
            return Text('${prediction['emotion']}: ${prediction['percentage']}%');
          }).toList(),
        );
      } else {
        return const Text('No predictions available.');
      }
    },
  );
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
             _imageManager.selectedImage != null 
      ? Column(
          children: [
            Image.file(_imageManager.selectedImage!),
            showPredictions()
          ],
        )
      : const Text("Please select an image"),
  
          ],
        ),
      ),
    );
  }
}
