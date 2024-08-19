class CommonService {
  // RETURNS THE LANGUAGE CODE FOR THE GIVEN LANGUAGE NAME.
  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en-US';
      case 'Sinhala':
        return 'si-LK';
      case 'Tamil':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }
}
