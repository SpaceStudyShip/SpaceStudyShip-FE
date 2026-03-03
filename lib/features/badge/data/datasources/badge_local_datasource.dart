import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_model.dart';

class BadgeLocalDataSource {
  static const _unlockedKey = 'badge_unlocked_data';

  final SharedPreferences _prefs;

  Future<void> _writeLock = Future.value();

  BadgeLocalDataSource(this._prefs);

  /// write 작업 직렬화 — 동시 호출 시 순차 실행 보장
  Future<void> _synchronized(Future<void> Function() fn) async {
    final previous = _writeLock;
    final completer = Completer<void>();
    _writeLock = completer.future;
    await previous;
    try {
      await fn();
    } finally {
      completer.complete();
    }
  }

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
      unawaited(_synchronized(() => _prefs.remove(_unlockedKey)));
      return {};
    }
  }

  /// 배지 해금 저장
  Future<void> unlockBadge(BadgeUnlockModel model) async {
    await _synchronized(() async {
      final current = getUnlockedBadges();
      current[model.badgeId] = model;
      await _saveAll(current.values.toList());
    });
  }

  /// 전체 초기화
  Future<void> clearAll() async {
    await _synchronized(() async {
      await _prefs.remove(_unlockedKey);
      debugPrint('Badge 캐시 삭제 완료');
    });
  }

  Future<void> _saveAll(List<BadgeUnlockModel> models) async {
    final jsonString = jsonEncode(models.map((e) => e.toJson()).toList());
    await _prefs.setString(_unlockedKey, jsonString);
  }
}
