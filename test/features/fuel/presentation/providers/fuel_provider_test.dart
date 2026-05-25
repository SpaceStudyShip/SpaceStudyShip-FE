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
    return ProviderContainer(overrides: [
      fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
      isAuthenticatedProvider.overrideWith((ref) => authed),
    ]);
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
    expect(guestContainer.read(fuelRepositoryProvider).runtimeType,
        isNot(equals(authedContainer.read(fuelRepositoryProvider).runtimeType)));
  });
}
