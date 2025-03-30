import 'dart:math';

import 'package:flutter/material.dart';

class NoAnimRouter extends PageRouteBuilder {
  final Widget child;

  NoAnimRouter({required this.child})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            // Simply return the child widget without triggering any additional navigation
            return child;
          },
          // Disable any animation
          transitionDuration: Duration.zero, // Set the transition duration to zero
          reverseTransitionDuration: Duration.zero, // Disable reverse transition animation
        );
}

class Animations {

  static Widget animateTextWave(String text, double fontSize) {
    return Center(
      child:  TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 2),
      builder: (context, value, child) {
        List<Widget> letterWidgets = [];

        // Split the text into individual letters
        for (int i = 0; i < text.length; i++) {
          // Create a wave effect with twice the cycle per animation and larger swell
          double scaleValue = 1 + 0.3 * sin(value * pi * 4 + (i * pi / 5)); // Twice per cycle and larger swell

          // Ensure letters return to their original size at the end of animation
          scaleValue = value < 1.0 ? scaleValue : 1.0;  // Reset to original size when animation completes

          letterWidgets.add(
            Transform(
              transform: Matrix4.identity()..scale(scaleValue),
              alignment: Alignment.center,
              child: Text(
                text[i],
                style: TextStyle(
                  fontSize: fontSize, // Custom font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Custom color (can change based on your needs)
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
    ));
}
  // Static method to return a PageRouteBuilder with a fade transition
  static PageRouteBuilder animFade(BuildContext context, Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apply a fade transition animation
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation, // Use the animation passed to transitionsBuilder
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 500), // Duration for the fade transition
      reverseTransitionDuration: Duration(milliseconds: 500), // Duration for reverse transition
    );
  }
}



class FadeThroughRoute extends MaterialPageRoute {
  final Widget page;

  FadeThroughRoute({required this.page})
      : super(
          builder: (context) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeInOut,
                ),
              ),
              child: page,
            );
          },
                );
        
          @override
          Duration get transitionDuration => Duration(milliseconds: 500); // Duration of the fade-through
        
          @override
          Duration get reverseTransitionDuration => Duration(milliseconds: 500); // Duration of reverse fade-through
        
}
