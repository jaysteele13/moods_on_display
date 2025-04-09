

import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/utils.dart';

class AnimatedSelectedImagesNotification extends StatefulWidget {
  final int selectedCount;
  final VoidCallback? onClearSelection;
  final Future<void> Function()? onDelete;
  final String onFunctionButtonText;
  final bool isVisible;

  const AnimatedSelectedImagesNotification({
    Key? key,
    required this.selectedCount,
    required this.onFunctionButtonText,
    required this.isVisible,
    this.onClearSelection,
    this.onDelete,
  }) : super(key: key);

  @override
  State<AnimatedSelectedImagesNotification> createState() =>
      _AnimatedSelectedImagesNotificationState();
}

class _AnimatedSelectedImagesNotificationState extends State<AnimatedSelectedImagesNotification> {
  bool _internalVisible = false;
  bool _wasManuallyDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _internalVisible = widget.isVisible;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedSelectedImagesNotification oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restore if new items are selected after manual dismiss
    if (widget.selectedCount > 0 && _wasManuallyDismissed) {
      setState(() {
        _internalVisible = true;
        _wasManuallyDismissed = false;
      });
    }

    // Respond to external visibility changes
    if (oldWidget.isVisible != widget.isVisible) {
      setState(() {
        _internalVisible = widget.isVisible;
      });
    }

    // Automatically show if selection is updated (and we weren't dismissed)
    if (widget.selectedCount > 0 && !_internalVisible && !_wasManuallyDismissed) {
      setState(() {
        _internalVisible = true;
      });
    }
  }

  void _dismiss() {
    setState(() {
      _internalVisible = false;
      _wasManuallyDismissed = true;
    });
  }

  Widget buildDismissableButton(Color color, String text, bool selectedImages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      constraints: const BoxConstraints(maxWidth: 250),
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
              onTap: widget.onDelete != null
                  ? () async {
                      await widget.onDelete!();
                    }
                  : widget.onClearSelection,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _internalVisible ? 20 : -180,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 100) {
            _dismiss();
          }
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.selectedCount > 0)
                buildDismissableButton(
                    DefaultColors.blue, 'Selected Images: ${widget.selectedCount}', true),
                    const SizedBox(width: 10),
                    buildDismissableButton(DefaultColors.red, widget.onFunctionButtonText, false),
            ],
          ),
        ),
      ),
    );
  }
}


// class AnimatedSelectedImagesNotification extends StatefulWidget {
//   final int selectedCount;
//   final VoidCallback? onClearSelection; // Callback to clear selected images
//   final Future<void> Function()? onDelete;
//   final String onFunctionButtonText;
//   final bool? isVisible;

//   const AnimatedSelectedImagesNotification({
//     Key? key,
//     required this.selectedCount,
//     required this.onFunctionButtonText,
//     this.onClearSelection,
//     this.onDelete,
//     this.isVisible
//   }) : super(key: key);

//   @override
//   _AnimatedSelectedImagesNotificationState createState() => _AnimatedSelectedImagesNotificationState();
// }

// class _AnimatedSelectedImagesNotificationState extends State<AnimatedSelectedImagesNotification> {
//   bool _isVisible = false;

//   @override
//   void didUpdateWidget(covariant AnimatedSelectedImagesNotification oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.selectedCount != 0) {
//       setState(() {
//         _isVisible = true;
//       });
//     }
//   }

//   void _dismiss() {
//     setState(() {
//       _isVisible = false;
//     });
//   }

// Widget buildDismissableButton(Color color, String text, bool selectedImages) {
//   return Container(
//     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//     constraints: BoxConstraints(maxWidth: 250),
//     decoration: BoxDecoration(
//       color: color,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 10,
//           spreadRadius: 5,
//         ),
//       ],
//     ),
//     child: !selectedImages
//         ? GestureDetector(
//             onTap: widget.onDelete != null
//                 ? () async {
//                     widget.onDelete!();
//                   }
//                 : widget.onClearSelection!, // Action when tapped
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           )
//         : Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 text, // Display the number of selected images
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPositioned(
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       bottom: _isVisible ? 20 : -180, // Moves both buttons up when visible
//       left: 0,
//       right: 0,
//       child: GestureDetector(
//         onVerticalDragEnd: (details) {
//           if (details.primaryVelocity! > 100) { // Swiped down
//             _dismiss();
//           }
//         },
//         child: Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Clear All Button
//               if (widget.selectedCount > 0)
//                 buildDismissableButton(DefaultColors.blue, 'Selected Images: ${widget.selectedCount}', true),
//                 SizedBox(width: 10), // Space between buttons
//                 buildDismissableButton(DefaultColors.red, widget.onFunctionButtonText, false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

