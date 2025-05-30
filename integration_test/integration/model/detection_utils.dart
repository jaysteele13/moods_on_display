import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/pages/gallery.dart';
import 'package:moods_on_display/utils/constants.dart';

import '../../constants.dart';

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

class DetectionUtils {
  
  // Helper Function 2: Verify GalleryScreen and Gallery Body
Future<void> verifyGalleryScreenDisplayed(WidgetTester tester) async {
  print("✅ Navigating to Gallery Screen");
  expect(find.byType(GalleryScreen), findsOneWidget, reason: "Gallery Screen should be displayed.");
  print("✅ Gallery Screen is displayed");

  expect(find.byKey(const Key('gallery_body')), findsOneWidget, reason: "Main body of Gallery should be opened.");
  print("✅ Gallery body is displayed");
}

// Helper Function 3: Scroll to the album and select it
Future<void> scrollToAndSelectAlbum(WidgetTester tester, String albumName) async {
  final albumFinder = find.text(albumName);

  if (albumFinder.evaluate().isEmpty) {
    print("Album not visible yet — attempting to drag to it...");

    await tester.dragUntilVisible(
      albumFinder,
      find.byKey(Key('album_list_view')), // The ListView
      Offset(0, -200) // drag up by 200 pixels
    );

    await tester.pumpAndSettle();
  }

  expect(albumFinder, findsOneWidget, reason: "Album should now be visible.");
  print("✅ Album is visible: $albumName");
  
  // Tap on the album
  await tester.tap(find.text(albumName));
  await tester.pumpAndSettle();
  print("✅ Tapped on album: $albumName");
  await tester.pumpAndSettle();
  
  // Ensure the album is selected in the AppBar
  expect(find.widgetWithText(AppBar, albumName), findsOneWidget, reason: "AppBar should display the selected album name.");
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
Future<double> runEmotionPrediction(WidgetTester tester, Model_Benchmark benchmark) async {


  print("✅ Running Prediction on ${benchmark.albumName}");

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
}