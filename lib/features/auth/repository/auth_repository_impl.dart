import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uangku/core/config/app_config.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final MonitoringService _monitoring;

  /// Ensures [GoogleSignIn.initialize] is called exactly once.
  final Completer<void> _initCompleter = Completer<void>();

  FirebaseAuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required MonitoringService monitoring,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _monitoring = monitoring {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      final clientId = AppConfig.serverClientId;
      if (clientId.isNotEmpty) {
        await _googleSignIn.initialize(serverClientId: clientId);
      }
      _initCompleter.complete();
    } catch (e, stack) {
      _monitoring.logError('GoogleSignIn initialization failed', e, stack);
      _initCompleter.completeError(e, stack);
    }
  }

  UserProfile? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserProfile(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<UserProfile?> signInWithGoogle() async {
    const operation = "signInWithGoogle";
    final start = DateTime.now();

    _monitoring.logInfo('SignIn attempt started', {
      'operation': operation,
      'provider': 'google',
    });

    try {
      // Wait for initialization to complete
      await _initCompleter.future;

      final googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        _monitoring.setUserId(user.uid);
        _monitoring.logEvent(name: 'login', parameters: {'method': 'google'});

        _monitoring.logInfo('SignIn successful', {
          'operation': operation,
          'userId': user.uid,
          'durationMs': DateTime.now().difference(start).inMilliseconds,
        });
      }

      return _mapFirebaseUser(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _monitoring.logInfo('SignIn cancelled by user', {
          'operation': operation,
          'durationMs': DateTime.now().difference(start).inMilliseconds,
        });
        return null;
      }
      _monitoring.logError(
        'GoogleSignInException during SignIn',
        e,
        StackTrace.current,
        {'operation': operation, 'code': e.code},
      );
      rethrow;
    } catch (e, stack) {
      _monitoring.logError('SignIn failed', e, stack, {
        'operation': operation,
        'provider': 'google',
        'durationMs': DateTime.now().difference(start).inMilliseconds,
      });
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    const operation = "signOut";
    final start = DateTime.now();

    _monitoring.logInfo('SignOut attempt started', {'operation': operation});

    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      _monitoring.setUserId(null); // Clear ID
      _monitoring.logInfo('SignOut successful', {
        'operation': operation,
        'durationMs': DateTime.now().difference(start).inMilliseconds,
      });
    } catch (e, stack) {
      _monitoring.logError('SignOut failed', e, stack, {
        'operation': operation,
        'durationMs': DateTime.now().difference(start).inMilliseconds,
      });
      rethrow;
    }
  }
}
