import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';
import 'package:moods_on_display/utils/utils.dart';


class WidgetUtils {

  static const double defaultPadding = 16.0;
  static const double titleFontSize = 24.0;
  static const double titleFontSize_75 = 20.0;
  static const double paragraphFontSize = 16.0;

  static Widget buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget buildParagraph(String paragraph) {
  const Map<String, Color> colorMap = {
    'p': DefaultColors.purple,
    'r': DefaultColors.red,
    'g': DefaultColors.green,
    'b': DefaultColors.blue,
    'o': DefaultColors.orange,
    'y': DefaultColors.yellow,
    'D': DefaultColors.black,
  };

  final List<InlineSpan> spans = [];
  final regex = RegExp(r'(\*.*?\*)|\{color->(\w+)(,b)?(,u)?\}(.*?)\{/color\}|([^*{]+)');
  final matches = regex.allMatches(paragraph);

  for (final match in matches) {
    if (match[1] != null) {
      // Bold text using *text*
      spans.add(TextSpan(
        text: match[1]!.substring(1, match[1]!.length - 1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: paragraphFontSize,
          color: DefaultColors.black,
        ),
      ));
    } else if (match[2] != null && match[5] != null) {
      // Apply color, bold, and underline using {color->colorName,b,u}text{/color}
      final color = colorMap[match[2]] ?? DefaultColors.black;
      final isBold = match[3] != null;
      final isUnderlined = match[4] != null;

      spans.add(TextSpan(
        text: match[5],
        style: TextStyle(
          color: color,
          fontSize: paragraphFontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
        ),
      ));
    } else if (match[6] != null) {
      // Regular text
      spans.add(TextSpan(
        text: match[6],
        style: const TextStyle(
          fontSize: paragraphFontSize,
          color: DefaultColors.black,
        ),
      ));
    }
  }

  return Container(
    alignment: Alignment.center, // Center the content within the container
    width: double.infinity, // Ensure it takes full width
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: DefaultColors.black),
        children: spans,
      ),
    ),
  );
}



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

}