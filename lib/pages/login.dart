import 'package:flutter/material.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';
import '../logic/authentication/auth_bloc.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier userCredential = ValueNotifier('');


  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) {
      if(fbUser !=null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute (builder: (context) => HomePage()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Login Screen')),
        body: Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          iconSize: 40,
                          icon: Image.asset(
                            'assets/images/google.png',
                          ),
                          onPressed: () => authBloc.loginGoogle())
                        ),
                      ),
                    );
  }
}