

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moods_on_display/utils/utils.dart';

class AnimatedSelectedImagesNotification extends StatefulWidget {
  final int selectedCount;
  final VoidCallback onClearSelection; // Callback to clear selected images

  const AnimatedSelectedImagesNotification({
    Key? key,
    required this.selectedCount,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  _AnimatedSelectedImagesNotificationState createState() => _AnimatedSelectedImagesNotificationState();
}

class _AnimatedSelectedImagesNotificationState extends State<AnimatedSelectedImagesNotification> {
  bool _isVisible = false;
  bool _isDismissed = false; // Tracks if user dismissed manually

  @override
  void didUpdateWidget(covariant AnimatedSelectedImagesNotification oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedCount > 0) {
      setState(() {
        _isVisible = true;
        _isDismissed = false; // Reset dismissal when a new image is selected
      });
    }
  }

  void _dismiss() {
    setState(() {
      _isVisible = false;
      _isDismissed = true; // Prevent auto-showing until a new image is selected
    });
  }

Widget buildDismissableButton(Color color, String text, bool selectedImages) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    constraints: BoxConstraints(maxWidth: 250),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: !selectedImages
        ? GestureDetector(
            onTap: widget.onClearSelection, // Action when tapped
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text, // Display the number of selected images
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
  );
}


  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _isVisible ? 20 : -180, // Moves both buttons up when visible
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 100) { // Swiped down
            _dismiss();
          }
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear All Button
              if (widget.selectedCount > 0)
                buildDismissableButton(DefaultColors.blue, 'Selected Images: ${widget.selectedCount}', true),
                SizedBox(width: 10), // Space between buttons
                buildDismissableButton(DefaultColors.red, 'Clear all', false),
            ],
          ),
        ),
      ),
    );
  }
}
