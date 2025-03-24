import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/animation_manager/anim_manager.dart';

class WidgetUtils {
  static Widget buildBackButton(BuildContext context, Widget path) {
  return IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        SadPageRouter(
          child: path,
        ),
      );
    },
  );
}

}