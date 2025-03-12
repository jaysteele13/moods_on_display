import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import 'add_image_utils.dart';

void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;
  late AddImageUtils addImageUtils;



  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    mockAuth = MockAuth();
    mockUser = MockUser();
    addImageUtils = AddImageUtils();
    
    Auth.instance = mockAuth; // Inject mock Auth instance
  });

  // Mock App Flow Tree
  Widget mockAddImages(Widget child) {
    return MultiProvider(
      
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        Provider<Auth>.value(value: mockAuth),
        
      ],
      child: MaterialApp(
        home: child,
        routes: {
        '/add_images': (context) => AddImageScreen(), // Ensure the route exists
      },
      ),
    );
  }

  group('E2E Navigate to Gallery', () {

    // E2E => Displays Gallery
     testWidgets("From Flow Navigate to Home", (WidgetTester tester) async {
      // mocks successful login
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(mockAddImages(const FlowTree()));
      await tester.pumpAndSettle();
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

     });

    testWidgets("From Home Navigate to Gallery", (WidgetTester tester) async {
      // mocks successful login
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(mockAddImages(const FlowTree()));
      await tester.pumpAndSettle();
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

    
      // tap on add image
      await tester.tap(find.byKey(const Key('add_images_screen_nav')));
      await tester.pumpAndSettle();
      try {
          // Verify HomePage is loaded
      expect(find.byType(GalleryScreen), findsOneWidget, reason: "Gallery Screen should be displayed when user navigates to Add Images Screen");  
      expect(find.byKey(const Key('gallery_body')), findsOneWidget, reason: "Main body of Gallery through Add Images should then be opened on init");

      // add first image from first album

      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
      
    });

      testWidgets("Select Album and Add Images from Gallery", (WidgetTester tester) async {
      // mocks successful login
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(mockAddImages(const FlowTree()));
      await tester.pumpAndSettle();
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

    
      // tap on add image
      await tester.tap(find.byKey(const Key('add_images_screen_nav')));
      await tester.pumpAndSettle();
      try {

        await addImageUtils.verifyGalleryScreenDisplayed(tester);

        // Step 4: Scroll to find album and select it
        await addImageUtils.scrollToAndSelectAlbum(tester, 'recent');

        await addImageUtils.tapImagesInGrid(tester, 5);

      // add first image from first album

      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
      
    });

    
  });

}

