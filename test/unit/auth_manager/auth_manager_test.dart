import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../mocks/auth_mock/auth_mock.mocks.dart';
import '../constants.dart';


void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
  });

  // Mimic Standard signInWithGoogle function
  Future<dynamic> signInWithGoogle({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('exception->$e');
      return null;
    }
  }

  Future<void> SignOut({required FirebaseAuth firebaseAuth}) async {
    await firebaseAuth.signOut();
  }

  group('signInWithGoogle', () {

    test('should return UserCredential on successful sign-in', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuth);
      when(mockGoogleSignInAuth.accessToken).thenReturn('mockAccessToken');
      when(mockGoogleSignInAuth.idToken).thenReturn('mockIdToken');
      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await signInWithGoogle(firebaseAuth: mockFirebaseAuth, googleSignIn: mockGoogleSignIn);

      // Assert
      try {
        expect(result, isA<UserCredential>());
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        UNIT_TEST.visualTestLogger('successfully returns google UserCredential on sign-in', true);
      } catch(e) {
        UNIT_TEST.visualTestLogger('', false);
        rethrow;
      }
      
    });

    test('should return null when user cancels sign-in', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act
      final result = await signInWithGoogle(firebaseAuth: mockFirebaseAuth, googleSignIn: mockGoogleSignIn);

      // Assert
      try {
        expect(result, isNull);
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
        UNIT_TEST.visualTestLogger('returns null when user cancels during sign-in', true);
      } catch(e) {
        UNIT_TEST.visualTestLogger('', false);
        rethrow;
      }
     
    });

    test('should return null and catch exception on error', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Sign-in failed'));

      // Act
      final result = await signInWithGoogle(firebaseAuth: mockFirebaseAuth, googleSignIn: mockGoogleSignIn);

      // Assert
      try {
        expect(result, isNull);
        UNIT_TEST.visualTestLogger('return null and catch exception on error', true);
      } catch (e) {
        UNIT_TEST.visualTestLogger('return null and catch exception on error', false);
        rethrow;
      }
    });

  });

  group('sign out with google', () {
    test('should sign out when called', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());

      // Act
      await SignOut(firebaseAuth: mockFirebaseAuth);

      // Assert
      try {
        verify(mockFirebaseAuth.signOut()).called(1);
        UNIT_TEST.visualTestLogger('succesfully sign out when called', true);
      } catch(e) {
        UNIT_TEST.visualTestLogger('', false);
        rethrow;
      }
      
    });

    test('should throw error on sign out if it fails', () async {
      // Arrange
      when(await SignOut(firebaseAuth: mockFirebaseAuth)).thenThrow(FirebaseAuthException(code: 'sign-out-failed', message: 'Sign out failed'));
      try {
        expect(() async => await SignOut(firebaseAuth: mockFirebaseAuth), throwsA(isA<FirebaseAuthException>()));
        verify(SignOut(firebaseAuth: mockFirebaseAuth)).called(1);
        UNIT_TEST.visualTestLogger('throw exception on sign-out failure', true);
      } catch(e) {
        UNIT_TEST.visualTestLogger('', false);
        rethrow;
      }
});
  });
}
