class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  // Add your configuration variables here
  String apiUrl = 'https://worker-yellow-flower-d1d3.psamxg1968.workers.dev/';
  bool isDebugEnabled = true; // Example configuration variable

  // Example method to toggle debug mode
  void toggleDebugMode() {
    isDebugEnabled = !isDebugEnabled;
  }
}
