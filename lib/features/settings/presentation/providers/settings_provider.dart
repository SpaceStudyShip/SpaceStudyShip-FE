import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/set_star_twinkle_usecase.dart';

part 'settings_provider.g.dart';

// === DataSource & Repository ===

@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  throw StateError(
    'SettingsLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}

// === UseCase Providers ===

@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
SetStarTwinkleUseCase setStarTwinkleUseCase(Ref ref) {
  return SetStarTwinkleUseCase(ref.watch(settingsRepositoryProvider));
}

// === Settings 상태 관리 ===

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettingsEntity build() {
    final useCase = ref.read(getSettingsUseCaseProvider);
    return useCase.execute();
  }

  Future<void> toggleStarTwinkle() async {
    final previousState = state;
    final newValue = !state.starTwinkleEnabled;
    state = state.copyWith(starTwinkleEnabled: newValue);

    try {
      final useCase = ref.read(setStarTwinkleUseCaseProvider);
      await useCase.execute(enabled: newValue);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

// === 편의 Provider (SpaceBackground에서 사용) ===

@riverpod
bool starTwinkleEnabled(Ref ref) {
  return ref.watch(
    settingsNotifierProvider.select((s) => s.starTwinkleEnabled),
  );
}
