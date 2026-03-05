import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/widgets/timer_animation_selector.dart';

part 'timer_animation_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerAnimationNotifier extends _$TimerAnimationNotifier {
  static const _prefKey = 'timer_lottie_asset';

  @override
  String build() {
    _loadSaved();
    return TimerAnimationData.defaultAsset;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && TimerAnimationData.isValidAsset(saved)) {
      state = saved;
    }
  }

  Future<void> select(String asset) async {
    if (asset == state) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, asset);
    state = asset;
  }
}
