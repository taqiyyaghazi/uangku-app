# Research Log: Secure Login with Google (Story 8.1)

## Context

The goal is to implement a secure Google Sign-In using Firebase Authentication. This allows the user's financial data to be safely linked to their identity and facilitates future cloud synchronization.

## Findings

### Flutter Packages Required

- `firebase_auth`: The official Firebase authentication plugin for Flutter.
- `google_sign_in`: Google Sign-In plugin for Flutter.

### Architecture Integration

- We will follow the defined project structure, creating an `auth` feature directory under `lib/features/`.
- We need an `AuthService` to wrap `FirebaseAuth` and `GoogleSignIn` to allow for clean mocking during testing.
- An `AuthWrapper` widget should be used at the root of the app (before the Dashboard) to listen to `FirebaseAuth.instance.authStateChanges()`. If a user is logged in, they are directed to the Dashboard. If not, they see the `LoginScreen`.

### Implementation Details

```dart
// Example AuthService
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // The user canceled the sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

### Gotchas / Edge Cases

- **SHA-1 Fingerprint**: Google Sign-In requires the SHA-1 fingerprint of the debug/release keystore to be registered in the Firebase console. If it's missing, it will throw a `Developer Error 10`.
- **State Management**: Using Riverpod, we can expose the `AuthService` and stream of `User?` using providers.

### Decisions

1. Create `AuthService` to encapsulate all Firebase Auth logic.
2. Provide `authStateChangesProvider` via Riverpod to easily consume the user's auth state across the app.
3. Update settings screen to include user info and sign-out button.
