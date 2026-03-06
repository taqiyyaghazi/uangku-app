import 'dart:async';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _authStateController = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;
  bool shouldThrowError = false;

  MockAuthRepository({UserProfile? initialUser}) {
    _currentUser = initialUser;
    Future.microtask(() {
      _authStateController.add(_currentUser);
    });
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserProfile?> signInWithGoogle() async {
    if (shouldThrowError) {
      throw Exception('Mock sign in error');
    }
    _currentUser = const UserProfile(
      id: 'mock-user-123',
      name: 'Mock User',
      email: 'mock@example.com',
      photoUrl: 'https://example.com/photo.png',
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    if (shouldThrowError) {
      throw Exception('Mock sign out error');
    }
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}
