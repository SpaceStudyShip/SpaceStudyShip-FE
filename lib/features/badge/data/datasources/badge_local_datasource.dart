import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_model.dart';

class BadgeLocalDataSource {
  static const _unlockedKey = 'badge_unlocked_data';

  final SharedPreferences _prefs;

  BadgeLocalDataSource(this._prefs);

  /// 해금된 배지 ID -> UnlockModel 맵
  Map<String, BadgeUnlockModel> getUnlockedBadges() {
    final jsonString = _prefs.getString(_unlockedKey);
    if (jsonString == null) return {};

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final models = jsonList
          .map((e) => BadgeUnlockModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return {for (final m in models) m.badgeId: m};
    } catch (e) {
      debugPrint('Badge 데이터 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_unlockedKey);
      return {};
    }
  }

  /// 배지 해금 저장
  Future<void> unlockBadge(BadgeUnlockModel model) async {
    final current = getUnlockedBadges();
    current[model.badgeId] = model;
    await _saveAll(current.values.toList());
  }

  /// 신규 표시 제거
  Future<void> markSeen(String badgeId) async {
    final current = getUnlockedBadges();
    final model = current[badgeId];
    if (model != null && model.isNew) {
      current[badgeId] = model.copyWith(isNew: false);
      await _saveAll(current.values.toList());
    }
  }

  /// 전체 초기화
  Future<void> clearAll() async {
    await _prefs.remove(_unlockedKey);
    debugPrint('Badge 캐시 삭제 완료');
  }

  Future<void> _saveAll(List<BadgeUnlockModel> models) async {
    final jsonString = jsonEncode(models.map((e) => e.toJson()).toList());
    await _prefs.setString(_unlockedKey, jsonString);
  }
}
