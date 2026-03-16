import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/spaceship_data.dart';

part 'spaceship_provider.g.dart';

@Riverpod(keepAlive: true)
class SpaceshipNotifier extends _$SpaceshipNotifier {
  static const _prefKey = 'selected_spaceship_id';

  /// main()에서 SharedPreferences 초기화 후 호출하여
  /// build() 시점에 동기적으로 저장된 값을 반환할 수 있게 한다.
  static String? _cachedInitialId;

  static void initFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    if (saved != null && SpaceshipData.sampleList.any((s) => s.id == saved)) {
      _cachedInitialId = saved;
    }
  }

  @override
  String build() {
    return _cachedInitialId ?? SpaceshipData.sampleList.first.id;
  }

  Future<void> select(String id) async {
    if (id == state) return;
    if (!SpaceshipData.sampleList.any((s) => s.id == id)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, id);
    state = id;
  }
}
