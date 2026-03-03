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

/// 배지 해금 조건 텍스트 (잠금 상태에서 표시용)
extension BadgeEntityX on BadgeEntity {
  String get unlockConditionText {
    switch (category) {
      case BadgeCategory.studyTime:
        final hours = requiredValue ~/ 60;
        if (hours >= 1) {
          return '누적 공부 시간 ${_formatNumber(hours)}시간 달성';
        }
        return '누적 공부 시간 $requiredValue분 달성';
      case BadgeCategory.streak:
        return '$requiredValue일 연속 공부 달성';
      case BadgeCategory.session:
        return '공부 세션 ${_formatNumber(requiredValue)}회 완료';
      case BadgeCategory.exploration:
        // 탐험은 ID 기반 분기가 필요해 description 사용
        return description;
      case BadgeCategory.fuel:
        return '연료 총 ${_formatNumber(requiredValue)} 충전';
      case BadgeCategory.hidden:
        return '???';
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return value.toString();
  }
}
