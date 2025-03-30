import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return BottomNavigationBar(
          currentIndex: navigationProvider.currentIndex,
          onTap: (index) {
          if (index != navigationProvider.currentIndex) {
            
            navigationProvider.setIndex(index);

            // to ammend this go to main.dart
            switch (index) {
              case 0:
               Navigator.pushReplacement(
                context,
                NoAnimRouter(
                  child: HomePage(),
                ),
              );
                break;
              case 1:
                 Navigator.pushReplacement(
                context,
                NoAnimRouter(
                  child: AddImageScreen(),
                ),
              );
                break;
              case 2:
                 Navigator.pushReplacement(
                context,
                NoAnimRouter(
                  child: AlbumScreen(),// Define the route name here
                ),
              );
                break;
              default:
                break;
            }
          }
        },
          fixedColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.black,
          unselectedFontSize: 10, // Slightly increased font size
          selectedLabelStyle: TextStyle(
            overflow: TextOverflow.visible,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            overflow: TextOverflow.visible,
            fontSize: 12,
            color: Colors.black54,
          ),

          items: [
    BottomNavigationBarItem(
      icon: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/Home1.svg',
            height: 32,
            width: 32,
          ),
          if (navigationProvider.currentIndex == 0)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: Colors.black,
            ),
        ],
      ),
      label: ''
    ),
    BottomNavigationBarItem(
      key: const Key('add_images_screen_nav'),
      icon: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/Plus_circle.svg',
            height: 32,
            width: 32,
          ),
          if (navigationProvider.currentIndex == 1)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: Colors.black,
            ),
        ],
      ),
      label: ''
    ),
    BottomNavigationBarItem(
      key: const Key('view_gallery_screen_nav'),
      icon: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/Folder.svg',
            height: 32,
            width: 32,
          ),
          if (navigationProvider.currentIndex == 2)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: Colors.black,
            ),
        ],
      ),
      label: ''
    ),
  ],
        );
      },
    );
  }
}