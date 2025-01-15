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
      name: 'Album Pancake',
      iconPath: 'assets/icons/album.svg',
      level: 'Medium',
      duration: '30mins',
      calorie: '230kCal',
      boxIsSelected: true,
    ));

    features.add(HomeTextModel(
      name: 'Slideshow Nigiri',
      iconPath: 'assets/icons/slideshow.svg',
      level: 'Easy',
      duration: '20mins',
      calorie: '120kCal',
      boxIsSelected: false,
    ));

    features.add(HomeTextModel(
      name: 'Add Tuna',
      iconPath: 'assets/icons/add.svg',
      level: 'Easy',
      duration: '20mins',
      calorie: '120kCal',
      boxIsSelected: false,
    ));

    return features;
  }
}
