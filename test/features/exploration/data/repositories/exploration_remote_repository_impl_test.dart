import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_remote_datasource.dart';
import 'package:space_study_ship/features/exploration/data/models/planet_response_model.dart';
import 'package:space_study_ship/features/exploration/data/models/unlock_response_models.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_remote_repository_impl.dart';
import 'package:space_study_ship/features/exploration/domain/exceptions/exploration_exceptions.dart';
import 'package:space_study_ship/features/fuel/domain/exceptions/fuel_exceptions.dart';

class _MockRemote extends Mock implements ExplorationRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late ExplorationRemoteRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = ExplorationRemoteRepositoryImpl(remote);
  });

  PlanetResponseModel planet(String id) => PlanetResponseModel(
    id: id,
    name: id,
    nodeType: 'planet',
    depth: 2,
    icon: id,
    requiredFuel: 10,
    isUnlocked: false,
    isCleared: false,
    sortOrder: 0,
    progress: const ProgressResponseModel(clearedChildren: 1, totalChildren: 4),
  );

  DioException unlockError(String code, {int? requiredFuel, int? currentFuel}) =>
      DioException(
        requestOptions: RequestOptions(path: '/api/explorations/regions/x/unlock'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {
            'code': code,
            'message': 'msg',
            if (requiredFuel != null) 'requiredFuel': requiredFuel,
            if (currentFuel != null) 'currentFuel': currentFuel,
          },
        ),
      );

  test('getPlanets — 매핑 + getProgress 캐시 사용', () async {
    when(() => remote.getPlanets()).thenAnswer((_) async => [planet('mars')]);

    final planets = await repo.getPlanets();
    expect(planets.single.id, 'mars');

    // getProgress는 추가 fetch 없이 캐시에서 반환
    final progress = await repo.getProgress('mars');
    expect(progress.clearedChildren, 1);
    expect(progress.totalChildren, 4);
    verify(() => remote.getPlanets()).called(1); // 단 1회
  });

  test('unlockRegion INSUFFICIENT_FUEL → fuel InsufficientFuelException', () async {
    when(() => remote.unlockRegion('seoul')).thenThrow(
      unlockError('INSUFFICIENT_FUEL', requiredFuel: 10, currentFuel: 3),
    );

    expect(
      () => repo.unlockRegion('seoul'),
      throwsA(
        isA<InsufficientFuelException>()
            .having((e) => e.requiredAmount, 'requiredAmount', 10)
            .having((e) => e.available, 'available', 3),
      ),
    );
  });

  test('unlockRegion ALREADY_UNLOCKED → NodeAlreadyUnlockedException', () async {
    when(() => remote.unlockRegion('seoul'))
        .thenThrow(unlockError('ALREADY_UNLOCKED'));
    expect(
      () => repo.unlockRegion('seoul'),
      throwsA(isA<NodeAlreadyUnlockedException>()),
    );
  });

  test('unlockPlanet 성공 → 결과 엔티티', () async {
    when(() => remote.unlockPlanet('mars')).thenAnswer(
      (_) async => const PlanetUnlockResponseModel(fuelConsumed: 10, currentFuel: 40),
    );
    final result = await repo.unlockPlanet('mars');
    expect(result.currentFuel, 40);
  });
}
