import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
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
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/album');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/add_images');
                break;
              case 3:
                // Navigator.pushReplacementNamed(context, '/slideshows');
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/profile');
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
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 20,
                width: 20,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              key: const Key('view_gallery_screen_nav'),
              icon: SvgPicture.asset(
                'assets/icons/album.svg',
                height: 20,
                width: 20,
              ),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              key: const Key('add_images_screen_nav'),
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                height: 20,
                width: 20,
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/slideshow.svg',
                height: 20,
                width: 20,
              ),
              label: 'Slideshows',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/profile.svg',
                height: 20,
                width: 20,
              ),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}