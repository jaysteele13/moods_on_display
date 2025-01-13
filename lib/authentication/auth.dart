import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // instance for auth functions

  User? get currentUser => _firebaseAuth.currentUser; // gets user

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // constant stream of changes

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
}

