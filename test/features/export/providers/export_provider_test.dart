import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/export/providers/export_provider.dart';

@GenerateMocks([MonitoringService, TransactionRepository])
import 'export_provider_test.mocks.dart';

void main() {
  late MockMonitoringService mockMonitoring;
  late MockTransactionRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockMonitoring = MockMonitoringService();
    mockRepo = MockTransactionRepository();
    container = ProviderContainer(
      overrides: [
        monitoringServiceProvider.overrideWithValue(mockMonitoring),
        transactionRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ExportNotifier', () {
    test('exportAndShare logs start event', () async {
      // Mock data.
      when(mockRepo.getAllTransactionsWithDetails()).thenAnswer(
        (_) async => [
          TransactionWithDetails(
            transaction: Transaction(
              id: 1,
              walletId: 1,
              amount: 100,
              type: TransactionType.expense,
              categoryId: 1,
              note: 'test',
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
            categoryName: 'Food',
            walletName: 'Main',
          ),
        ],
      );

      // Mock monitoring.
      when(
        mockMonitoring.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ),
      ).thenAnswer((_) async => {});

      // Call.
      try {
        await container.read(exportNotifierProvider.notifier).exportAndShare();
      } catch (_) {}

      verify(mockMonitoring.logEvent(name: 'export_csv_start')).called(1);
    });

    test('exportAndShare records non-fatal error on failure', () async {
      when(
        mockRepo.getAllTransactionsWithDetails(),
      ).thenThrow(Exception('DB Error'));

      when(
        mockMonitoring.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ),
      ).thenAnswer((_) async => {});

      when(
        mockMonitoring.recordError(any, any, reason: anyNamed('reason')),
      ).thenAnswer((_) async => {});

      await container.read(exportNotifierProvider.notifier).exportAndShare();

      verify(
        mockMonitoring.recordError(
          any,
          any,
          reason: 'Failed to export transactions to CSV',
        ),
      ).called(1);
      expect(container.read(exportNotifierProvider), ExportState.error);
    });
  });
}
