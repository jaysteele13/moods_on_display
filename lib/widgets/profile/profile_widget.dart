import 'package:flutter/material.dart';
import 'package:moods_on_display/logic/navigation/base_scaffold.dart';
import 'package:moods_on_display/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:moods_on_display/logic/authentication/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
    // Login button widgets
    // Sign out and user logic
  // final User? user = Auth().currentUser; // Current firebase object user

  //  Widget _userEmail() {
  //   return Text(user?.email ?? 'Users email');
  // }

  // // Widget to sign out
  
  class _ProfileScreenState extends State<ProfileScreen> {
      @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) {
      if(fbUser !=null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute (builder: (context) => LoginScreen()));
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // get context
    final authBloc = Provider.of<AuthBloc>(context);
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: Column(
              children: [
                const SizedBox(height: 20),
                const Text('Your Profile!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    authBloc.logOutGoogle();
                  },
                  child: const Text('Sign Out'),
                )
              ],
            ),
    );
  }
}

