import 'package:flutter/material.dart';
import '../logic/authentication/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await Auth().signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      print('Sign-in failed: $error');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Log in and loading state baked into one.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _isLoading ? Text('Logging in') : Text('Login Screen')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  iconSize: 40,
                  icon: Image.asset('assets/images/google.png'),
                  onPressed: _handleSignIn,
                ),
              ),
      ),
    );
  }
}
