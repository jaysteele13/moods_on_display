import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class AuthBloc {
  final auth = Auth();
  final googleSignIn = GoogleSignIn(scopes: ['email']);

  Stream<User?> get currentUser => auth.currentUser;

  Future<void> loginGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  if (googleUser == null) {
      // User cancelled the sign-in
      print('Sign-in aborted by user.');
      return;
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken
    );

    // firebase sign in
    final result = await auth.signInWithCredential(credential);
    
    // Proceed with signed-in user
    print('User signed in: ${result.user?.displayName}');
  } catch (error) {
    print('Error during Google sign-in: $error');
  }
}

Future<bool> logOutGoogle() async {
    try {
      await auth.logout();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }



}