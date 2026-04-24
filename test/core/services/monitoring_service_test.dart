import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uangku/core/services/monitoring_service.dart';

@GenerateMocks([FirebaseAnalytics, FirebaseCrashlytics])
import 'monitoring_service_test.mocks.dart';

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;
  late MonitoringService service;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();
    service = MonitoringService(mockAnalytics, mockCrashlytics);
  });

  group('MonitoringService', () {
    test('logEvent calls analytics.logEvent', () async {
      final parameters = {'key': 'value'};
      await service.logEvent(name: 'test_event', parameters: parameters);

      verify(
        mockAnalytics.logEvent(name: 'test_event', parameters: parameters),
      ).called(1);
    });

    test('setUserId calls both analytics and crashlytics', () async {
      await service.setUserId('user_123');
      verify(mockAnalytics.setUserId(id: 'user_123')).called(1);
      verify(mockCrashlytics.setUserIdentifier('user_123')).called(1);
    });

    test('recordError calls crashlytics.recordError', () async {
      final error = Exception('test');
      final stack = StackTrace.current;
      await service.recordError(error, stack, reason: 'testing');

      verify(
        mockCrashlytics.recordError(
          error,
          stack,
          reason: 'testing',
          fatal: false,
        ),
      ).called(1);
    });

    test('log calls crashlytics.log', () async {
      await service.log('test message');
      verify(mockCrashlytics.log('test message')).called(1);
    });

    group('logAiAccuracy', () {
      test('logs correct=1 when categories match', () async {
        await service.logAiAccuracy(
          method: 'nlp_chat',
          aiCategory: 'Food',
          finalCategory: 'Food',
        );

        verify(
          mockAnalytics.logEvent(
            name: 'ai_performance_v1',
            parameters: {
              'method': 'nlp_chat',
              'ai_cat': 'Food',
              'final_cat': 'Food',
              'is_correct': 1,
            },
          ),
        ).called(1);
      });

      test('logs correct=0 when categories mismatch', () async {
        await service.logAiAccuracy(
          method: 'scan_receipt',
          aiCategory: 'Food',
          finalCategory: 'Shopping',
        );

        verify(
          mockAnalytics.logEvent(
            name: 'ai_performance_v1',
            parameters: {
              'method': 'scan_receipt',
              'ai_cat': 'Food',
              'final_cat': 'Shopping',
              'is_correct': 0,
            },
          ),
        ).called(1);
      });

      test('is case-insensitive for comparison', () async {
        await service.logAiAccuracy(
          method: 'nlp_chat',
          aiCategory: 'food',
          finalCategory: 'Food',
        );

        verify(
          mockAnalytics.logEvent(
            name: 'ai_performance_v1',
            parameters: {
              'method': 'nlp_chat',
              'ai_cat': 'food',
              'final_cat': 'Food',
              'is_correct': 1,
            },
          ),
        ).called(1);
      });

      test('fails silently on analytics error', () async {
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenThrow(Exception('Analytics failed'));

        // Should not throw
        await service.logAiAccuracy(
          method: 'nlp_chat',
          aiCategory: 'Food',
          finalCategory: 'Food',
        );

        verify(mockCrashlytics.recordError(any, any, reason: anyNamed('reason')))
            .called(1);
      });
    });
  });
}
