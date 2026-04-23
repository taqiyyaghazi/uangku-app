import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';
import 'package:uangku/features/auth/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([AuthRepository, AppDatabase, MonitoringService])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAppDatabase mockAppDatabase;
  late MockMonitoringService mockMonitoringService;
  late AuthService authService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAppDatabase = MockAppDatabase();
    mockMonitoringService = MockMonitoringService();
    
    SharedPreferences.setMockInitialValues({});

    authService = AuthService(
      authRepository: mockAuthRepository,
      appDatabase: mockAppDatabase,
      monitoring: mockMonitoringService,
    );
  });

  test('performSecureLogout should wipe database, clear prefs, and sign out', () async {
    // Arrange
    when(mockAppDatabase.deleteAllLocalData()).thenAnswer((_) async => {});
    when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_key', 'test_value');
    expect(prefs.getString('test_key'), 'test_value');

    // Act
    await authService.performSecureLogout();

    // Assert
    verify(mockAppDatabase.deleteAllLocalData()).called(1);
    verify(mockAuthRepository.signOut()).called(1);
    
    // verify prefs are cleared
    expect(prefs.getString('test_key'), null);
  });

  test('performSecureLogout should throw if database wipe fails', () async {
    // Arrange
    when(mockAppDatabase.deleteAllLocalData()).thenThrow(Exception('Database error'));
    
    // Act & Assert
    expect(() => authService.performSecureLogout(), throwsException);
    
    verify(mockAppDatabase.deleteAllLocalData()).called(1);
    verifyNever(mockAuthRepository.signOut()); // Should not proceed to sign out
  });
}
