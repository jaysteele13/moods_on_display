import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/utils.dart';

import 'dart:math';

class SetUpScreen extends StatefulWidget {
  final String title;
  final List<String> paragraph;
  final String? buttonText;

  const SetUpScreen({
    super.key,
    required this.title,
    required this.paragraph,
    this.buttonText,
  });

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<SetUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showWave = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );

    _scaleAnimation = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.5 && !_showWave) {
        setState(() {
          _showWave = true;
        });
      }
    });

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWaveText(String text, double fontSize) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 2),
      builder: (context, value, child) {
        List<Widget> letterWidgets = [];

        // Split the text into individual letters
        for (int i = 0; i < text.length; i++) {
          double scaleValue = 1 + 0.3 * sin(value * pi * 4 + (i * pi / 5));
          letterWidgets.add(
            Transform(
              transform: Matrix4.identity()..scale(scaleValue),
              alignment: Alignment.center,
              child: Text(
                text[i],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: letterWidgets,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show large text initially
                if (_controller.value < 0.5)
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text(
                        "Welcome to...",
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                // Show wave animation once scale animation finishes
                if (_showWave) ...[
                  SizedBox(height: 20),
                  _buildWaveText(widget.title, 36.0),
                  SizedBox(height: 20),
                ],
                // Final modal content with fade-in effect
                if (_controller.value >= 1.0) ...[
                  SizedBox(height: 20),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.paragraph.asMap().entries.map((entry) {
                        int index = entry.key;
                        String text = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              WidgetUtils.buildParagraph(text),
                              const SizedBox(height: 10),
                              if (index != widget.paragraph.length - 1) const Divider(),
                            ],
                          ),
                        );
                      }),
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
                            child: Text('Exit'),
                          ),
                    )],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

