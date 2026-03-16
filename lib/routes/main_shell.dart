import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/spacing_and_radius.dart';
import '../core/constants/text_styles.dart';
import '../core/constants/toss_design_tokens.dart';
import '../core/widgets/backgrounds/space_background.dart';
import 'navigation_providers.dart';

/// 탭 개수
const _tabCount = 5;

/// 메인 네비게이션 쉘 (플로팅 글래스모피즘 바텀 네비게이션)
///
/// StatefulShellRoute와 함께 사용되어 탭 간 상태를 유지합니다.
/// 플로팅 캡슐 형태 + 글래스모피즘 배경 + 슬라이딩 인디케이터 적용.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          navigationShell,

          // 플로팅 바텀 네비게이션
          if (ref.watch(isFloatingNavVisibleProvider))
            Positioned(
              left: FloatingNavMetrics.horizontalMargin,
              right: FloatingNavMetrics.horizontalMargin,
              bottom: bottomPadding + FloatingNavMetrics.bottomMargin,
              child: _FloatingNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => _onTap(ref, index),
              ),
            ),
        ],
      ),
    );
  }

  void _onTap(WidgetRef ref, int index) {
    // 홈 탭 재탭: 바텀시트 닫기 이벤트 발행
    if (index == 0 && index == navigationShell.currentIndex) {
      ref.read(homeReTapProvider.notifier).state++;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// 플로팅 바텀 네비게이션 바 (iOS 스타일)
///
/// 불투명 다크 배경 캡슐 + 슬라이딩 glass pill 인디케이터.
/// 롱프레스 + 드래그로 인디케이터를 이동, 릴리스 시 가장 가까운 탭으로 전환.
class _FloatingNavBar extends StatefulWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar> {
  static const _items = <_NavItemData>[
    _NavItemData(Icons.home_outlined, Icons.home_rounded, '홈'),
    _NavItemData(Icons.timer_outlined, Icons.timer_rounded, '타이머'),
    _NavItemData(Icons.explore_outlined, Icons.explore_rounded, '탐험'),
    _NavItemData(Icons.people_outline_rounded, Icons.people_rounded, '소셜'),
    _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, '프로필'),
  ];

  /// 드래그 중인지 여부
  bool _isDragging = false;

  /// 드래그 중 인디케이터의 left 위치 (px)
  double _dragLeft = 0;

  /// 바 전체 너비 (LayoutBuilder에서 갱신)
  double _barWidth = 0;

  double get _itemWidth => _barWidth / _tabCount;

  /// 드래그 위치 기준 가장 가까운 탭 인덱스
  int get _dragHoverIndex {
    if (_barWidth == 0) return widget.currentIndex;
    final center = _dragLeft + _itemWidth / 2;
    final index = (center / _itemWidth).floor().clamp(0, _tabCount - 1);
    return index;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragLeft = (widget.currentIndex * _itemWidth).clamp(
        0.0,
        _barWidth - _itemWidth,
      );
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    final targetIndex = _dragHoverIndex;
    setState(() => _isDragging = false);
    widget.onTap(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: FloatingNavMetrics.barHeight,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.floatingNav,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      // 유리 질감: 표면 빛 반사 gradient + gradient border
      foregroundDecoration: BoxDecoration(
        borderRadius: AppRadius.floatingNav,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.06), Colors.transparent],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _barWidth = constraints.maxWidth;
          final itemWidth = _itemWidth;

          // 인디케이터 위치: 드래그 중이면 드래그 위치, 아니면 현재 탭
          final indicatorLeft = _isDragging
              ? _dragLeft
              : widget.currentIndex * itemWidth;

          // 드래그 중 하이라이트할 탭
          final highlightIndex = _isDragging
              ? _dragHoverIndex
              : widget.currentIndex;

          return GestureDetector(
            onLongPressStart: _onLongPressStart,
            onLongPressMoveUpdate: (details) {
              setState(() {
                _dragLeft = (details.localPosition.dx - itemWidth / 2).clamp(
                  0.0,
                  _barWidth - itemWidth,
                );
              });
            },
            onLongPressEnd: _onLongPressEnd,
            child: Stack(
              children: [
                // 슬라이딩 glass pill 인디케이터
                AnimatedPositioned(
                  // 드래그 중이면 즉각 반응, 탭 전환은 스프링 애니메이션
                  duration: _isDragging
                      ? Duration.zero
                      : TossDesignTokens.animationNormal,
                  curve: TossDesignTokens.springCurve,
                  left: indicatorLeft,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Center(
                    child: _GlassPillIndicator(
                      width: itemWidth - AppSpacing.s8,
                      height: FloatingNavMetrics.barHeight - AppSpacing.s12,
                    ),
                  ),
                ),

                // 탭 아이템들
                Row(
                  children: List.generate(_tabCount, (index) {
                    final item = _items[index];
                    final isSelected = index == highlightIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: _NavItemWidget(
                          icon: item.icon,
                          activeIcon: item.activeIcon,
                          label: item.label,
                          isSelected: isSelected,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 선택 탭 뒤 glass pill 인디케이터
///
/// iOS 시계 앱 스타일: 약간 밝은 배경 + 얇은 밝은 border glow.
class _GlassPillIndicator extends StatelessWidget {
  const _GlassPillIndicator({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // 바 배경보다 약간 밝은 elevated 색상
        color: AppColors.spaceElevated,
        borderRadius: AppRadius.xxlarge,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: [
          // 미세한 glow
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

/// 네비게이션 아이템 데이터
class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 네비게이션 아이템 위젯
class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: TossDesignTokens.animationFast,
          child: Icon(
            isSelected ? activeIcon : icon,
            key: ValueKey(isSelected),
            size: 22.w,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style:
              (isSelected ? AppTextStyles.tag10Semibold : AppTextStyles.tag_10)
                  .copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
        ),
      ],
    );
  }
}
