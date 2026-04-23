import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';

/// Displays the authenticated user's avatar in the dashboard header.
///
/// Tapping the avatar shows a bottom sheet with profile info and sign-out.
/// When no user is authenticated, renders an empty [SizedBox].
class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _AvatarIcon(user: user);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AvatarIcon extends ConsumerWidget {
  const _AvatarIcon({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showProfileSheet(context, ref),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        backgroundImage: user.photoUrl != null
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null
            ? Text(
                _initials(user),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  String _initials(UserProfile user) {
    final name = user.name ?? user.email ?? '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProfileSheet(user: user, ref: ref),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.user, required this.ref});

  final UserProfile user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──────────────────────────────────────────
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ── Avatar ──────────────────────────────────────────────
            CircleAvatar(
              radius: 36,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 36)
                  : null,
            ),
            const SizedBox(height: 12),

            // ── Name ────────────────────────────────────────────────
            if (user.name != null)
              Text(
                user.name!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 4),

            // ── Email ───────────────────────────────────────────────
            if (user.email != null)
              Text(
                user.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(height: 24),

            // ── Sign Out Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  
                  // Hide the profile sheet first
                  navigator.pop();
                  
                  final confirmed = await showDialog<bool>(
                    context: navigator.context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                        'Are you sure? This will clear all local data from this device. Your data remains safe in the cloud.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  if (!navigator.mounted) return;

                  // Show non-dismissible loading overlay
                  showDialog(
                    context: navigator.context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final authService = ref.read(authServiceProvider);
                    await authService.performSecureLogout();
                    
                    // Invalidate sync status to allow restoration for the next user.
                    ref.invalidate(syncStatusProvider);
                  } finally {
                    // Close the loading overlay
                    navigator.pop();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
