import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/widgets/backgrounds/space_background.dart';

/// 메인 네비게이션 쉘 (바텀 네비게이션)
///
/// StatefulShellRoute와 함께 사용되어 탭 간 상태를 유지합니다.
/// 글래스모피즘 배경 + active dot indicator 적용.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          navigationShell,
        ],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.spaceBackground.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: AppColors.spaceDivider.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: '홈',
                      isSelected: navigationShell.currentIndex == 0,
                      onTap: () => _onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.timer_outlined,
                      activeIcon: Icons.timer_rounded,
                      label: '타이머',
                      isSelected: navigationShell.currentIndex == 1,
                      onTap: () => _onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore_rounded,
                      label: '탐험',
                      isSelected: navigationShell.currentIndex == 2,
                      onTap: () => _onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: '소셜',
                      isSelected: navigationShell.currentIndex == 3,
                      onTap: () => _onTap(3),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: '프로필',
                      isSelected: navigationShell.currentIndex == 4,
                      onTap: () => _onTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// 네비게이션 아이템 위젯
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 24.w,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: isSelected
                    ? 'Pretendard-SemiBold'
                    : 'Pretendard-Medium',
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isSelected ? 4.w : 0,
              height: isSelected ? 4.w : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
