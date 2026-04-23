import 'package:shared_preferences/shared_preferences.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';

/// Service responsible for orchestrating authentication flows and
/// ensuring proper data isolation between user sessions.
class AuthService {
  final AuthRepository _authRepository;
  final AppDatabase _appDatabase;
  final MonitoringService _monitoring;

  AuthService({
    required AuthRepository authRepository,
    required AppDatabase appDatabase,
    required MonitoringService monitoring,
  })  : _authRepository = authRepository,
        _appDatabase = appDatabase,
        _monitoring = monitoring;

  /// Performs a secure logout by wiping all local persistence before
  /// invalidating the authentication session.
  /// This ensures no local data leaks if a different user logs in.
  Future<void> performSecureLogout() async {
    const operation = "performSecureLogout";
    _monitoring.logInfo('Secure logout started', {'operation': operation});

    try {
      // 1. Wipe SQLite
      await _appDatabase.deleteAllLocalData();
      _monitoring.logInfo('Local database wiped', {'operation': operation});

      // 2. Wipe Prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _monitoring.logInfo('SharedPreferences wiped', {'operation': operation});

      // 3. Repository Sign Out (Firebase & Google)
      await _authRepository.signOut();
      _monitoring.logInfo('Secure logout completed successfully', {'operation': operation});
    } catch (e, stack) {
      _monitoring.logError('Secure logout failed', e, stack, {'operation': operation});
      rethrow;
    }
  }
}
