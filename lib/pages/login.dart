import '../authentication/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool loggedIn = true;

  // initialise text field
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // Configure Sign in Catch

  Future<void> _SignIn() async {
    try {
      await Auth().SignIn(email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch(e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> _CreateUser() async {
    try {
      await Auth().CreateUser(
        email: _controllerEmail.text, password: _controllerPassword.text
      );
    } on FirebaseAuthException catch(e) {
        setState(() {
          errorMessage = e.message;
        });
    }
  }

  // Widgets for page

  Widget _title() {
    return const Text('Login Screen');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(controller: controller, decoration: InputDecoration(
      labelText: title
    ),);
  }

  Widget _errorMessage() {
    return  Text(errorMessage == '' ? '' : 'Error:  $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(onPressed: loggedIn ? _SignIn : _CreateUser, child: Text(loggedIn ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(onPressed: () {
      setState(() {
        loggedIn != loggedIn;
      });
    }, child: Text(loggedIn ? 'Register instead' : 'Login instead'));
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
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton()
          ],
        )
      ),
    );
  }
}