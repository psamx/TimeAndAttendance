class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  // Add your configuration variables here
  String apiUrl = 'https://f1a5e51b-3b0f-4417-a81c-8f03040ea7af.mock.pstmn.io/';
  bool isDebugEnabled = true; // Example configuration variable

  // Example method to toggle debug mode
  void toggleDebugMode() {
    isDebugEnabled = !isDebugEnabled;
  }
}
