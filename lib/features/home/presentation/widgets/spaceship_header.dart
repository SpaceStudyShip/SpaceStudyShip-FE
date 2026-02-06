import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import 'home_stat_chip.dart';

/// 우주선 헤더 위젯 - SliverAppBar의 flexibleSpace용
///
/// 스크롤에 따라 우주선이 축소되는 애니메이션을 제공합니다.
///
/// **사용 예시**:
/// ```dart
/// SpaceshipHeader(
///   spaceshipIcon: '🚀',
///   spaceshipName: '화성 탐사선',
///   fuel: 85.0,
///   experience: 1234,
///   streakDays: 5,
///   isStreakActive: true,
///   onSpaceshipTap: () => showSpaceshipSelector(),
/// )
/// ```
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

  /// 현재 우주선 아이콘 (이모지)
  final String spaceshipIcon;

  /// 우주선 이름
  final String spaceshipName;

  /// 연료량
  final double fuel;

  /// 경험치
  final int experience;

  /// 연속 공부 일수
  final int streakDays;

  /// 오늘 공부 여부
  final bool isStreakActive;

  /// 우주선 탭 콜백 (변경하기)
  final VoidCallback onSpaceshipTap;

  /// 확장 높이
  final double expandedHeight;

  @override
  State<SpaceshipHeader> createState() => _SpaceshipHeaderState();
}

class _SpaceshipHeaderState extends State<SpaceshipHeader> {
  bool _isSpaceshipPressed = false;

  /// 연료 상태에 따른 색상
  Color get _fuelColor {
    if (widget.fuel >= 75) return AppColors.fuelFull;
    if (widget.fuel >= 50) return AppColors.fuelMedium;
    if (widget.fuel >= 25) return AppColors.fuelLow;
    return AppColors.fuelEmpty;
  }

  /// 경험치 포맷팅 (1234 → 1,234)
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7, 1.0],
          colors: [
            AppColors.spaceBackground,
            AppColors.spaceBackground,
            AppColors.spaceBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 8.h),

            // 스트릭 배지
            if (widget.streakDays > 0)
              StreakBadge(
                days: widget.streakDays,
                isActive: widget.isStreakActive,
                showLabel: true,
                size: StreakBadgeSize.medium,
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
                    // 우주선 아이콘
                    Text(
                      widget.spaceshipIcon,
                      style: TextStyle(fontSize: 80.w),
                    ),
                    SizedBox(height: 8.h),

                    // 우주선 이름
                    Text(
                      widget.spaceshipName,
                      style: AppTextStyles.heading_20.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 연료 칩
                  HomeStatChip(
                    icon: '⛽',
                    value: widget.fuel.toStringAsFixed(0),
                    label: '연료',
                    valueColor: _fuelColor,
                  ),
                  SizedBox(width: 16.w),

                  // 경험치 칩
                  HomeStatChip(
                    icon: '⭐',
                    value: _formattedExperience,
                    label: '경험치',
                    valueColor: AppColors.accentGold,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
