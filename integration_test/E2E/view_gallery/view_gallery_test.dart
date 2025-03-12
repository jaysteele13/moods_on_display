import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;



  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    mockAuth = MockAuth();
    mockUser = MockUser();
    
    Auth.instance = mockAuth; // Inject mock Auth instance
  });

  // Mock App Flow Tree
  Widget mockViewGallery(Widget child) {
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
        '/album': (context) => AlbumScreen(), // Ensure the route exists
      },
      ),
    );
  }

  group('E2E Navigate to Gallery', () {

    testWidgets("View DB Images Multi-Screen", (WidgetTester tester) async {
      // mocks successful login
      when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(mockViewGallery(const FlowTree()));
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

    
  });

}

