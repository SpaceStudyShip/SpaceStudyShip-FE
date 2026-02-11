import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
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

  String _rarityLabel(SpaceshipRarity rarity) {
    switch (rarity) {
      case SpaceshipRarity.normal:
        return '일반';
      case SpaceshipRarity.rare:
        return '희귀';
      case SpaceshipRarity.epic:
        return '에픽';
      case SpaceshipRarity.legendary:
        return '레전더리';
    }
  }

  Color _rarityColor(SpaceshipRarity rarity) {
    switch (rarity) {
      case SpaceshipRarity.normal:
        return AppColors.textTertiary;
      case SpaceshipRarity.rare:
        return AppColors.primary;
      case SpaceshipRarity.epic:
        return AppColors.secondary;
      case SpaceshipRarity.legendary:
        return AppColors.accentGold;
    }
  }

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

              // 우주선 그리드 (2열)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.s12,
                  mainAxisSpacing: AppSpacing.s12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _spaceships.length,
                itemBuilder: (context, index) {
                  return _buildCollectionCard(_spaceships[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(SpaceshipData spaceship) {
    final rarityColor = _rarityColor(spaceship.rarity);
    final borderColor =
        spaceship.isUnlocked ? rarityColor : AppColors.spaceDivider;

    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: spaceship.isUnlocked &&
                spaceship.rarity == SpaceshipRarity.legendary
            ? [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Stack(
            alignment: Alignment.center,
            children: [
              spaceship.isUnlocked
                  ? SpaceIcons.buildIcon(spaceship.icon, size: 48.w)
                  : Icon(
                      SpaceIcons.resolve(spaceship.icon),
                      size: 48.w,
                      color: AppColors.textTertiary,
                    ),
              if (!spaceship.isUnlocked)
                Icon(
                  Icons.lock_rounded,
                  size: 24.w,
                  color: AppColors.textTertiary,
                ),
              if (spaceship.isAnimated && spaceship.isUnlocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14.w,
                    color: AppColors.accentGold,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s12),

          // 이름
          Text(
            spaceship.isUnlocked ? spaceship.name : '???',
            style: AppTextStyles.label16Medium.copyWith(
              color:
                  spaceship.isUnlocked ? Colors.white : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.s4),

          // 희귀도 태그
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (spaceship.isUnlocked ? rarityColor : AppColors.spaceDivider)
                  .withValues(alpha: 0.15),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              _rarityLabel(spaceship.rarity),
              style: AppTextStyles.tag_10.copyWith(
                color: spaceship.isUnlocked
                    ? rarityColor
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
