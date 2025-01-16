import 'package:flutter/material.dart';
import 'package:moods_on_display/widgets/navbar/actual1.dart';
import 'package:moods_on_display/widgets/navbar/widdy.dart';
import 'package:moods_on_display/widgets/home/text_model.dart';
import 'package:moods_on_display/widgets/home/widdy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HomeTextModel> features = [];

  void getInitialInfo() {
    features = HomeTextModel.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    getInitialInfo();
    return Scaffold(
        appBar: appBar(),
        backgroundColor: Colors.white,
        body: ListView(
          // necessary to scroll app
          children: [
            HomeFeatures(features: features),
            SizedBox(
              height: 40,
            )
          ],
        
        ),
        bottomNavigationBar: NavigationMenu());
  }
}
