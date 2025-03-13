import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:provider/provider.dart';
import '../../../mocks/database_mock.dart';
import '../../../mocks/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import '../add_images/add_image_utils.dart';



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

      // Initialize Mock Database
    await MockDatabaseManager.instance.database;
    
    // Insert test data
    await MockDatabaseManager.instance.insertImage("1", "Happy");
    await MockDatabaseManager.instance.insertImage("2", "Sad");
    
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
  when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

  await tester.pumpWidget(mockViewGallery(const FlowTree()));
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget, reason: "HomePage should be displayed when user is authenticated");


  // For Ease We will add two test images for prediction that will return



  // Navigate to album screen
  await tester.tap(find.byKey(const Key('view_gallery_screen_nav')));
  await tester.pumpAndSettle();
  
  expect(find.byType(AlbumScreen), findsOneWidget, reason: "Album Screen should be displayed");

  // Select album "Happy"
  String selected_album = 'Fear';
  await addImageUtils.scrollToAndSelectAlbum(tester, selected_album);
  await tester.pumpAndSettle();

  // Query mock database for expected images
  List<EmotionPointer> images = await MockDatabaseManager.instance.getImagesByEmotion(selected_album);
  
  // Verify that the correct number of images are displayed
  expect(images.length, greaterThan(0), reason: "Mock DB should return images for album '$selected_album'");

  // Find GridView and images
  Finder gridViewFinder = find.byType(GridView);
  Finder imagesFinder = find.descendant(
    of: gridViewFinder,
    matching: find.byType(GestureDetector),
  );

  int imageCount = tester.widgetList(imagesFinder).length;

  print('✅ Found $imageCount images in $selected_album');
  expect(imageCount, equals(images.length), reason: "Displayed images should match the mock DB count");
});


    
  });

}

