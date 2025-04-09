import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/utils/utils.dart';

class AlertScreen extends StatelessWidget {
  final String title;
  final List<String> paragraph;
  final String? buttonText;
  final bool? icons;
  final Function(BuildContext)? onButtonPressed;  // Change to accept context

  const AlertScreen({
    super.key,
    required this.title,
    required this.paragraph,
    this.onButtonPressed,
    this.buttonText,
    this.icons = false,
  });
@override
Widget build(BuildContext context) {
  
  return Padding(
    padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
    child: Center(
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: icons == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            WidgetUtils.buildTitle(title, isUnderlined: true),
            const SizedBox(height: 20), // More space between title and content
            ...paragraph.asMap().entries.map((entry) {
              int index = entry.key;
              String text = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: icons == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    icons == true ?
                    Padding(padding: const EdgeInsets.all(WidgetUtils.defaultPadding), 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (index == 0) ...[
                          const Icon(Icons.camera_alt_outlined, size: 48, color: DefaultColors.black),
                          const SizedBox(width: 16.0),
                        ],
                        if (index == 1) ...[
                          SvgPicture.asset('assets/icons/Plus_circle.svg', height: 48, width: 48),
                          const SizedBox(width: 16.0),
                        ],
                        // Make the text wrap and truncate if necessary
                        Expanded(
                          child: WidgetUtils.buildParagraph(text, isCentered: false, fontSize: WidgetUtils.titleFontSize_675),
                        ),
                      ],
                    ) ):
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
                onPressed: () async {
                  final currentContext = context;
                  Navigator.of(currentContext).pop();
                  await Future.delayed(const Duration(milliseconds: 100)); // Wait for animation
                  if (currentContext.mounted && onButtonPressed != null) {
                    onButtonPressed!(currentContext);
                  }
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

