import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
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




  // ------------------ Native ---------------------------
  // Native Sign In
  Future<void> SignIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }


  Future<void> SignOut() async {
    await _firebaseAuth.signOut();
  }

  // Create Account
  Future<void> CreateUser({
    required String email,
    required String password
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }
  // ------------------- End ----------------------
}

