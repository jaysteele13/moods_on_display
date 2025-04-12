import 'package:flutter/material.dart';
// import firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:moods_on_display/managers/database_manager/database_manager.dart';
import 'package:moods_on_display/pages/albums.dart';
import 'package:moods_on_display/pages/home.dart';
import 'package:moods_on_display/pages/detect.dart';
import 'package:moods_on_display/pages/splash.dart';
import 'package:moods_on_display/utils/utils.dart';
import 'package:provider/provider.dart';



// import 'package:moods_on_display/widgets/navbar/actual1.dart';
import 'package:moods_on_display/managers/navigation_manager/navigation_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseManager.instance.database;


  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key : key);

  // Add this in to possibly avoid database leak if app runs out of 'memory'
  //  void dispose() {
  //   // Close the database when the app is disposed
  //   DatabaseManager.instance.closeDatabase();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: '/home',
      // routes in app
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: DefaultColors.neutral,
          selectionColor: DefaultColors.green.withAlpha(20),
          selectionHandleColor: DefaultColors.darkGreen
          
        )
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/add_images': (context) => AddImageScreen(),
        '/album': (context) => AlbumScreen(),
      },
      debugShowCheckedModeBanner: false,
      
      
      home: const SplashScreen()
    );
  }
}