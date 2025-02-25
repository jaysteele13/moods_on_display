import 'dart:typed_data';

import 'package:image/image.dart' as img;

class EmotionPointer {
  /*
I need to amend what db data object gets stored in the DB
- this class needs to be amended to store multiple emotions per image
- each emotion will bounding box coordinates of where the face is
*/
  String pointer; // file due to efficiency reasons and clairty must be -> change this to FilePath rather than actual File!
  String highestEmotion;
  
  EmotionPointer({
    required this.pointer,
    required this.highestEmotion,
  });

  // find a way the database can parse this into the database
  factory EmotionPointer.fromMap(Map<String, dynamic> map) {
    return EmotionPointer(
      pointer: map['id'] as String,
      highestEmotion: map['emotion'] as String,
    );
  }

}

class ImagePointer {
  Uint8List image;
  String pointer;

  ImagePointer({
    required this.image,
    required this.pointer
  });
}
/*
batch.insert(
        'bounding_boxes',
        {
          'emotion_id': emotionPointer,
          'emotion': ebbx.emotion,
          'x': ebbx.boundingBox.x, // No need for `ebb.boundingBox.x`, just `ebb.x`
          'y': ebbx.boundingBox.y,
          'width': ebbx.boundingBox.width,
          'height': ebbx.boundingBox.height,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
*/


// create new type which holds a string and 4 doubles
class EmotionBoundingBox {
  String emotion;
  BoundingBox boundingBox;

  EmotionBoundingBox({
    required this.emotion,
    required this.boundingBox
  });

  factory EmotionBoundingBox.fromMap(Map<String, dynamic> map) {
    return EmotionBoundingBox(
      emotion: map['emotion'] as String,
      boundingBox: BoundingBox(x: map['x'] as int,
       y: map['y'] as int, 
       width: map['width'] as int,
        height: map['height'] as int),
    );
  }
}


class ImageBoundingBox {
  img.Image image;
  BoundingBox boundingBox;

  ImageBoundingBox({
    required this.image,
    required this.boundingBox
  });
}

class BoundingBox {
  int x;
  int y;
  int width;
  int height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height
  });
}