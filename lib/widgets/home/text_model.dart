class HomeTextModel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  bool boxIsSelected;

  HomeTextModel(
      {required this.name,
      required this.iconPath,
      required this.level,
      required this.duration,
      required this.calorie,
      required this.boxIsSelected});

  static List<HomeTextModel> getCategories() {
    List<HomeTextModel> features = [];

    features.add(HomeTextModel(
      name: 'Albums',
      iconPath: 'assets/icons/album.svg',
      level: '',
      duration: '',
      calorie: '',
      boxIsSelected: true,
    ));

    features.add(HomeTextModel(
      name: 'Slideshow',
      iconPath: 'assets/icons/slideshow.svg',
      level: 'It',
      duration: 'is',
      calorie: 'Fun',
      boxIsSelected: false,
    ));

    features.add(HomeTextModel(
      name: 'Add Images',
      iconPath: 'assets/icons/Plus_circle.svg',
      level: 'Find',
      duration: 'your',
      calorie: 'Emotion',
      boxIsSelected: false,
    ));

    return features;
  }
}
