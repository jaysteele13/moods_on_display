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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool isProfileSetUp = false; // will be told by db
  String username = 'Guest';

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

      setState(() {
      });
     
  });
}

HomeValidationName formatTitleValidation(String title, double fontSize) {
  String newtitle;
  double newFontSize = fontSize;

  if (title.length > 15) {
    int spaceIndex = title.indexOf(' ', (1).toInt());
    if (spaceIndex != -1) {
      newtitle = '${title.substring(0, spaceIndex)}\n${title.substring(spaceIndex + 1)}';
      newFontSize = WidgetUtils.titleFontSize_75;
    } else {
      newtitle = title;
    }

    // Reduce size if there are multiple spaces
    int spaceCount = title.split(' ').length;
    if (spaceCount > 1) {
      newFontSize *= 0.75;
    }

    return HomeValidationName(text: newtitle, fontSize: newFontSize);
  }

  return HomeValidationName(text: title, fontSize: fontSize);
}

// Validate the length of the title, scale the title based off of the length,
Widget _buildUserTitle(String title) {

    double fontSize = WidgetUtils.titleFontSize;

    HomeValidationName textAndFont = formatTitleValidation(title, fontSize);
   

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
      textAndFont.text,
      style: TextStyle(
        fontSize: textAndFont.fontSize,
        fontWeight: FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    ),
    SizedBox(width: 8.0),
    IconButton(onPressed: () => _showNameModal(context),
    icon: Icon(Icons.mode_edit_outline_outlined, color: DefaultColors.black))
    ]);
  }

// Validate Name can't be any bigger than 30 characters
void _showNameModal(BuildContext context) {
  showDialog(
    context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(HOME_CONSTANTS.enterName),
          content: Form(
            key: _formKey,
            child: TextFormField(
            controller: _nameController,
            cursorColor: DefaultColors.neutral,
            cursorErrorColor: DefaultColors.red,
            
            decoration: InputDecoration(
              hintText: HOME_CONSTANTS.enterNamePlaceHolder,
              border: OutlineInputBorder(),
              
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: DefaultColors.neutral)),
              errorBorder: OutlineInputBorder(borderSide: BorderSide(color: DefaultColors.red))
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return HOME_CONSTANTS.validationText;
                }
                if(value.characters.length > 25) {
                  return HOME_CONSTANTS.validationTooLong;
                }
              return null;
              },
            ),
          ),
          actions: [
            _buildInfoButton('Submit', DefaultColors.darkGreen, () {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display the entered name
                  setState((
                  ) {
                     username = _nameController.text;
                     _nameController.clear();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hello, $username!')),
                  );
                }
            }),
            _buildInfoButton('Cancel', DefaultColors.red, () => Navigator.of(context).pop()),
          ],
        );
      },
    );
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

  Widget _buildInfoButton(String text, Color color, void Function() onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
      padding: EdgeInsets.all(WidgetUtils.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInfoButton(HOME_CONSTANTS.gettingStarted, DefaultColors.green, () => {}),
          SizedBox(height: 16),
          _buildInfoButton(HOME_CONSTANTS.howWillDataBeUsed, DefaultColors.blue, () => {}),
        ],
      ),
    );
  }

  Widget _buildFeatureTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
      title,
      style: TextStyle(
        fontSize: WidgetUtils.titleFontSize_75,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.underline, 
      ),
      textAlign: TextAlign.center,
    ),
    SizedBox(width: 8.0),
    ]);
  }

Widget _buildImage(String filePath) {
  bool isSvg = filePath.endsWith('.svg');
  
  return ClipRRect(
    borderRadius: BorderRadius.circular(5.0), // For rounded rectangle
    child: isSvg
        ? SvgPicture.asset(
            filePath,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => CircularProgressIndicator(), // Placeholder while loading
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.print,
                color: DefaultColors.darkGreen,
                size: 64,
              ); // Return an error icon if loading fails
            },
          )
        : Image.asset(
            filePath, // For PNG files or other image formats
            width: 64,
            height: 96,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image,
                color: DefaultColors.darkGreen,
                size: 64,
              ); // Return an error icon if loading fails
            },
          ),
  );
}


  Widget _buildFeatureButton(String text, String iconPath, String filePath, Color primaryColor, Color secondaryColor) {
    return Container(
      width: double.infinity,
      height: HOME_CONSTANTS.featureButtonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetUtils.buildTitle(text, fontSize: WidgetUtils.titleFontSize_75, color: DefaultColors.black),
                  SizedBox(height: 4),
                  SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    color: DefaultColors.black,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(WidgetUtils.defaultPadding),
            child: _buildImage(filePath),
          ),
        ],
      ),
    );
  }

  Widget buildFeatures() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(WidgetUtils.defaultPadding),
      child: Column(
        children: [
          _buildFeatureTitle(HOME_CONSTANTS.features),
          SizedBox(height: 16),
          _buildFeatureButton(HOME_CONSTANTS.viewAlbums, 'assets/icons/Folder.svg', '', DefaultColors.blue, DefaultColors.green),
          SizedBox(height: 16),
          _buildFeatureButton(HOME_CONSTANTS.predictEmotions, 'assets/icons/Plus_circle.svg', 'assets/icons/Vector.svg', DefaultColors.green, Colors.white),
        ],
      ),
    );
  }


@override
Widget build(BuildContext context) {
  return BaseScaffold(
    appBar:  AppBar(
  backgroundColor: DefaultColors.background,  // Set the background color to white
  title: WidgetUtils.buildTitle('Hub'), // Use the buildTitle method from the WidgetUtils class
),
    body: SingleChildScrollView( 
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildUserDetails(username, 2, EMOTIONS.happy),
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


