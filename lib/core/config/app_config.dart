enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.prod;

  static bool get isDev => environment == Environment.dev;
  static bool get isProd => environment == Environment.prod;

  static String get title => isDev ? 'Uangku Dev' : 'Uangku';

  /// Web Client ID for Google Sign-In (from Firebase Console).
  /// This is required on Android to obtain an idToken.
  /// Load from --dart-define=GOOGLE_CLIENT_ID=...
  static String get serverClientId =>
      const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
}
