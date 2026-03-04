/// Pure logic for monthly comparisons.
class ComparisonHelper {
  ComparisonHelper._();

  /// Calculates the percentage change from [previous] to [current].
  ///
  /// Returns 0.0 if [previous] is 0.
  static double calculateDelta(double current, double previous) {
    if (previous <= 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Returns a motivational message based on expense change.
  static String getExpenseMessage(double delta) {
    if (delta < -5) {
      return "Luar biasa! Pengeluaranmu turun signifikan. Pertahankan! 🚀";
    } else if (delta < 0) {
      return "Bagus! Kamu berhasil menekan pengeluaran bulan ini. 👏";
    } else if (delta > 5) {
      return "Waspada! Pengeluaranmu naik cukup banyak bulan ini. 🚨";
    } else if (delta > 0) {
      return "Pengeluaranmu sedikit meningkat. Tetap kontrol ya! 🧐";
    }
    return "Pengeluaranmu stabil dibandingkan bulan lalu. 📊";
  }
}
