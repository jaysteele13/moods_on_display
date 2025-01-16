import 'package:flutter/material.dart';
import '../logic/authentication/auth.dart';
import 'package:moods_on_display/logic/navigation/base_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  // Change userCredential to store UserCredential instead of String
  ValueNotifier<UserCredential?> userCredential = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: ValueListenableBuilder<UserCredential?>(
        valueListenable: userCredential,
        builder: (context, value, child) {
          if (value == null) {
            // If userCredential is null, show sign-in button
            return Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  iconSize: 40,
                  icon: Image.asset(
                    'assets/images/google.png',
                  ),
                  onPressed: () async {
                    // Sign in with Google
                    // UserCredential user = await Auth().signInWithGoogle();
                    // userCredential.value = user;
                    // if (user.user != null) {
                    //   print(user.user!.email);
                    // }
                  },
                ),
              ),
            );
          } else {
            // If user is logged in, show profile information
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User profile image
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.5, color: Colors.black54)),
                    child: Image.network(value.user!.photoURL ?? ''),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // User display name
                  Text(value.user!.displayName ?? ''),
                  const SizedBox(
                    height: 20,
                  ),
                  // User email
                  Text(value.user!.email ?? ''),
                  const SizedBox(
                    height: 30,
                  ),
                  // Logout button
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     // Sign out
                  //     await Auth().signOutFromGoogle();
                  //     // After signing out, update UI by calling setState()
                  //     setState(() {
                  //       userCredential.value = null; // Reset the userCredential
                  //     });
                  //   },
                  //   child: const Text('Logout'),
                  // )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}