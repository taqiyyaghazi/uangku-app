import 'package:uangku/features/auth/models/user_profile.dart';

abstract class AuthRepository {
  /// Stream of user profile changes (null if unauthenticated).
  Stream<UserProfile?> get authStateChanges;

  /// Initiate sign-in with Google.
  Future<UserProfile?> signInWithGoogle();

  /// Sign out the current user.
  Future<void> signOut();
}
