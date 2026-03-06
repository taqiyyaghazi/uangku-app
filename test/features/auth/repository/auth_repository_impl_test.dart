import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/auth/repository/auth_repository_impl.dart';

// ── Fake Implementations ────────────────────────────────────────────────
// ignore: must_be_immutable
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  late Future<UserCredential> Function(AuthCredential) onSignInWithCredential;
  late Future<void> Function() onSignOut;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) =>
      onSignInWithCredential(credential);

  @override
  Future<void> signOut() => onSignOut();
}

// ignore: must_be_immutable
class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  late Future<GoogleSignInAccount> Function() onAuthenticate;
  late Future<GoogleSignInAccount?> Function() onSignOut;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const [],
  }) => onAuthenticate();

  @override
  Future<GoogleSignInAccount?> signOut() => onSignOut();
}

// ignore: must_be_immutable
class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  late GoogleSignInAuthentication Function() onAuthentication;

  @override
  String get email => 'test@example.com';

  @override
  GoogleSignInAuthentication get authentication => onAuthentication();
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'test-id-token';
}

class FakeUserCredential extends Fake implements UserCredential {
  User? userToReturn;
  @override
  User? get user => userToReturn;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'user-123';
  @override
  String? get displayName => 'Test User';
  @override
  String? get email => 'test@example.com';
  @override
  String? get photoURL => 'https://example.com/photo.jpg';
}

class FakeMonitoringService extends Fake implements MonitoringService {
  final List<String> logs = [];
  @override
  void logInfo(String message, [Map<String, dynamic>? parameters]) {
    logs.add(message);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? parameters,
  ]) {
    logs.add('ERROR: $message - $error');
  }
}

void main() {
  late FakeFirebaseAuth fakeFirebaseAuth;
  late FakeGoogleSignIn fakeGoogleSignIn;
  late FakeMonitoringService fakeMonitoring;
  late FirebaseAuthRepositoryImpl repository;

  setUp(() {
    fakeFirebaseAuth = FakeFirebaseAuth();
    fakeGoogleSignIn = FakeGoogleSignIn();
    fakeMonitoring = FakeMonitoringService();
    repository = FirebaseAuthRepositoryImpl(
      firebaseAuth: fakeFirebaseAuth,
      googleSignIn: fakeGoogleSignIn,
      monitoring: fakeMonitoring,
    );
  });

  group('FirebaseAuthRepositoryImpl', () {
    test('signInWithGoogle signs in successfully', () async {
      final fakeAccount = FakeGoogleSignInAccount();
      final fakeAuth = FakeGoogleSignInAuthentication();
      final fakeCredential = FakeUserCredential();
      final fakeUser = FakeUser();

      fakeGoogleSignIn.onAuthenticate = () async => fakeAccount;
      fakeAccount.onAuthentication = () => fakeAuth;

      fakeFirebaseAuth.onSignInWithCredential = (cred) async {
        fakeCredential.userToReturn = fakeUser;
        return fakeCredential;
      };

      final profile = await repository.signInWithGoogle();

      expect(profile, isNotNull);
      expect(profile!.id, 'user-123');
      expect(profile.name, 'Test User');
    });

    test('signInWithGoogle returns null if user cancels', () async {
      fakeGoogleSignIn.onAuthenticate = () async {
        throw const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
        );
      };

      final profile = await repository.signInWithGoogle();

      expect(profile, isNull);
      expect(fakeMonitoring.logs.any((l) => l.contains('cancelled')), true);
    });

    test('signOut signs out from both firebase and google', () async {
      bool firebaseSignedOut = false;
      bool googleSignedOut = false;

      fakeFirebaseAuth.onSignOut = () async => firebaseSignedOut = true;
      fakeGoogleSignIn.onSignOut = () async {
        googleSignedOut = true;
        return null;
      };

      await repository.signOut();

      expect(firebaseSignedOut, true);
      expect(googleSignedOut, true);
    });
  });
}
