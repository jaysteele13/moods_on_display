import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';
import 'package:moods_on_display/utils/constants.dart';

import 'package:image/image.dart' as img;  // Import the package for img.ColorRgb8

class DefaultColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color yellow = Color(0xFFEBB40E);
  static const Color yellow_rect = Color(0xFFfcfd95);
  static const Color blue = Color(0xFF7494EA);
  static const Color red = Color(0xFFA41616);
  static const Color purple = Color(0xFF740F74);
  static const Color green = Color(0xFF1AC793);
  static const Color lightGreen = Color(0xFF85A600);
  static const Color darkGreen = Color(0xFF357C5B);
  static const Color grey = Color(0xFFCEC8C8);
  static const Color darkGrey = Color(0xFF848282);
  static const Color orange = Color(0xFFdd7141);
  static const Color neutral = Color(0xFF5E7E70);
  static const Color black = Color(0xFF000000);

  static const Color user_profile = Color(0xFFD9D9D9);
  static const Color background = Color(0xFFEFEEF3);
  static const Color tickColor = Color(0xFF68C89B);
  static const Color selectButtonColor = Color(0xFF393636);


  // img.ColorRgb8 for Drawing
  static img.ColorRgb8 rgbBlue = img.ColorRgb8(116, 148, 234);
  static img.ColorRgb8 rgbYellow = img.ColorRgb8(235, 180, 14);
  static img.ColorRgb8 rgbRed = img.ColorRgb8(164, 22, 22);
  static img.ColorRgb8 rgbPurple = img.ColorRgb8(116, 15, 116);
  static img.ColorRgb8 rgbGreen = img.ColorRgb8(133, 160, 0);
  static img.ColorRgb8 rgbNeutral = img.ColorRgb8(94, 126, 112);
  static img.ColorRgb8 rgbOrange = img.ColorRgb8(255, 165, 0);

 

 


  // You can add more methods to convert other colors similarly
}


class WidgetUtils {

  static const double defaultToolBarHeight = 56;

  static const double defaultPadding = 16.0;
  static const double titleFontSize = 24.0;
  static const double titleFontSize_75 = 20.0;
  static const double titleFontSize_675 = 18.0;
  static const double paragraphFontSize = 16.0;
  static const double paragraphFontSize_875 = 14.0;
  static const double paragraphFontSize_75 = 12.0;

  static const double containerWidth = 350.0;
  static BoxDecoration containerDecoration = BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(26, 0, 0, 0),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    );
                   
  static Widget buildTitle(String title, {double fontSize = titleFontSize, Color color = DefaultColors.black, bool isUnderlined = false, bool isBold = true}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
        decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
        decorationColor: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget buildParagraph(String paragraph, {double fontSize = paragraphFontSize, bool isCentered = true}) {
  const Map<String, Color> colorMap = {
    'p': DefaultColors.purple,
    'r': DefaultColors.red,
    'g': DefaultColors.green,
    'G': DefaultColors.grey,
    'b': DefaultColors.blue,
    'o': DefaultColors.orange,
    'y': DefaultColors.yellow,
    'D': DefaultColors.black,
    'w': DefaultColors.white,
  };

  final List<InlineSpan> spans = [];
  final regex = RegExp(r'(\*.*?\*)|\{color->(\w+)(,b)?(,u)?\}(.*?)\{/color\}|([^*{]+)');
  final matches = regex.allMatches(paragraph);

  for (final match in matches) {
    if (match[1] != null) {
      // Bold text using *text*
      spans.add(TextSpan(
        text: match[1]!.substring(1, match[1]!.length - 1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
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
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
        ),
      ));
    } else if (match[6] != null) {
      // Regular text
      spans.add(TextSpan(
        text: match[6],
        style: TextStyle(
          fontSize: fontSize,
          color: DefaultColors.black,
        ),
      ));
    }
  }

  return Container(
    alignment: isCentered ? Alignment.center: Alignment.centerLeft, // Center the content within the container
    child: RichText(
      softWrap: true,  // Allow text to wrap to the next line
      maxLines: null,
      textAlign: isCentered ? TextAlign.center : TextAlign.left,
      text: TextSpan(
        style: const TextStyle(color: DefaultColors.black),
        children: spans,
      ),
    ),
  );
}

static String getEmojiByText(String text) {
  switch (text) {
    case EMOTIONS.happy:
      return '😊';
    case EMOTIONS.sad:
      return '😪';
    case EMOTIONS.angry:
      return '🤬';
    case EMOTIONS.fear:
      return '😱';
    case EMOTIONS.disgust:
      return '🤢';
    case EMOTIONS.neutral:
      return '🫥';
    case EMOTIONS.surprise:
      return '😲';
    default:
      return '❓'; // Default emoji for unknown emotions
  }
}


static Color getColorByEmotion(String emotion) {
  switch (emotion) {
    case EMOTIONS.happy:
      return DefaultColors.yellow;
    case EMOTIONS.sad:
      return DefaultColors.blue;
    case EMOTIONS.angry:
      return DefaultColors.red;
    case EMOTIONS.fear:
      return DefaultColors.purple;
    case EMOTIONS.disgust:
      return DefaultColors.lightGreen;
    case EMOTIONS.neutral:
      return DefaultColors.neutral;
    case EMOTIONS.surprise:
      return DefaultColors.orange;
    default:
      return DefaultColors.black;
  }
}

  static Widget buildBackButton(BuildContext context, Widget path) {
  return IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        NoAnimRouter(
          child: path,
        ),
      );
    },
  );
}

}