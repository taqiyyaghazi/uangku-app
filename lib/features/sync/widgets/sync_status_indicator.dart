import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/sync/providers/connectivity_provider.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';

/// A reusable widget that displays the current connection and cloud sync status.
///
/// It glows/spins during synchronization and shows a warning icon when offline.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key, this.isLight = false});

  /// Whether the icon should be styled for a light background (e.g. standard AppBar)
  /// or a dark/gradient background (e.g. DashboardHeader).
  final bool isLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final syncState = ref.watch(syncStatusProvider);

    final theme = Theme.of(context);
    final iconColor = _getIconColor(isOnline, syncState.status, theme);

    return Tooltip(
      message: _getTooltipMessage(isOnline, syncState),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildIcon(isOnline, syncState.status, iconColor),
      ),
    );
  }

  Widget _buildIcon(bool isOnline, SyncStatus status, Color color) {
    if (!isOnline) {
      return Icon(
        Icons.cloud_off_rounded,
        key: const ValueKey('offline'),
        color: Colors.orange,
        size: 20,
      );
    }

    if (status == SyncStatus.syncing) {
      return SizedBox(
        key: const ValueKey('syncing'),
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (status == SyncStatus.error) {
      return Icon(
        Icons.cloud_off_rounded,
        key: const ValueKey('error'),
        color: Colors.redAccent,
        size: 20,
      );
    }

    return Icon(
      Icons.cloud_done,
      key: const ValueKey('online'),
      color: color,
      size: 20,
    );
  }

  Color _getIconColor(bool isOnline, SyncStatus status, ThemeData theme) {
    if (!isOnline) return Colors.orange;
    if (status == SyncStatus.error) return Colors.redAccent;

    if (isLight) {
      return OceanFlowColors.primary;
    }

    return Colors.white.withValues(alpha: 0.9);
  }

  String _getTooltipMessage(bool isOnline, SyncStatusState state) {
    if (!isOnline) {
      return 'You are offline. Changes will sync when back online.';
    }

    switch (state.status) {
      case SyncStatus.syncing:
        return state.message ?? 'Synchronizing your data...';
      case SyncStatus.error:
        return state.message ?? 'Sync failed. Tap to retry.';
      case SyncStatus.completed:
      case SyncStatus.idle:
        return 'Data is synced to cloud';
    }
  }
}
