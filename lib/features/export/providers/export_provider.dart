import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/export/logic/csv_export_service.dart';

/// State for the CSV export operation.
enum ExportState { idle, loading, success, error }

/// Provider that manages the CSV export flow:
/// 1. Fetch all transactions with details from the repository.
/// 2. Generate CSV string using the pure CsvExportService.
/// 3. Write to a temporary file.
/// 4. Trigger the native share sheet.
class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => ExportState.idle;

  /// Executes the full export flow.
  ///
  /// Returns `true` if the share sheet was shown successfully,
  /// `false` if an error occurred.
  Future<bool> exportAndShare() async {
    const operation = 'exportAndShare';
    final startTime = DateTime.now();
    developer.log('START: $operation', name: 'ExportNotifier');

    state = ExportState.loading;

    try {
      // 1. Fetch data.
      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.getAllTransactionsWithDetails();

      if (transactions.isEmpty) {
        developer.log(
          'WARN: $operation - No transactions to export',
          name: 'ExportNotifier',
        );
        state = ExportState.error;
        return false;
      }

      // 2. Generate CSV (pure function).
      final csvString = CsvExportService.generateCsv(transactions);

      // 3. Write to temp file.
      final directory = await getTemporaryDirectory();
      final fileName = CsvExportService.generateFileName();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvString);

      // 4. Trigger share sheet.
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Uangku Transaction Export',
        ),
      );

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'SUCCESS: $operation',
        name: 'ExportNotifier',
        error: {
          'transactionCount': transactions.length,
          'filePath': filePath,
          'durationMs': durationMs,
        },
      );

      state = ExportState.success;
      return true;
    } catch (e, st) {
      developer.log(
        'FAILURE: $operation',
        name: 'ExportNotifier',
        error: e,
        stackTrace: st,
      );
      state = ExportState.error;
      return false;
    }
  }

  /// Resets the export state back to idle.
  void reset() {
    state = ExportState.idle;
  }
}

/// Provider for the export notifier.
final exportNotifierProvider = NotifierProvider<ExportNotifier, ExportState>(
  ExportNotifier.new,
);
