import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moods_on_display/page_text/single_image/single_image_constant.dart';
import 'package:moods_on_display/utils/utils.dart';  // Import the necessary library for Future.delayed

class StaggeredContainer extends StatefulWidget {
  @override
  _StaggeredContainerState createState() => _StaggeredContainerState();
}

class _StaggeredContainerState extends State<StaggeredContainer> {
  bool _isFirstParagraphVisible = false;
  bool _isSecondParagraphVisible = false;
  bool _isThirdParagraphVisible = false;
  bool _isActivityIndicatorVisible = false;

  @override
  void initState() {
    super.initState();

    // Stagger the visibility of each element after a delay
    Future.delayed(Duration(milliseconds: 0), () {
      if(!mounted) return;
      setState(() {
        _isFirstParagraphVisible = true;
      });
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if(!mounted) return;
      setState(() {
        _isSecondParagraphVisible = true;
      });
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if(!mounted) return;
      setState(() {
        _isThirdParagraphVisible = true;
      });
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      if(!mounted) return;
      setState(() {
        _isActivityIndicatorVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                DefaultColors.green,
                DefaultColors.blue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
      width: 450,
      height: 450,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isFirstParagraphVisible)
            WidgetUtils.buildParagraph(
              SINGLE_IMAGE_CONSTANTS.loading,
              fontSize: WidgetUtils.titleFontSize,
              isCentered: true,
            ),
          if (_isSecondParagraphVisible)
            WidgetUtils.buildParagraph(
              SINGLE_IMAGE_CONSTANTS.emojis,
              fontSize: WidgetUtils.titleFontSize,
              isCentered: true,
            ),
          if (_isThirdParagraphVisible)
            WidgetUtils.buildParagraph(
              SINGLE_IMAGE_CONSTANTS.drawing,
              fontSize: WidgetUtils.titleFontSize,
              isCentered: true,
            ),
          if (_isActivityIndicatorVisible)
            const SizedBox(height: 16),
            const CupertinoActivityIndicator(radius: 20, animating: true),
        ],
      ),
    ),
        )
      ]));
  }
}
