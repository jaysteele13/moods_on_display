import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/logic/navigation/navigation_provider.dart';
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
            navigationProvider.setIndex(index);
            

            // based on index determine what happens next, have page manager
            // Custom actions based on the index
            switch (index) {
              case 0:
                // Navigate to Home Screen or perform a Home action
                Navigator.pushReplacementNamed(context, '/home');
                // print('index: ${navigationProvider.currentIndex}');
                break;
              case 1:
                // Navigate to Albums Screen or perform an Albums action
                // Navigator.pushNamed(context, '/albums');
                print('index: ${navigationProvider.currentIndex}');
                break;
              case 2:
                // Navigate to Add Images Screen or perform an Add Images action
                // Navigator.pushNamed(context, '/add_images');
                print('index: ${navigationProvider.currentIndex}');
                break;
              case 3:
                // Navigate to Slideshows Screen or perform a Slideshows action
                // Navigator.pushNamed(context, '/slideshows');
                print('index: ${navigationProvider.currentIndex}');
                break;
              case 4:
                // Navigate to Profile Screen or perform a Profile action
                Navigator.pushReplacementNamed(context, '/profile');
                break;
              default:
                break;
            }
          },
          fixedColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.pink,
          unselectedFontSize: 5,

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
              icon: SvgPicture.asset(
                'assets/icons/album.svg',
                height: 20,
                width: 20,
              ),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                height: 20,
                width: 20,
              ),
              label: 'Add Images',
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