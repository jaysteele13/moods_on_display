import 'package:flutter/material.dart';
// import firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moods_on_display/authentication/auth.dart';


class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser; // Current firebase object user


  // Widgets for home page

  Widget _title() {
    return const Text('Home');
  }

  Widget _userEmail() {
    return Text(user?.email ?? 'Users email');
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: Auth().SignOut, child: const Text('Sign Out.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userEmail(),
            _signOutButton()
          ],
        )
      )
    );
  }
}