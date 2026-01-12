class AppConfig {
  static const String appName = "Omnia Foods";

  static const bool isDev = true; // Toggle this for Dev/Prod

  static String get apiBaseUrl {
    if (isDev) {
      // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
      return "http://192.168.50.50:9000";
    }
    return "https://api-medusa.winwinlssb.com";
  }

  static const int timeoutDuration = 8; // in seconds
  static const String publishableKey =
      "pk_6fe416ddb475a7907d0b8a04fc3685428d7e8bec90dbe5d7c9da8b644750da65";
}
