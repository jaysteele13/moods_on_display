import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/widgets/navbar/navigation_provider.dart';
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
            print('index: ${navigationProvider.currentIndex}');
          },
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