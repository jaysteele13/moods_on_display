import 'package:flutter/material.dart';
import 'navbar_widget.dart'; // Ensure you have this file

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Color? backgroundColor;

  const BaseScaffold({required this.body, this.appBar, this.backgroundColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: const NavigationMenu(),
      backgroundColor: backgroundColor,
    );
  }
}
