import 'package:flutter/material.dart';
import '../logic/authentication/auth.dart';
import 'package:moods_on_display/logic/navigation/base_scaffold.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier userCredential = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBar: AppBar(title: const Text('Profile Screen')),
        body: ValueListenableBuilder(
            valueListenable: userCredential,
            builder: (context, value, child) {
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
                            userCredential.value = await Auth().signInWithGoogle();
                            if (userCredential.value != null)
                              print(userCredential.value.user!.email);
                          },
                        ),
                      ),
                    );
            }));
  }
}