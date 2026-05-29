import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_local_datasource.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_remote_repository_impl.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_repository_impl.dart';
import 'package:space_study_ship/features/exploration/presentation/providers/exploration_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> container({required bool authed}) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        explorationLocalDataSourceProvider.overrideWithValue(
          ExplorationLocalDataSource(prefs),
        ),
        isAuthenticatedProvider.overrideWith((ref) => authed),
      ],
    );
  }

  test('게스트 → Local repo 주입', () async {
    final c = await container(authed: false);
    addTearDown(c.dispose);
    expect(
      c.read(explorationRepositoryProvider),
      isA<ExplorationLocalRepositoryImpl>(),
    );
  });

  test('인증 → Remote repo 주입', () async {
    final c = await container(authed: true);
    addTearDown(c.dispose);
    expect(
      c.read(explorationRepositoryProvider),
      isA<ExplorationRemoteRepositoryImpl>(),
    );
  });

  test('게스트 정리: localDataSource.clearAll 직접 호출 — 순환참조 없음', () async {
    // 8.1 회귀: repo 분기 추가 후에도 localDataSource 직접 경로가 동작.
    final c = await container(authed: false);
    addTearDown(c.dispose);
    final ds = c.read(explorationLocalDataSourceProvider);
    await ds.saveNodeState(
      const ExplorationNodeState(
        nodeId: 'japan',
        isUnlocked: true,
        isCleared: true,
      ),
    );
    await ds.clearAll();
    expect(ds.getAllStates(), isEmpty);
  });
}
