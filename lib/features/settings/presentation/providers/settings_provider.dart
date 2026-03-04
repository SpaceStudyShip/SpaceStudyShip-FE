import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

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

// === Settings 상태 관리 ===

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettingsEntity build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getSettings();
  }

  Future<void> toggleStarTwinkle() async {
    final repository = ref.read(settingsRepositoryProvider);
    final newValue = !state.starTwinkleEnabled;
    await repository.setStarTwinkleEnabled(enabled: newValue);
    state = state.copyWith(starTwinkleEnabled: newValue);
  }
}

// === 편의 Provider (SpaceBackground에서 사용) ===

@riverpod
bool starTwinkleEnabled(Ref ref) {
  return ref.watch(
    settingsNotifierProvider.select((s) => s.starTwinkleEnabled),
  );
}
