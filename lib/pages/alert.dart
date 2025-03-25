import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

class AlertScreen extends StatelessWidget {
  final String title;
  final List<String> paragraph;
  final String? buttonText;

  const AlertScreen({
    super.key,
    required this.title,
    required this.paragraph,
    this.buttonText,
  });

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
    child: Center(
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetUtils.buildTitle(HOME_SCREEN_START_UP.title),
            const SizedBox(height: 20), // More space between title and content
            ...paragraph.asMap().entries.map((entry) {
              int index = entry.key;
              String text = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    WidgetUtils.buildParagraph(text),
                    const SizedBox(height: 10),
                    if (index != paragraph.length - 1) const Divider(),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(buttonText ?? 'Exit'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


}

