import 'package:flutter/material.dart';
import 'package:moods_on_display/managers/navigation_manager/base_app_bar.dart';
import 'package:moods_on_display/managers/navigation_manager/base_scaffold.dart';
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
    return BaseScaffold(
        appBar: Base.appBar(title: Text('Home')),
        
        body: ListView(
          key: const Key('home_body'),
          // necessary to scroll app
          children: [
            HomeFeatures(features: features),
            SizedBox(
              height: 40,
            )
          ],
        
        ),
        backgroundColor: Colors.white);
  }
}
