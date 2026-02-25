import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_entity.freezed.dart';

/// 배지 해금 조건 카테고리
enum BadgeCategory {
  studyTime, // 공부 시간 기반
  streak, // 연속 기록 기반
  session, // 세션 수 기반
  exploration, // 탐험 기반
  fuel, // 연료 기반
  hidden, // 숨겨진 조건
}

/// 배지 희귀도
enum BadgeRarity { normal, rare, epic, legendary, hidden }

@freezed
class BadgeEntity with _$BadgeEntity {
  const factory BadgeEntity({
    required String id,
    required String name,
    required String icon,
    required String description,
    required BadgeCategory category,
    required BadgeRarity rarity,

    /// 해금에 필요한 조건값 (예: 60 = 60분, 7 = 7일)
    required int requiredValue,
    @Default(false) bool isUnlocked,

    /// 해금된 시간
    DateTime? unlockedAt,
  }) = _BadgeEntity;
}
