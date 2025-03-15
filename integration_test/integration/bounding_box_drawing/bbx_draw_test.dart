import 'package:crypto/crypto.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mocks.mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../constants.dart';
import '../../integration/model/detection_utils.dart';
import 'package:image/image.dart' as img;

import '../../E2E/add_images/add_image_utils.dart';


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


group('Bounding Box Test', () {

String getImageHash(img.Image image) {
  // Convert the image to a byte array and return a hash
  List<int> byteArray = image.getBytes();
  return md5.convert(byteArray).toString();  // Using md5 for example
}
testWidgets("Draw rectangle on image and verify image update", (WidgetTester tester) async {
  // Load original image
  BBOX_TEST bboxTest = BBOX_TEST();
  img.Image originalImage = await bboxTest.loadTestImage();

  // Get the initial image hash or any general marker to compare later
  String initialImageHash = getImageHash(originalImage);

  // Draw the rectangle
  img.drawRect(originalImage, x1: 1079, y1: 1184, x2: 1002, y2: 985, 
               color: img.ColorRgb8(0, 255, 0), thickness: 6);

  // Get the updated image hash or marker
  String updatedImageHash = getImageHash(originalImage);

  // Wait for some time to ensure the drawing process has completed
  await tester.pumpAndSettle();

  // Check that the image has changed (the hash will be different if the image changes)
  expect(updatedImageHash, isNot(equals(initialImageHash)),
      reason: "The image should change after drawing the rectangle.");
});


  testWidgets("Draw Emotions in Real-Time", (WidgetTester tester) async {
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

    await tester.longPress(imageFinder);
    await tester.pumpAndSettle();

    await tester.longPress(imageFinder);
    await tester.pumpAndSettle();

    // ⏳ Wait up to 10 seconds for image to change
  const int maxWaitTime = 30; // Max wait time in seconds
  int elapsedTime = 0;
  bool imageUpdated = false;

  while (elapsedTime < maxWaitTime) {
    await tester.pump(const Duration(seconds: 1)); // Wait 1 second
    elapsedTime++;

    // Check if image has changed
    ExtendedImage updatedImage = tester.widget(imageFinder);
    final newImageProvider = updatedImage.image;

    if (newImageProvider != initialImageProvider) {
      imageUpdated = true;
      break; // Exit loop early if image changed
    }
  }

    // ⏳ If after 10s image hasn't changed, fail the test
    expect(imageUpdated, isTrue, reason: "Image should update within 10 seconds after long press.");

    // Step 4: Find the new image after swiping
    ExtendedImage newImage = tester.widget(imageFinder);
    final newImageProvider = newImage.image;

     // ⏳ If after 10s image hasn't changed, fail the test
    expect(imageUpdated, isTrue, reason: "Image should update within 10 seconds after long press.");
    expect(newImageProvider, isNot(equals(initialImageProvider)), 
        reason: "A new image should be displayed after swiping");

    await Future.delayed(Duration(milliseconds: 6000)); // persist changes
  });
      
    
  });
  }