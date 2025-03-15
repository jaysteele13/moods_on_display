import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moods_on_display/pages/gallery.dart';


class AddImageUtils {
  
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
  print("Attempting to scroll to album...");
  await tester.scrollUntilVisible(
    find.text(albumName),
    500.0, // Adjust scroll distance
    scrollable: find.byType(Scrollable),
  );
  await tester.pump();
  print("✅ Scrolled ListView to find album");

  expect(find.text(albumName), findsOneWidget, reason: "Album should be visible.");
  
  // Tap on the album
  await tester.tap(find.widgetWithText(ListTile, albumName));
  await tester.pumpAndSettle();
  print("✅ Tapped on album: $albumName");
  
  // Ensure the album is selected in the AppBar
  expect(find.widgetWithText(AppBar, albumName), findsOneWidget, reason: "AppBar should display the selected album name.");
  print("✅ Selected album is displayed in the AppBar");
}

// Helper Function 4: Tap on all images in the GridView
Future<void> tapImagesInGrid(WidgetTester tester, int amount) async {
  print("Attempting to tap all images in GridView...");
  
  Finder gridViewFinder = find.byType(GridView);
  Finder imagesFinder = find.descendant(
    of: gridViewFinder,
    matching: find.byType(GestureDetector),
  );

  for (var i = 0; i < amount; i++) {
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

}