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
  });
}
