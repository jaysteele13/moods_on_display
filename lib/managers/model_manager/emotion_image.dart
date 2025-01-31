import 'dart:io';

class EmotionImage {
  final File? selectedImage;
  final Map<String, double> emotions;
  final bool valid;

  EmotionImage({
    this.selectedImage,
    required this.emotions,
    required this.valid,
  });

  /// Determines the highest emotion based on values
  String get highestEmotion {
    if (emotions.isEmpty) return "Unknown";
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}