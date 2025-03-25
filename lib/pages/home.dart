import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/pages/alert.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/home/home_constants.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isProfileSetUp = false; // will be told by db

  void _openAlert() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => AlertScreen(title: HOME_SCREEN_START_UP.title, paragraph: HOME_SCREEN_START_UP.paragraphs, buttonText: HOME_SCREEN_START_UP.buttonText),
    );
  }

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!isProfileSetUp) _openAlert();
     
  });
}

Widget _buildUserTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
      title,
      style: const TextStyle(
        fontSize: WidgetUtils.titleFontSize,
        fontWeight: FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    ),
    SizedBox(width: 8.0),
    Icon(Icons.mode_edit_outline_outlined, color: DefaultColors.black),
    ]);
  }

Widget _drawUserProfile() {
   return Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                child: SvgPicture.asset(
                  'assets/icons/User.svg',
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.all(0),
                
                  child: Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
}

Widget _buildUserStats(String primary, String secondary, bool inverted) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: inverted
        ? [
            Text(
              secondary,
              style: TextStyle(
                fontSize: WidgetUtils.paragraphFontSize*0.75,
                fontWeight: FontWeight.normal,
                color: DefaultColors.darkGrey
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              primary,
              style: TextStyle(
                fontSize: WidgetUtils.titleFontSize_75,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ]
        : [
            Text(
              primary,
              style: TextStyle(
                fontSize: WidgetUtils.titleFontSize_75,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              secondary,
              style: TextStyle(
                fontSize: WidgetUtils.paragraphFontSize*0.75,
                fontWeight: FontWeight.normal,
                color: DefaultColors.darkGrey
              ),
              textAlign: TextAlign.left,
            ),
          ],
  );
}


Widget buildUserDetails(String username, int photos, String emotion) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(WidgetUtils.defaultPadding),
      child: Row(
        children: [
          _drawUserProfile(),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUserTitle(username),
                
                Divider(color: DefaultColors.grey, thickness: 1),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUserStats(photos.toString(), 'Photos', false),
                    SizedBox(width: 16),
                    Container(height: 50, width: 1, color: DefaultColors.grey),
                    SizedBox(width: 16),
                    _buildUserStats(emotion, 'Mostly', true),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          backgroundColor: color,
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget buildUserAccessibility() {
    return Container(
      
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInfoButton(HOME_CONSTANTS.gettingStarted, DefaultColors.green),
          SizedBox(height: 16),
          _buildInfoButton(HOME_CONSTANTS.howWillDataBeUsed, DefaultColors.blue),
        ],
      ),
    );
  }

  Widget buildFeatures() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('Feature 1'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text('Feature 2'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
        ],
      ),
    );
  }


 @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: Text('Hub')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildUserDetails('Jay Steele', 2, EMOTIONS.happy),
            Divider(color: DefaultColors.grey, thickness: 1),
            buildUserAccessibility(),
            Divider(color: DefaultColors.grey, thickness: 1),
            buildFeatures(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}


