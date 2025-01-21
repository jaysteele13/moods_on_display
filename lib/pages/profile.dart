import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';

class ProfileScreen extends StatelessWidget {
    // Login button widgets
    // Sign out and user logic
  final User? user = Auth().currentUser; // Current firebase object user

   Widget _userEmail() {
    return Text(user?.email ?? 'Users email');
  }

  Widget _userName() {
    return Text(user?.displayName ?? 'Users name');
  }

  Widget _profilePicture() {
    return Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 1.5, color: Colors.black54)),
                            child: Image.network(
                                user!.photoURL.toString()),
                          );
  }

  // Widget to sign out
  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print('Trying to log out...');
        await Auth().SignOut(); // Ensure sign out is awaited
        Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen after sign-out
      },
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: user == null // Check if the user is null
          ? Center(child: const Text('No user is logged in.'))
          : Column(
              children: [
                const SizedBox(height: 20),
                const Text('Your Profile!'),
                const SizedBox(height: 20),
                _userEmail(), // Display user email
                _userName(),
                _signOutButton(context), // Sign out button
                _profilePicture()
              ],
            ),
    );
  }
}