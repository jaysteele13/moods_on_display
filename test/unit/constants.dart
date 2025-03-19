import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:moods_on_display/utils/types.dart';

class UNIT_TEST {
  late File file; // late initialization since file will be initialized later
  late img.Image testImage; // Late initialization for the image
  late ImageBoundingBox IMAGE_BOUNDING_BOX; // Late initialization for the bounding box

  UNIT_TEST() {
    // initialize your variables in the constructor
    file = File('assets/test_images/sample.jpg');
    testImage = img.decodeImage(file.readAsBytesSync())!; // Using `!` to assert non-null (but handle potential null gracefully)
    
    // Now initialize IMAGE_BOUNDING_BOX with a valid Image
    IMAGE_BOUNDING_BOX = ImageBoundingBox(
      image: testImage,
      boundingBox: BoundingBox(x: 10, y: 10, width: 40, height: 40),
    );
  }

  static void visualTestLogger(String description, bool passed) {
    final String emoji = passed ? '✅' : '❌';
    final String status = passed ? 'PASS' : 'FAIL';
    
    // Color output for terminals that support ANSI escape codes
    final String colorStatus = passed 
        ? '\x1B[32m$status\x1B[0m'  // Green for pass
        : '\x1B[31m$status\x1B[0m'; // Red for fail

    final String description_header = '\x1B[35mDESCRIPTION\x1B[0m';  // Green for pass

    print('$emoji $colorStatus\n📖 $description_header: $description\n'
    '------------------------------------------------------------------------');
}
}