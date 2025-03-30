import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/pages/home.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Centralized navigation function
  void navigateTo(int index, BuildContext context) {
    if (index != _currentIndex) {
      setIndex(index);

      Widget screen;
      switch (index) {
        case 0:
          screen = HomePage();
          break;
        case 1:
          screen = AddImageScreen();
          break;
        case 2:
          screen = AlbumScreen();
          break;
        default:
          return;
      }

      Navigator.pushReplacement(
        context,
        NoAnimRouter(child: screen),
      );
    }
  }
}
