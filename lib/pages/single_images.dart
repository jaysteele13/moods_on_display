import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class SingleImageView extends StatelessWidget {
  final List<Uint8List> images;
  final int initialIndex;

  const SingleImageView({Key? key, required this.images, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      appBar: AppBar(title: const Text("Image Viewer")),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: ExtendedImage.memory(
              images[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
