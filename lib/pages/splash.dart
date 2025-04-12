import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:moods_on_display/pages/home.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedSplashScreen(
      splash: 
        Center(child: 
        Lottie.asset('assets/lottie/SplashV2.json'),)
      ,
      nextScreen: HomePage(),
      splashTransition: SplashTransition.scaleTransition,
      duration: 5500,
      splashIconSize: 600,
    );
  }
}