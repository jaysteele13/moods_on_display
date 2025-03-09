import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:mockito/mockito.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../../test/mocks.mocks.dart';
import '../../test/photo_manager_mock.mocks.dart';
import 'package:firebase_core/firebase_core.dart';


import '../constants.dart';

// Extension to add countStrings method to WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  // Function to count the occurrences of a string in the widget tree
  Future<int> countStrings(String searchString) async {
    // Find all Text widgets in the widget tree
    final textWidgets = find.byType(Text);
    
    // Get the widgets from the finder
    final widgets = await widgetList(textWidgets);
    
    // Count how many times the searchString appears in the Text widgets
    int count = 0;
    for (var widget in widgets) {
      if (widget is Text && widget.data?.contains(searchString) == true) {
        count++;
      }
    }
    return count;
  }
}

// Helper Function 2: Verify GalleryScreen and Gallery Body
Future<void> verifyGalleryScreenDisplayed(WidgetTester tester) async {
  print("✅ Navigating to Gallery Screen");
  expect(find.byType(GalleryScreen), findsOneWidget, reason: "Gallery Screen should be displayed.");
  print("✅ Gallery Screen is displayed");

  expect(find.byKey(const Key('gallery_body')), findsOneWidget, reason: "Main body of Gallery should be opened.");
  print("✅ Gallery body is displayed");
}

// Helper Function 3: Scroll to the album and select it
Future<void> scrollToAndSelectAlbum(WidgetTester tester) async {
  print("Attempting to scroll to album...");
  await tester.scrollUntilVisible(
    find.text(DETECTION_TEST.emotion_test_album),
    500.0, // Adjust scroll distance
    scrollable: find.byType(Scrollable),
  );
  await tester.pump();
  print("✅ Scrolled ListView to find album");

  expect(find.text(DETECTION_TEST.emotion_test_album), findsOneWidget, reason: "Album should be visible.");
  
  // Tap on the album
  await tester.tap(find.widgetWithText(ListTile, DETECTION_TEST.emotion_test_album));
  await tester.pumpAndSettle();
  print("✅ Tapped on album: ${DETECTION_TEST.emotion_test_album}");
  
  // Ensure the album is selected in the AppBar
  expect(find.widgetWithText(AppBar, DETECTION_TEST.emotion_test_album), findsOneWidget, reason: "AppBar should display the selected album name.");
  print("✅ Selected album is displayed in the AppBar");
}

// Helper Function 4: Tap on all images in the GridView
Future<void> tapAllImagesInGrid(WidgetTester tester) async {
  print("Attempting to tap all images in GridView...");
  
  Finder gridViewFinder = find.byType(GridView);
  Finder imagesFinder = find.descendant(
    of: gridViewFinder,
    matching: find.byType(GestureDetector),
  );

  for (var i = 0; i < imagesFinder.evaluate().length; i++) {
    Finder imageFinder = imagesFinder.at(i);
    
    // Ensure the image is visible and tap it
    await tester.scrollUntilVisible(
      imageFinder,
      100.0, // Scroll amount per step (adjust if needed)
      scrollable: find.byType(Scrollable), 
    );
    await tester.pumpAndSettle();

    await tester.tap(imageFinder);
    await tester.pumpAndSettle();

    print("✅ Tapped on image ${i + 1}");

    // Small delay before selecting the next image
    await Future.delayed(Duration(milliseconds: 500));
  }

  print("✅ Successfully tapped all images in the GridView");
}

// Helper Function 5: Run emotion prediction and compare to benchmark
Future<double> runEmotionPrediction(WidgetTester tester) async {
  Model_Benchmark benchmark = Model_Benchmark(
    albumName: DETECTION_TEST.emotion_test_album,
    anger: 2,
    disgust: 2,
    fear: 1,
    happy: 9,
    neutral: 5,
    sad: 0,
    surprise: 2,
  );

  print("✅ Running Prediction on test_album");

  final int angryCount = await tester.countStrings(EMOTIONS.angry);
  final int disgustCount = await tester.countStrings(EMOTIONS.disgust);
  final int fearCount = await tester.countStrings(EMOTIONS.fear);
  final int happyCount = await tester.countStrings(EMOTIONS.happy);
  final int neutralCount = await tester.countStrings(EMOTIONS.neutral);
  final int sadCount = await tester.countStrings(EMOTIONS.sad);
  final int surpriseCount = await tester.countStrings(EMOTIONS.surprise);

  // Create predicted emotion model
  Model_Benchmark pred_benchmark = Model_Benchmark(
    albumName: DETECTION_TEST.emotion_test_album,
    anger: angryCount,
    disgust: disgustCount,
    fear: fearCount,
    happy: happyCount,
    neutral: neutralCount,
    sad: sadCount,
    surprise: surpriseCount,
  );

  // Compare the predicted benchmark to the real benchmark
  double accuracy = benchmark.compareAndAnalyzePredictions(pred_benchmark);
  
  return accuracy;
}

void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;
  late MockIPhotoManagerService mockPhotoManagerService; 


  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    mockAuth = MockAuth();
    mockUser = MockUser();
    mockPhotoManagerService = MockIPhotoManagerService();
    
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

  group('Emotion Detection Tests', () {

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
      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
      
    });

    test('should return granted permission without prompt', () async {
      when(mockPhotoManagerService.requestPermission())
          .thenAnswer((_) async => PermissionState.authorized);

      final result = await mockPhotoManagerService.requestPermission();

      expect(result, PermissionState.authorized);
    });
    testWidgets("Should select Images from Albums", (WidgetTester tester) async {
      try {
        // Mock successful login
        when(mockAuth.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
        await tester.pumpWidget(mockAddImages(const FlowTree()));
        await tester.pumpAndSettle();

         // Step 2: Handle Dialog for "Allow Full Access"
        when(mockPhotoManagerService.requestPermission())
          .thenAnswer((_) async => PermissionState.authorized);
        final result = await mockPhotoManagerService.requestPermission();
        expect(result, PermissionState.authorized);

        // Step 1: Navigate to Add Images screen
        await tester.tap(find.byKey(const Key('add_images_screen_nav')));
        await tester.pumpAndSettle();

       

        // Step 3: Ensure Gallery Screen and Gallery Body are displayed
        await verifyGalleryScreenDisplayed(tester);

        // Step 4: Scroll to find album and select it
        await scrollToAndSelectAlbum(tester);

        // Step 5: Tap on all images in the GridView
        await tapAllImagesInGrid(tester);

        // Step 6: Tap the "check" icon
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();
        print("✅ Tapped on Tick");

        // Step 7: Run the emotion prediction and compare with benchmark
        double accuracy = await runEmotionPrediction(tester);
        expect(accuracy, greaterThan(70), reason: "Accuracy should be greater than 70%");

      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
    });
  });
  
}
