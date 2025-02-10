import 'dart:io';

class EmotionImage {
  File? selectedImage; // file due to efficiency reasons and clairty must be -> change this to FilePath rather than actual File!
  final Map<String, double> emotions;
  final bool valid;
  String? mostCommonEmotion;
  

  EmotionImage({
    this.selectedImage,
    required this.emotions,
    required this.valid,
    this.mostCommonEmotion
  });

  /// Determines the highest emotion based on values
  String get highestEmotion {
    
    if (emotions.isEmpty) return "Unknown";
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}