import 'package:flutter/material.dart';

class SadPageRouter extends PageRouteBuilder {
  final Widget child;

  SadPageRouter({required this.child})
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
