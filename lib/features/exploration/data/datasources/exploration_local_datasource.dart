import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 탐험 노드 상태 (영속화 대상)
///
/// 시드 데이터의 정적 정보를 제외한 변동 상태만 저장.
/// 향후 백엔드 연동 시 서버 DB로 교체.
class ExplorationNodeState {
  const ExplorationNodeState({
    required this.nodeId,
    this.isUnlocked = false,
    this.isCleared = false,
    this.unlockedAt,
  });

  final String nodeId;
  final bool isUnlocked;
  final bool isCleared;
  final DateTime? unlockedAt;

  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
    'is_unlocked': isUnlocked,
    'is_cleared': isCleared,
    'unlocked_at': unlockedAt?.toIso8601String(),
  };

  factory ExplorationNodeState.fromJson(Map<String, dynamic> json) {
    return ExplorationNodeState(
      nodeId: json['node_id'] as String,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      isCleared: json['is_cleared'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }
}

/// 탐험 상태 로컬 DataSource
///
/// SharedPreferences에 노드별 해금/클리어 상태를 저장합니다.
/// 향후 백엔드 연동 시 ExplorationRemoteDataSource로 교체 예정.
class ExplorationLocalDataSource {
  static const _stateKey = 'guest_exploration_states';

  final SharedPreferences _prefs;

  ExplorationLocalDataSource(this._prefs);

  /// 모든 노드 상태 조회
  Map<String, ExplorationNodeState> getAllStates() {
    final jsonString = _prefs.getString(_stateKey);
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonMap.map(
        (key, value) => MapEntry(
          key,
          ExplorationNodeState.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Exploration 상태 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_stateKey);
      return {};
    }
  }

  /// 특정 노드 상태 저장
  Future<void> saveNodeState(ExplorationNodeState state) async {
    final states = getAllStates();
    states[state.nodeId] = state;
    await _saveAll(states);
  }

  /// 전체 상태 저장
  Future<void> _saveAll(Map<String, ExplorationNodeState> states) async {
    final jsonMap = states.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_stateKey, jsonEncode(jsonMap));
  }

  /// 전체 삭제 (게스트 로그아웃 시)
  Future<void> clearAll() async {
    final count = getAllStates().length;
    await _prefs.remove(_stateKey);
    debugPrint('🧹 Exploration 상태 삭제 완료 (노드: $count건)');
  }
}
