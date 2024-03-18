class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  // Add your configuration variables here
  String apiUrl = 'http://localhost:8787/';
  bool isDebugEnabled = true; // Example configuration variable

  // Example method to toggle debug mode
  void toggleDebugMode() {
    isDebugEnabled = !isDebugEnabled;
  }
}
