/// Application-wide constants for Uangku.
class AppConstants {
  AppConstants._();

  static const String appName = 'Uangku';
  static const String databaseName = 'uangku.db';
  static const int databaseVersion = 2;

  /// Default monthly spending budget (in IDR).
  ///
  /// Used by the Daily Breath engine until the user configures their own.
  static const double defaultMonthlyBudget = 3000000;
}
