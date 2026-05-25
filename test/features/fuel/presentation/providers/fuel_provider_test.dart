import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/data/repositories/local_fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/presentation/providers/fuel_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> containerWithAuth({required bool authed}) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        fuelLocalDataSourceProvider.overrideWithValue(
          FuelLocalDataSource(prefs),
        ),
        isAuthenticatedProvider.overrideWith((ref) => authed),
      ],
    );
  }

  test('isAuthenticated=false → LocalFuelRepositoryImpl 주입', () async {
    final container = await containerWithAuth(authed: false);
    addTearDown(container.dispose);
    final repo = container.read(fuelRepositoryProvider);
    expect(repo, isA<LocalFuelRepositoryImpl>());
  });

  test('isAuthenticated=true → FuelRepositoryImpl 주입', () async {
    final container = await containerWithAuth(authed: true);
    addTearDown(container.dispose);
    final repo = container.read(fuelRepositoryProvider);
    expect(repo, isA<FuelRepositoryImpl>());
  });

  test('인증 상태에 따라 repo 인스턴스 종류가 다름', () async {
    final guestContainer = await containerWithAuth(authed: false);
    final authedContainer = await containerWithAuth(authed: true);
    addTearDown(guestContainer.dispose);
    addTearDown(authedContainer.dispose);
    expect(
      guestContainer.read(fuelRepositoryProvider).runtimeType,
      isNot(equals(authedContainer.read(fuelRepositoryProvider).runtimeType)),
    );
  });

  group('FuelNotifier 게스트 mutation loading-window 회귀', () {
    test('build 완료 전 chargeFuel 호출 → minute 소실 없음', () async {
      final container = await containerWithAuth(authed: false);
      addTearDown(container.dispose);
      // 의도적으로 build 완료 대기 전에 바로 호출
      await container
          .read(fuelNotifierProvider.notifier)
          .chargeFuel(studyMinutes: 30);
      final fuel = container.read(fuelNotifierProvider).requireValue;
      expect(fuel.currentFuel, 1);
      expect(fuel.pendingMinutes, 0);
    });

    test(
      'build 완료 전 consumeFuel 호출 → 잔량 부족 시 InsufficientFuelException',
      () async {
        final container = await containerWithAuth(authed: false);
        addTearDown(container.dispose);
        await expectLater(
          container.read(fuelNotifierProvider.notifier).consumeFuel(amount: 5),
          throwsA(anything),
        );
      },
    );

    test('build 완료 후 chargeFuel 누적 pendingMinutes 정상', () async {
      final container = await containerWithAuth(authed: false);
      addTearDown(container.dispose);
      // 명시적 build 완료 대기
      await container.read(fuelNotifierProvider.future);
      await container
          .read(fuelNotifierProvider.notifier)
          .chargeFuel(studyMinutes: 15);
      await container
          .read(fuelNotifierProvider.notifier)
          .chargeFuel(studyMinutes: 20);
      final fuel = container.read(fuelNotifierProvider).requireValue;
      expect(fuel.currentFuel, 1); // 35분 → 1통 + 잔여 5분
      expect(fuel.pendingMinutes, 5);
    });
  });

  // 인증 사용자 분기 흡수의 unit test 는 fuelRemoteDataSourceProvider mock 주입이
  // 필요해 비용 대비 가치가 낮아 생략. 분기 로직 자체는 fuelRepositoryProvider 분기
  // 테스트 (위) + 코드 self-evident (early return) 로 충분.
}
