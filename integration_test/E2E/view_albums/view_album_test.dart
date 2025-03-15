import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../integration/model/detection_utils.dart';
import '../../../mocks/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import '../add_images/add_image_utils.dart';



void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;
  late AddImageUtils addImageUtils;
  late DetectionUtils detectionUtils;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    mockAuth = MockAuth();
    mockUser = MockUser();
    addImageUtils = AddImageUtils();
    detectionUtils = DetectionUtils();
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
        '/album': (context) => AlbumScreen(),
        '/add_images': (context) => AddImageScreen(), 
      },
      ),
    );
  }

  group('E2E Navigate to Gallery', () {

  testWidgets("View DB Images Multi-Screen", (WidgetTester tester) async {
  String albumToTest = 'Happy';
  when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

  await tester.pumpWidget(mockViewGallery(const FlowTree()));
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget, reason: "HomePage should be displayed when user is authenticated");


  // Code to add prediction
  await tester.tap(find.byKey(const Key('add_images_screen_nav')));
  await tester.pumpAndSettle();

  await detectionUtils.verifyGalleryScreenDisplayed(tester);

  await detectionUtils.scrollToAndSelectAlbum(tester, DETECTION_TEST.emotion_test_album);

  await addImageUtils.tapImagesInGrid(tester, 3);

  await tester.tap(find.byIcon(Icons.check));
  await tester.pumpAndSettle();
  print("✅ Tapped on Tick");



  // Navigate to album screen
  await tester.tap(find.byKey(const Key('view_gallery_screen_nav')));
  await tester.pumpAndSettle();
  
  expect(find.byType(AlbumScreen), findsOneWidget, reason: "Album Screen should be displayed");

  // Select album "Happy"
  await addImageUtils.scrollToAndSelectAlbum(tester, albumToTest);
  await tester.pumpAndSettle();

  await Future.delayed(Duration(milliseconds: 1000)); // load images from db

  // Find GridView and images
  Finder listViewFinder = find.byType(ListView);
  Finder imagesFinder = find.descendant(
    of: listViewFinder,
    matching: find.byType(GestureDetector),
  );

  int imageCount = tester.widgetList(imagesFinder).length;

  print('✅ Found $imageCount images in $albumToTest');

  // hardcoded change for demo
  expect(imageCount, equals(1), reason: "Displayed images should match the mock Predict count");
});

 testWidgets("View DB Images Single-Screen", (WidgetTester tester) async {
  String albumToTest = 'Happy';
  when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

  await tester.pumpWidget(mockViewGallery(const FlowTree()));
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget, reason: "HomePage should be displayed when user is authenticated");


  // Code to add prediction
  await tester.tap(find.byKey(const Key('add_images_screen_nav')));
  await tester.pumpAndSettle();

  await detectionUtils.verifyGalleryScreenDisplayed(tester);

  await detectionUtils.scrollToAndSelectAlbum(tester, DETECTION_TEST.emotion_test_album);

  await addImageUtils.tapImagesInGrid(tester, 6);

  await tester.tap(find.byIcon(Icons.check));
  await tester.pumpAndSettle();
  print("✅ Tapped on Tick");



  // Navigate to album screen
  await tester.tap(find.byKey(const Key('view_gallery_screen_nav')));
  await tester.pumpAndSettle();
  
  expect(find.byType(AlbumScreen), findsOneWidget, reason: "Album Screen should be displayed");

  // Select album "Happy"
  await addImageUtils.scrollToAndSelectAlbum(tester, albumToTest);
  await tester.pumpAndSettle();

  // tap image
  await tester.tap(find.byKey(const Key('single_image')).first);
  await tester.pumpAndSettle();

  Finder imageFinder = find.byType(ExtendedImage);
  expect(imageFinder, findsOneWidget, reason: "There should be an image displayed initially");

  // Step 2: Get the initial image widget
  ExtendedImage firstImage = tester.widget(imageFinder);
  final initialImageProvider = firstImage.image;

  await tester.drag(imageFinder, const Offset(-300, 0));
  await tester.pumpAndSettle();

  // Step 4: Find the new image after swiping
  ExtendedImage newImage = tester.widget(imageFinder);
  final newImageProvider = newImage.image;

  // Step 5: Ensure the image has changed
  expect(newImageProvider, isNot(equals(initialImageProvider)), 
      reason: "A new image should be displayed after swiping");
});
    
  });

}

