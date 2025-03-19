import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  static Auth instance = Auth._internal(); // Replaceable in tests
  Auth._internal();

  factory Auth() => instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // instance for auth functions

  User? get currentUser => _firebaseAuth.currentUser; // gets user

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // constant stream of changes

  // -------------------- Google Login -----------------------
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on Exception catch (e) {
        print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }


  Future<void> SignOut() async {
    await _firebaseAuth.signOut();
  }

  // ------------------- End ----------------------
}

