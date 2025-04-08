import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  final bool? disableNavBar;
  const NavigationMenu( {super.key, this.disableNavBar,});


  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return IgnorePointer(
          ignoring: widget.disableNavBar == true,
          child: Opacity(
            opacity: widget.disableNavBar == true ? 0.5 : 1.0,
            child: BottomNavigationBar(
              currentIndex: navigationProvider.currentIndex,
              onTap: (index) => navigationProvider.navigateTo(index, context),
              fixedColor: Colors.black,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              unselectedItemColor: Colors.black,
              unselectedFontSize: 10,
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
                  icon: _buildNavItem('assets/icons/Home1.svg', 0, navigationProvider),
                  label: widget.disableNavBar == true ? 'Disabled' : '',
                ),
                BottomNavigationBarItem(
                  key: const Key('add_images_screen_nav'),
                  icon: _buildNavItem('assets/icons/Plus_circle.svg', 1, navigationProvider),
                  label: widget.disableNavBar == true ? 'Disabled' : '',
                ),
                BottomNavigationBarItem(
                  key: const Key('view_gallery_screen_nav'),
                  icon: _buildNavItem('assets/icons/Folder.svg', 2, navigationProvider),
                  label: widget.disableNavBar == true ? 'Disabled' : '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


  Widget _buildNavItem(String iconPath, int index, NavigationProvider provider) {
    return Column(
      children: [
        SvgPicture.asset(iconPath, height: 32, width: 32),
        if (provider.currentIndex == index)
          Container(
            margin: EdgeInsets.only(top: 4),
            height: 2,
            width: 24,
            color: Colors.black,
          ),
      ],
    );
  }
