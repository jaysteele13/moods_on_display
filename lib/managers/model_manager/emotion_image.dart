import 'package:moods_on_display/managers/image_manager/filePointer.dart';

class EmotionImage {
  FilePathPointer? selectedFilePathPointer; 
  final Map<String, double> emotions;
  final bool valid;
  String? mostCommonEmotion;
  

  EmotionImage({
    this.selectedFilePathPointer,
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