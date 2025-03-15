import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/app_flow/flow.dart';
import 'package:moods_on_display/managers/authentication_manager/auth.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mocks.mocks.dart';
import '../../../mocks/photo_manager_mock.mocks.dart';
import 'package:firebase_core/firebase_core.dart';


import '../../constants.dart';
import 'detection_utils.dart';



void main() {
  late MockAuth mockAuth;
  late MockUser mockUser;
  late MockIPhotoManagerService mockPhotoManagerService; 
  late DetectionUtils detectionUtils;


  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    mockAuth = MockAuth();
    mockUser = MockUser();
    detectionUtils = DetectionUtils();
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


  group('Detection Test', () {
    // function to run model bench prediction
    Future<void> runModelPredictionTest(
    WidgetTester tester, 
    MockAuth mockAuth, 
    MockIPhotoManagerService mockPhotoManagerService, 
    DetectionUtils detectionUtils, 
    MockUser mockUser,
    {required double expectedAccuracy, required Model_Benchmark benchmark}) async {
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
        await detectionUtils.verifyGalleryScreenDisplayed(tester);

        // Step 4: Scroll to find album and select it
        await detectionUtils.scrollToAndSelectAlbum(tester, benchmark.albumName);

        // Step 5: Tap on all images in the GridView
        await detectionUtils.tapAllImagesInGrid(tester);

        // Step 6: Tap the "check" icon
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();
        print("✅ Tapped on Tick");

        // Step 7: Run the emotion prediction and compare with benchmark
        double accuracy = await detectionUtils.runEmotionPrediction(tester, benchmark);
        expect(accuracy, greaterThan(expectedAccuracy), 
            reason: "Accuracy should be greater than $expectedAccuracy%");
        
      } catch (e, stack) {
        print("❌ Test Failed: \nError: $e");
        print(stack);
        rethrow; // Ensure test still fails
      }
}
    test('Mock Prompt for PhotoManager permission request', () async {
      when(mockPhotoManagerService.requestPermission())
          .thenAnswer((_) async => PermissionState.authorized);

      final result = await mockPhotoManagerService.requestPermission();

      expect(result, PermissionState.authorized);
    });
    testWidgets("Test Model Prediction Benchmark 1", (WidgetTester tester) async {
      await runModelPredictionTest(
        tester, 
        mockAuth, 
        mockPhotoManagerService, 
        detectionUtils, 
        mockUser,
        expectedAccuracy: 70.0,
        benchmark: DETECTION_TEST.benchmark1,
      );
    });

    testWidgets("Test Model Prediction Benchmark 2", (WidgetTester tester) async {
      await runModelPredictionTest(
        tester, 
        mockAuth, 
        mockPhotoManagerService, 
        detectionUtils, 
        mockUser,
        expectedAccuracy: 70.0,
        benchmark: DETECTION_TEST.benchmark2,
      );
    });

    testWidgets("Test Model Prediction Benchmark 3", (WidgetTester tester) async {
      await runModelPredictionTest(
        tester, 
        mockAuth, 
        mockPhotoManagerService, 
        detectionUtils, 
        mockUser,
        expectedAccuracy: 70.0,
        benchmark: DETECTION_TEST.benchmark3,
      );
    });

  });


  // Add E2E to Test Happy album and using Emotion detection bounding box feature
  
}
