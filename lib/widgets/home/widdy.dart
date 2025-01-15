import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moods_on_display/widgets/home/text_model.dart'; 
import 'package:moods_on_display/widgets/home/styles.dart'; // Import styles


class HomeFeatures extends StatelessWidget {
  const HomeFeatures({
    super.key,
    required this.features,
  });

  final List<HomeTextModel> features;

  // Screen to build
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureList(), // Generate features
      ],
    );
  }

  Widget _buildFeatureList() {
    return ListView.separated(
      // list scrollable view
      itemCount: features.length, // features object given from text model
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 25), // space between tabs
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureItem(feature: feature);
      },
    );
  }
}

class FeatureItem extends StatelessWidget {
  const FeatureItem({super.key, required this.feature});

  final HomeTextModel feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(feature.boxIsSelected),
      height: 180, // height of each component
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // order of image, details and button
          _buildIcon(),
          _buildFeatureDetails(),
          _buildActionButton(),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: const Color(0xff101617).withOpacity(0.07),
                offset: const Offset(0, 30),
                blurRadius: 40,
              ),
            ]
          : [],
    );
  }

  Widget _buildIcon() {
    return Padding(
      padding: AppStyles.defaultPadding,
      child: SvgPicture.asset(feature.iconPath, width: 40, height: 40),
    );
  }

  Widget _buildFeatureDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature.name, style: AppStyles.featureNameText),
        Text(
          '${feature.level} | ${feature.duration} | ${feature.calorie}',
          style: AppStyles.subtitleText,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () {
        print('Hit button');
      },
      child: SvgPicture.asset('assets/icons/button.svg', width: 30, height: 30),
    );
  }
}
