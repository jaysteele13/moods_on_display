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
}

class HomeValidationName { 
  String text; 
  double fontSize;

  HomeValidationName({
    required this.text,
    required this.fontSize
  });
}