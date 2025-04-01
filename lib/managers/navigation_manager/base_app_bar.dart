import 'package:flutter/material.dart';
import 'package:moods_on_display/utils/utils.dart';


class Base extends StatelessWidget {
  final Widget title;  
  final Color? backgroundColor;

  const Base({required this.title, this.backgroundColor, Key? key}) : super(key: key);

  // Static method to create and return an AppBar
  static AppBar appBar({required Widget title,  Widget? leading, Color? backgroundColor = DefaultColors.background}) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: title,
      leading: leading ?? const SizedBox(), // Hides the default back button
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBar(title: title, backgroundColor: backgroundColor);
  }
}



