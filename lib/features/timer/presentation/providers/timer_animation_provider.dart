import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_animation_data.dart';

part 'timer_animation_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerAnimationNotifier extends _$TimerAnimationNotifier {
  static const _prefKey = 'timer_lottie_asset';

  /// main()에서 SharedPreferences 초기화 후 호출하여
  /// build() 시점에 동기적으로 저장된 값을 반환할 수 있게 한다.
  static String? _cachedInitialAsset;

  static void initFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    if (saved != null && TimerAnimationData.isValidAsset(saved)) {
      _cachedInitialAsset = saved;
    }
  }

  @override
  String build() {
    return _cachedInitialAsset ?? TimerAnimationData.defaultAsset;
  }

  Future<void> select(String asset) async {
    if (asset == state) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, asset);
    state = asset;
  }
}
