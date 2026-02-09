import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import 'home_stat_chip.dart';

/// 우주선 헤더 위젯 - SliverAppBar의 flexibleSpace용
///
/// 스크롤에 따라 우주선이 축소되는 애니메이션을 제공합니다.
class SpaceshipHeader extends StatefulWidget {
  const SpaceshipHeader({
    super.key,
    required this.spaceshipIcon,
    required this.spaceshipName,
    required this.fuel,
    required this.experience,
    required this.streakDays,
    required this.isStreakActive,
    required this.onSpaceshipTap,
    this.expandedHeight = 320.0,
  });

  final String spaceshipIcon;
  final String spaceshipName;
  final double fuel;
  final int experience;
  final int streakDays;
  final bool isStreakActive;
  final VoidCallback onSpaceshipTap;
  final double expandedHeight;

  @override
  State<SpaceshipHeader> createState() => _SpaceshipHeaderState();
}

class _SpaceshipHeaderState extends State<SpaceshipHeader> {
  bool _isSpaceshipPressed = false;

  Color get _fuelColor {
    if (widget.fuel >= 75) return AppColors.fuelFull;
    if (widget.fuel >= 50) return AppColors.fuelMedium;
    if (widget.fuel >= 25) return AppColors.fuelLow;
    return AppColors.fuelEmpty;
  }

  String get _formattedExperience {
    if (widget.experience >= 1000) {
      final thousands = widget.experience ~/ 1000;
      final remainder = widget.experience % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return widget.experience.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.expandedHeight.h,
      decoration: const BoxDecoration(
        gradient: AppGradients.cosmicHeader,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: AppSpacing.s8),

            // 스트릭 배지
            if (widget.streakDays > 0)
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: StreakBadge(
                  days: widget.streakDays,
                  isActive: widget.isStreakActive,
                  showLabel: true,
                  size: StreakBadgeSize.medium,
                ),
              ),

            const Spacer(),

            // 우주선 영역
            GestureDetector(
              onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
              onTapUp: (_) {
                setState(() => _isSpaceshipPressed = false);
                widget.onSpaceshipTap();
              },
              onTapCancel: () => setState(() => _isSpaceshipPressed = false),
              child: AnimatedScale(
                scale: _isSpaceshipPressed
                    ? TossDesignTokens.buttonTapScale
                    : 1.0,
                duration: TossDesignTokens.animationFast,
                curve: TossDesignTokens.springCurve,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 우주선 아이콘 - 그라데이션 원형 + glow
                    _buildSpaceshipIcon(),
                    SizedBox(height: AppSpacing.s12),

                    // 우주선 이름
                    Text(
                      widget.spaceshipName,
                      style: AppTextStyles.heading_20.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),

                    // 변경하기 버튼
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '변경하기',
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right,
                          size: 14.w,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 상태 칩들
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: AppPadding.horizontal20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeStatChip(
                      iconData: Icons.local_gas_station_rounded,
                      value: widget.fuel.toStringAsFixed(0),
                      label: '연료',
                      valueColor: _fuelColor,
                    ),
                    SizedBox(width: AppSpacing.s16),
                    HomeStatChip(
                      iconData: Icons.star_rounded,
                      value: _formattedExperience,
                      label: '경험치',
                      valueColor: AppColors.accentGold,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.s20),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceshipIcon() {
    return SpaceshipAvatar(
      icon: widget.spaceshipIcon,
      size: 120,
    );
  }
}
