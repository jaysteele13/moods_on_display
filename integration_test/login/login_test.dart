import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/login.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../../test/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuth = MockAuth();
    mockUser = MockUser();
    Auth.instance = mockAuth; // Inject mock Auth instance
  });

  // Mock App Flow Tree
  Widget mockFlowTree(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        Provider<Auth>.value(value: mockAuth),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('FlowTree Widget Tests', () {
    testWidgets("Shows Login Screen when user is not authenticated", (WidgetTester tester) async {
      // mocks user not authenticated
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(mockFlowTree(const FlowTree()));

      await tester.pumpAndSettle();

      try {
          // Verify Login Page is loaded
      expect(find.byType(LoginScreen), findsOneWidget, reason: "Login Screen should be displayed when user is not authenticated");  
      // Additional verifications (Optional):
      String loginTitle = 'Login Screen';
        expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(loginTitle),
        ),
        findsOneWidget,
        reason: "AppBar should have the title '$loginTitle'",
      );
      expect(find.byKey(const Key('login_body')), findsOneWidget, reason: "Main body of Login should exist");
      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
    });

    testWidgets("Shows Home Page when user is authenticated", (WidgetTester tester) async {
      // mocks successful login
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(mockFlowTree(const FlowTree()));

      await tester.pumpAndSettle();
      try {
          // Verify HomePage is loaded
      expect(find.byType(HomePage), findsOneWidget, reason: "HomePage should be displayed when user is authenticated");  
      // Additional verifications (Optional):
        expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Home'),
        ),
        findsOneWidget,
        reason: "AppBar should have the title 'Home'",
      );
      expect(find.byKey(const Key('home_body')), findsOneWidget, reason: "Main body of HomePage should exist");
      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
      
    });
  });

  
}
