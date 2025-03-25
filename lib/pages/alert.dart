import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, // Use dynamic title passed in constructor
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
...paragraph.asMap().entries.map((entry) {
  int index = entry.key;
  String text = entry.value;

  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.normal,
                fontSize: 16),),
        const SizedBox(height: 10),
        if (index != paragraph.length - 1) const Divider(), // Add Divider only if it's not the last item
        const SizedBox(height: 10), // Space after divider
      ],
    ),
  );
}),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(buttonText ?? 'Exit'), // Use buttonText or default 'Exit'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
