
class EmotionPointer {
  String pointer; // file due to efficiency reasons and clairty must be -> change this to FilePath rather than actual File!
  String emotion;
  
  EmotionPointer({
    required this.pointer,
    required this.emotion
  });

  // database parsable -> change later
  factory EmotionPointer.fromMap(Map<String, dynamic> map) {
    return EmotionPointer(
      pointer: map['id'] as String,
      emotion: map['emotion'] as String,
    );
  }

}