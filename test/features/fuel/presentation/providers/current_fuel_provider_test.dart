import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/presentation/providers/fuel_provider.dart';

/// currentFuelProvider 가 `AsyncValue<int>` 로 전환된 이후 consumer 화면들이
/// `?? 0` 패턴으로 fallback 하는 동작을 회귀 가드한다.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> guestContainer() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(overrides: [
      fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
      isAuthenticatedProvider.overrideWith((ref) => false),
    ]);
  }

  test('데이터 도착 후 AsyncData<int> 노출', () async {
    final container = await guestContainer();
    addTearDown(container.dispose);
    await container.read(fuelNotifierProvider.future);
    final fuel = container.read(currentFuelProvider);
    expect(fuel, isA<AsyncData<int>>());
    expect(fuel.value, 0,
        reason: '게스트 신규 컨테이너의 초기 잔량은 0');
  });

  test('loading 시점에는 AsyncLoading 또는 즉시 data — 어느 쪽도 acceptable', () async {
    final container = await guestContainer();
    addTearDown(container.dispose);
    final initial = container.read(currentFuelProvider);
    expect(
      initial is AsyncLoading || initial is AsyncData,
      isTrue,
      reason: '소비 화면들은 valueOrNull ?? 0 으로 양쪽 모두 안전하게 처리',
    );
  });

  test('valueOrNull ?? 0 패턴은 loading/error 모두 안전 fallback', () async {
    final container = await guestContainer();
    addTearDown(container.dispose);
    final asyncValue = container.read(currentFuelProvider);
    final safeInt = asyncValue.valueOrNull ?? 0;
    expect(safeInt, isA<int>());
    expect(safeInt, isNonNegative);
  });
}
