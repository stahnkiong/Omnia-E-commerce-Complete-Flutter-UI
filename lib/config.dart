class AppConfig {
  static const String appName = "Omnia";

  static const bool isDev = false; // Toggle this for Dev/Prod

  static String get apiBaseUrl {
    return isDev
        ? "http://localhost:9000"
        : "https://api-medusa.omniafoodsupply.com.my";
    // : "https://api-medusa.winwinlssb.com";
  }

  // ADD THIS: This ensures your Flutter app looks for images on the masked domain
  static String get imageBaseUrl {
    return isDev
        ? "http://localhost:9000/static"
        : "https://omnia.omniafoodsupply.com.my/static";
    // : "https://omnia.winwinlssb.com/static";
  }

  static const int timeoutDuration = 8; // in seconds
  // Medusa Publishable API Key (used for sales channel context in headers)
  static const String publishableKey =
      "pk_6fe416ddb475a7907d0b8a04fc3685428d7e8bec90dbe5d7c9da8b644750da65";

  // Stripe Publishable Key (used for payment sheet processing)
  static String get stripePublishableKey {
    return isDev
        ? 'pk_test_51SnE0nHVeaSTBf7hNyFNTAy1pPL12sXYAFbnBRp8VYdHPlzdIQqxMflRyefGQWCzVKp2BSPp6fXt87yGVSHtEcrt00tvxjkD03'
        : 'pk_live_51SnE0WQYIpepWISFwPyaKt1kR4SnZgB1jtan4mHPocsvfI4qRgFBgk7V2LaS8sDbcWPKrnsN0HF8k7TLU9hk321000OzYILjj8';
  }
}
