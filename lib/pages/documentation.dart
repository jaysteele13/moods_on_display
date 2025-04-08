import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:moods_on_display/widgets/utils/utils.dart';

class DocumentationScreen extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> paragraph;
  final List<String>? iconPaths;
  final String? image;

  const DocumentationScreen({
    super.key,
    required this.title,
    required this.paragraph,
    required this.color,
    this.iconPaths,
    this.image,
  });

@override
Widget build(BuildContext context) {
  return BaseScaffold(
    backgroundColor: DefaultColors.background,
    body: Center(
      child: Stack(
        children: [
          Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                WidgetUtils.buildTitle(
                  title,
                  color: color,
                  isUnderlined: true,
                ),
                SizedBox(height: 16),
                // If image is true then:
                image != null && image!.isNotEmpty ?
                Image.asset(
                  image ?? '',
                  height: 150,
                  width: 300,
                  fit: BoxFit.contain,
                ) : SizedBox(),
                SizedBox(height: 32),

                // If Icon paths are false this indicates that Data will be used will be displayed!
                if(iconPaths == null || iconPaths!.isEmpty && image != null && image!.isNotEmpty) ...[
                  for (int i = 0; i < paragraph.length; i++) ...[
                    WidgetUtils.buildParagraph(
                      paragraph[i], 
                      fontSize: WidgetUtils.paragraphFontSize,
                      isCentered: false,
                    ),
                    SizedBox(height: 16),
                    if (i < paragraph.length - 1) ...[
                      Divider(color: DefaultColors.grey),
                    ],
                  ],
                  SizedBox(height: 32),
                ] else ...[
                // Loop through paragraphs
                for (int i = 0; i < paragraph.length; i++) ...[
                  if (iconPaths != null && iconPaths!.isNotEmpty && i != paragraph.length-1)...[
                    WidgetUtils.buildParagraph(
                    paragraph[i], 
                    fontSize: WidgetUtils.paragraphFontSize,
                    isCentered: false,
                  ),
                  ] else ...[
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WidgetUtils.buildParagraph(
                          '{color->D,b,u}Icons:{/color} ', 
                          fontSize: WidgetUtils.titleFontSize_75
                        ),
                        SizedBox(width: 32),
                        for (String iconPath in iconPaths!) 
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SvgPicture.asset(
                              iconPath,
                              height: 32,
                              width: 32,
                            ),
                          ),
                       
                      ],
                    ),
                    SizedBox(height: 8),
                       WidgetUtils.buildParagraph(
                    paragraph[i], 
                    fontSize: WidgetUtils.paragraphFontSize,
                    isCentered: true,
                  ),
                  ],
                  
                  // Divider between paragraphs
                  if (i < paragraph.length - 1) ...[
                    SizedBox(height: 16),
                    Divider(color: DefaultColors.grey),
                  ],
                ],
              ],
              ],
            ),
          ),
          
          // Close button with proper constraints
          Positioned(
            top: 8,
            right: 8,
            child: SizedBox(
              width: 40, // specify width
              height: 40, // specify height
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  Animations.animFade(
                     context, HomePage(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}

