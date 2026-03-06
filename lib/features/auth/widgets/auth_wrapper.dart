import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/features/auth/screens/login_screen.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/main_shell.dart';

/// Root widget that gates access based on Firebase Auth state.
///
/// Listens to [authStateProvider] and displays:
/// - [LoginScreen] when the user is not authenticated.
/// - [MainShell] when the user is authenticated.
/// - A loading indicator while auth state is being determined.
///
/// Uses [AnimatedSwitcher] for a smooth fade transition between states.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: authState.when(
        data: (user) {
          if (user != null) {
            return const MainShell(key: ValueKey('main'));
          }
          return const LoginScreen(key: ValueKey('login'));
        },
        loading: () => const Scaffold(
          key: ValueKey('loading'),
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          key: const ValueKey('error'),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Authentication error',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(authStateProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
