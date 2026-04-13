import '../../../../core/constants/space_icons.dart';
import '../../domain/entities/badge_entity.dart';

/// 배지 시드 데이터 (25개)
///
/// 정적 배지 정의. 해금 상태는 기본값(false).
/// 서버 연동 시 API 응답으로 교체 예정.
///
/// `icon` 필드는 `SpaceIcons` 의 String ID 상수를 사용한다.
/// UI 렌더링 시 `SpaceIcons.resolve(badge.icon)` 로 IconData 변환.
class BadgeSeedData {
  BadgeSeedData._();

  // ──────────────────────────────────────
  // studyTime — 공부 시간 (requiredValue: 분)
  // ──────────────────────────────────────
  static const List<BadgeEntity> studyTime = [
    BadgeEntity(
      id: 'study_1h',
      name: '첫 발걸음',
      icon: SpaceIcons.footstep,
      description: '누적 공부 시간 1시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 60,
    ),
    BadgeEntity(
      id: 'study_10h',
      name: '꾸준한 학습자',
      icon: SpaceIcons.book,
      description: '누적 공부 시간 10시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 600,
    ),
    BadgeEntity(
      id: 'study_50h',
      name: '지식 탐험가',
      icon: SpaceIcons.telescope,
      description: '누적 공부 시간 50시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 3000,
    ),
    BadgeEntity(
      id: 'study_100h',
      name: '학문의 별',
      icon: SpaceIcons.star,
      description: '누적 공부 시간 100시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 6000,
    ),
    BadgeEntity(
      id: 'study_500h',
      name: '우주 학자',
      icon: SpaceIcons.planet,
      description: '누적 공부 시간 500시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.epic,
      requiredValue: 30000,
    ),
    BadgeEntity(
      id: 'study_1000h',
      name: '은하의 현자',
      icon: SpaceIcons.galaxy,
      description: '누적 공부 시간 1,000시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.legendary,
      requiredValue: 60000,
    ),
  ];

  // ──────────────────────────────────────
  // streak — 연속 기록 (requiredValue: 일)
  // ──────────────────────────────────────
  static const List<BadgeEntity> streak = [
    BadgeEntity(
      id: 'streak_3',
      name: '3일의 약속',
      icon: SpaceIcons.fire,
      description: '3일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 3,
    ),
    BadgeEntity(
      id: 'streak_7',
      name: '일주일 파일럿',
      icon: SpaceIcons.rocket,
      description: '7일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 7,
    ),
    BadgeEntity(
      id: 'streak_14',
      name: '2주 항해사',
      icon: SpaceIcons.sailboat,
      description: '14일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      requiredValue: 14,
    ),
    BadgeEntity(
      id: 'streak_30',
      name: '한 달의 궤도',
      icon: SpaceIcons.moon,
      description: '30일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 30,
    ),
    BadgeEntity(
      id: 'streak_60',
      name: '60일의 항성',
      icon: SpaceIcons.sun,
      description: '60일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 60,
    ),
    BadgeEntity(
      id: 'streak_100',
      name: '백일의 전설',
      icon: SpaceIcons.dizzy,
      description: '100일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.legendary,
      requiredValue: 100,
    ),
  ];

  // ──────────────────────────────────────
  // session — 세션 수 (requiredValue: 횟수)
  // ──────────────────────────────────────
  static const List<BadgeEntity> session = [
    BadgeEntity(
      id: 'session_1',
      name: '엔진 점화',
      icon: SpaceIcons.target,
      description: '첫 번째 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 1,
    ),
    BadgeEntity(
      id: 'session_10',
      name: '열 번의 비행',
      icon: SpaceIcons.airplane,
      description: '공부 세션 10회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'session_50',
      name: '반백의 여정',
      icon: SpaceIcons.ufo,
      description: '공부 세션 50회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'session_100',
      name: '백전백승',
      icon: SpaceIcons.medal,
      description: '공부 세션 100회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 100,
    ),
    BadgeEntity(
      id: 'session_500',
      name: '전설의 조종사',
      icon: SpaceIcons.astronaut,
      description: '공부 세션 500회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.epic,
      requiredValue: 500,
    ),
  ];

  // ──────────────────────────────────────
  // exploration — 탐험 (requiredValue: 해금 수)
  // ──────────────────────────────────────
  static const List<BadgeEntity> exploration = [
    BadgeEntity(
      id: 'explore_first_planet',
      name: '우주의 문',
      icon: SpaceIcons.earth,
      description: '행성 2개 해금 (지구 포함)',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2,
    ),
    BadgeEntity(
      id: 'explore_all_planets',
      name: '태양계 정복자',
      icon: SpaceIcons.trophy,
      description: '모든 행성 해금',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.epic,
      requiredValue: 4,
    ),
    BadgeEntity(
      id: 'explore_first_region',
      name: '첫 탐사',
      icon: SpaceIcons.map,
      description: '지역 2개 해금 (대한민국 포함)',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2,
    ),
  ];

  // ──────────────────────────────────────
  // fuel — 연료 (requiredValue: 총 충전량)
  // ──────────────────────────────────────
  static const List<BadgeEntity> fuel = [
    BadgeEntity(
      id: 'fuel_10',
      name: '연료 수집가',
      icon: SpaceIcons.fuel,
      description: '연료 총 10 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'fuel_50',
      name: '연료 비축대장',
      icon: SpaceIcons.oilDrum,
      description: '연료 총 50 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'fuel_100',
      name: '에너지 마스터',
      icon: SpaceIcons.bolt,
      description: '연료 총 100 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.epic,
      requiredValue: 100,
    ),
  ];

  // ──────────────────────────────────────
  // hidden — 히든 (requiredValue: 24시간 기준 시각)
  // ──────────────────────────────────────
  static const List<BadgeEntity> hidden = [
    BadgeEntity(
      id: 'hidden_night_owl',
      name: '올빼미',
      icon: SpaceIcons.owl,
      description: '새벽 3시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 3,
    ),
    BadgeEntity(
      id: 'hidden_early_bird',
      name: '얼리버드',
      icon: SpaceIcons.bird,
      description: '오전 5시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 5,
    ),
  ];

  /// 전체 배지 목록 (25개)
  static const List<BadgeEntity> allBadges = [
    ...studyTime,
    ...streak,
    ...session,
    ...exploration,
    ...fuel,
    ...hidden,
  ];
}
