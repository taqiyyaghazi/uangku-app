import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';
import 'package:uangku/features/auth/repository/auth_repository_impl.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/auth/services/auth_service.dart';

/// Provides the [AuthRepository] backed by Firebase Authentication.
///
/// Override this in tests with a mock implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final monitoring = ref.watch(monitoringServiceProvider);
  return FirebaseAuthRepositoryImpl(
    monitoring: monitoring,
    googleSignIn: GoogleSignIn.instance,
  );
});

/// Provides the [AuthService] for orchestrating auth flows and data clearing.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    authRepository: ref.watch(authRepositoryProvider),
    appDatabase: ref.watch(databaseProvider),
    monitoring: ref.watch(monitoringServiceProvider),
  );
});

/// Provides a reactive stream of the user's authentication state.
///
/// Emits [UserProfile] when signed in, and `null` when signed out.
final authStateProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});
