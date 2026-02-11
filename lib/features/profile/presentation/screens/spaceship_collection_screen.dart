import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/space/spaceship_card.dart';
import '../../../home/presentation/widgets/spaceship_selector.dart';

/// 우주선 컬렉션 스크린
///
/// 보유 중인 우주선 목록을 그리드로 표시합니다.
class SpaceshipCollectionScreen extends StatelessWidget {
  const SpaceshipCollectionScreen({super.key});

  // 임시 데이터 (나중에 Riverpod Provider로 이동)
  static const _spaceships = [
    SpaceshipData(
      id: 'default',
      icon: '🚀',
      name: '우주공부선',
      isUnlocked: true,
      rarity: SpaceshipRarity.normal,
      lottieAsset: 'assets/lotties/default_rocket.json',
    ),
    SpaceshipData(
      id: 'ufo',
      icon: '🛸',
      name: 'UFO',
      isUnlocked: true,
      rarity: SpaceshipRarity.rare,
    ),
    SpaceshipData(
      id: 'satellite',
      icon: '🛰️',
      name: '인공위성',
      isUnlocked: true,
      isAnimated: true,
      rarity: SpaceshipRarity.epic,
    ),
    SpaceshipData(
      id: 'star',
      icon: '🌟',
      name: '스타쉽',
      isUnlocked: false,
      rarity: SpaceshipRarity.legendary,
    ),
    SpaceshipData(
      id: 'shuttle',
      icon: '🚁',
      name: '셔틀',
      isUnlocked: false,
      rarity: SpaceshipRarity.normal,
    ),
    SpaceshipData(
      id: 'moon',
      icon: '🌙',
      name: '달 탐사선',
      isUnlocked: false,
      rarity: SpaceshipRarity.rare,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = _spaceships.where((s) => s.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '우주선 컬렉션',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 수집 현황
              Text(
                '$unlocked / ${_spaceships.length} 해금',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: AppSpacing.s20),

              // 우주선 그리드
              Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s12,
                children: _spaceships.map((spaceship) {
                  return SpaceshipCard(
                    icon: spaceship.icon,
                    name: spaceship.name,
                    isUnlocked: spaceship.isUnlocked,
                    isAnimated: spaceship.isAnimated,
                    rarity: spaceship.rarity,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
