import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';

class WidgetUtils {
  static Widget buildBackButton(BuildContext context, Widget path) {
  return IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        SadPageRouter(
          child: path,
        ),
      );
    },
  );
}

 static Widget bottomScreenAlert(
      BuildContext context, String title, List<String> paragraphs, String buttonText) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          
          // Paragraphs with bold and colored text
          ...paragraphs.map((paragraph) => _buildStyledText(paragraph)).toList(),

          const SizedBox(height: 24.0),

          // Exit Button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Widget _buildStyledText(String text) {
    final RegExp pattern = RegExp(r'\*(.*?)\*|\[(.*?)\]');
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in pattern.allMatches(text)) {
      // Add normal text before match
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      if (match.group(1) != null) {
        // Bold text between * *
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        // Colored text between [ ]
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(color: Colors.blue),
        ));
      }
      
      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: spans,
        ),
      ),
    );
  }

}