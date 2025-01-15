import 'package:flutter/material.dart';
import 'package:moods_on_display/authentication/auth.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/pages/login.dart';

class FlowTree  extends StatefulWidget {
  const FlowTree({Key? key}) : super(key: key);

  @override
  State<FlowTree> createState() => _FlowState();
}

class _FlowState extends State<FlowTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, 
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return HomePage();
        } else {
          return const GoogleSignInScreen();
        }
      });
  }
}