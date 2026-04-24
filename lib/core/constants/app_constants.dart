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

  // --- ANALYTICS ---
  static const String eventAiPerformance = 'ai_performance_v1';
  static const String paramAiMethod = 'method';
  static const String paramAiSuggestedCat = 'ai_cat';
  static const String paramUserFinalCat = 'final_cat';
  static const String paramIsCorrect = 'is_correct';

  // --- AI METHODS ---
  static const String methodScanReceipt = 'scan_receipt';
  static const String methodNlpChat = 'nlp_chat';
}
