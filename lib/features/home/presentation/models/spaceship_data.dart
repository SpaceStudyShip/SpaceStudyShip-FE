import '../../../../core/constants/space_icons.dart';
import '../../../../core/widgets/space/spaceship_card.dart';

/// 우주선 데이터 모델 (임시 — 서버 연동 시 domain entity 로 전환)
class SpaceshipData {
  const SpaceshipData({
    required this.id,
    required this.icon,
    required this.name,
    this.isUnlocked = false,
    this.isAnimated = false,
    this.rarity = SpaceshipRarity.normal,
    this.lottieAsset,
  });

  final String id;
  final String icon;
  final String name;
  final bool isUnlocked;
  final bool isAnimated;
  final SpaceshipRarity rarity;
  final String? lottieAsset;

  /// 임시 샘플 데이터 (나중에 Riverpod Provider 로 이동)
  static const sampleList = [
    SpaceshipData(
      id: 'default',
      icon: SpaceIcons.rocket,
      name: '우주공부선',
      isUnlocked: true,
      rarity: SpaceshipRarity.normal,
      lottieAsset: 'assets/lotties/default_rocket.json',
    ),
    SpaceshipData(
      id: 'ufo',
      icon: SpaceIcons.ufo,
      name: 'UFO',
      isUnlocked: true,
      rarity: SpaceshipRarity.rare,
    ),
    SpaceshipData(
      id: 'satellite',
      icon: SpaceIcons.satellite,
      name: '인공위성',
      isUnlocked: true,
      isAnimated: true,
      rarity: SpaceshipRarity.epic,
    ),
    SpaceshipData(
      id: 'star',
      icon: SpaceIcons.sparkleStar,
      name: '스타쉽',
      isUnlocked: false,
      rarity: SpaceshipRarity.legendary,
    ),
    SpaceshipData(
      id: 'shuttle',
      icon: SpaceIcons.helicopter,
      name: '셔틀',
      isUnlocked: false,
      rarity: SpaceshipRarity.normal,
    ),
    SpaceshipData(
      id: 'moon',
      icon: SpaceIcons.moon,
      name: '달 탐사선',
      isUnlocked: false,
      rarity: SpaceshipRarity.rare,
    ),
  ];
}
