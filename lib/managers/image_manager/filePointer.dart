import 'dart:io';

class FilePathPointer {
  String filePath; // file due to efficiency reasons and clairty must be -> change this to FilePath rather than actual File!
  String imagePointer;
  
  FilePathPointer({
    required this.filePath,
    required this.imagePointer
  });

  // database parsable -> change later
  factory FilePathPointer.fromMap(Map<String, dynamic> map) {
    return FilePathPointer(
      imagePointer: map['id'] as String,
      filePath: map['emotion'] as String,
    );
  }

}


class FilePointer {
  File file; // file due to efficiency reasons and clairty must be -> change this to FilePath rather than actual File!
  String imagePointer;
  
  FilePointer({
    required this.file,
    required this.imagePointer
  });

}