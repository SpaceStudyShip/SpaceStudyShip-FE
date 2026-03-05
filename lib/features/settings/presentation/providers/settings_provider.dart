import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/settings_data_providers.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/set_star_twinkle_usecase.dart';

part 'settings_provider.g.dart';

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
      await useCase.execute(isEnabled: newValue);
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
