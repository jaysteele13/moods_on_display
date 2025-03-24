import 'package:flutter/material.dart';

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    var tween = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
    .chain(CurveTween(curve: Curves.easeInOut));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
