import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/pages/login.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';

class FlowTree  extends StatefulWidget {
  const FlowTree({Key? key}) : super(key: key);

  @override
  State<FlowTree> createState() => _FlowState();
}

class _FlowState extends State<FlowTree> {

   @override
  void dispose() {
    // Close the database when the app is disposed
    DatabaseManager.instance.closeDatabase();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, 
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return HomePage();
        } else {
          return const LoginScreen();
        }
      });
  }
}