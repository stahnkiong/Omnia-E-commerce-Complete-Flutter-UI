class AppConfig {
  static const String appName = "Omnia Foods";

  static const bool isDev = false; // Toggle this for Dev/Prod

  static String get apiBaseUrl {
    return isDev
        ? "http://192.168.50.50:9000"
        : "https://api-medusa.winwinlssb.com";
  }

  // ADD THIS: This ensures your Flutter app looks for images on the masked domain
  static String get imageBaseUrl {
    return isDev
        ? "http://192.168.50.50:9000/static"
        : "https://omnia.winwinlssb.com/static";
  }

  static const int timeoutDuration = 8; // in seconds
  static const String publishableKey =
      "pk_6fe416ddb475a7907d0b8a04fc3685428d7e8bec90dbe5d7c9da8b644750da65";
}
