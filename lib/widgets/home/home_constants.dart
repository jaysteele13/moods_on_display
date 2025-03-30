class HOME_CONSTANTS {
  static const gettingStarted = "Getting Started";
  static const howWillDataBeUsed = 'How will your data be used?';
  static const features = 'Features';
  static const viewAlbums = 'View Albums';
  static const predictEmotions = 'Predict Emotions';

  static const featureButtonHeight = 100.0;

  // Add Username
  static const enterName = 'Enter your name';
  static const enterNamePlaceHolder = 'Enter name';
  static const validationText = 'Enter a valid name!';
  static const validationTooLong = 'That name is too long... sorry.';

  // Getting Started
  static const gettingStartedTitle = 'Getting Started';
  static const gettingStartedText = ['Welcome to Moods on Display! This app *predicts and organizes your images into emotional categories.*',
  'Use it to *curate stories* with emotionally categorised albums or revisit past moments from a {color->g,b}fresh perspective.{/color}',
  'These Icons will let you *add images for emotion prediction* and *view categorized results.*'
  ];
  static const gettingStartedIcons = ['assets/icons/Plus_circle.svg', 'assets/icons/Folder.svg'];
  static const gettingStartedImage = 'assets/images/dummies.png';
}

class HomeValidationName { 
  String text; 
  double fontSize;

  HomeValidationName({
    required this.text,
    required this.fontSize
  });
}