import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/widgets/space/spaceship_card.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../widgets/spaceship_selector.dart';

/// 홈 스크린
///
/// 우주선을 화면 중앙에 크게 배치하고,
/// 상단 바에 연료 등 재화 칩을 표시합니다.
/// 할 일/활동은 하단 시트로 제공합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 임시 상태 (나중에 Riverpod Provider로 이동)
  String _selectedSpaceshipId = 'default';
  String _selectedSpaceshipIcon = '🚀';
  String _selectedSpaceshipName = '화성 탐사선';
  final double _fuel = 85.0;
  final int _streakDays = 5;
  final bool _isStreakActive = true;
  bool _isSpaceshipPressed = false;
  bool _isSheetExpanded = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // 임시 할 일 데이터 (나중에 Riverpod Provider로 이동)
  final List<Map<String, dynamic>> _todos = [
    {'title': '알고리즘 2문제 풀기', 'subtitle': '30분', 'completed': false},
    {'title': '영어 단어 50개 외우기', 'subtitle': '20분', 'completed': true},
    {'title': '수학 과제 제출', 'subtitle': '1시간', 'completed': false},
    {'title': '물리 노트 정리', 'subtitle': '40분', 'completed': false},
  ];

  // 샘플 우주선 데이터
  final List<SpaceshipData> _spaceships = [
    const SpaceshipData(
      id: 'default',
      icon: '🚀',
      name: '화성 탐사선',
      isUnlocked: true,
      rarity: SpaceshipRarity.normal,
    ),
    const SpaceshipData(
      id: 'ufo',
      icon: '🛸',
      name: 'UFO',
      isUnlocked: true,
      rarity: SpaceshipRarity.rare,
    ),
    const SpaceshipData(
      id: 'satellite',
      icon: '🛰️',
      name: '인공위성',
      isUnlocked: true,
      isAnimated: true,
      rarity: SpaceshipRarity.epic,
    ),
    const SpaceshipData(
      id: 'star',
      icon: '🌟',
      name: '스타쉽',
      isUnlocked: false,
      rarity: SpaceshipRarity.legendary,
    ),
    const SpaceshipData(
      id: 'shuttle',
      icon: '🚁',
      name: '셔틀',
      isUnlocked: false,
      rarity: SpaceshipRarity.normal,
    ),
    const SpaceshipData(
      id: 'moon',
      icon: '🌙',
      name: '달 탐사선',
      isUnlocked: false,
      rarity: SpaceshipRarity.rare,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    final expanded = _sheetController.size > 0.3;
    if (expanded != _isSheetExpanded) {
      setState(() => _isSheetExpanded = expanded);
    }
  }

  Color get _fuelColor {
    if (_fuel >= 75) return AppColors.fuelFull;
    if (_fuel >= 50) return AppColors.fuelMedium;
    if (_fuel >= 25) return AppColors.fuelLow;
    return AppColors.fuelEmpty;
  }

  void _showSpaceshipSelector() {
    showSpaceshipSelector(
      context: context,
      spaceships: _spaceships,
      selectedId: _selectedSpaceshipId,
      onSelect: (id) {
        final selected = _spaceships.firstWhere((s) => s.id == id);
        setState(() {
          _selectedSpaceshipId = id;
          _selectedSpaceshipIcon = selected.icon;
          _selectedSpaceshipName = selected.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // 메인 콘텐츠
          GestureDetector(
            onTap: () {
              _sheetController.animateTo(
                0.22,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            behavior: HitTestBehavior.translucent,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: _buildSpaceshipArea()),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),

          // 하단 시트
          _buildBottomSheet(),
        ],
      ),
    );
  }

  /// 상단 바: 스트릭 배지 + 알림 아이콘
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          if (_streakDays > 0)
            FadeSlideIn(
              child: StreakBadge(
                days: _streakDays,
                isActive: _isStreakActive,
                showLabel: true,
                size: StreakBadgeSize.medium,
              ),
            ),
          const Spacer(),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_gas_station_rounded,
                  size: 18.w,
                  color: _fuelColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  _fuel.toStringAsFixed(0),
                  style: AppTextStyles.label_16.copyWith(
                    color: _fuelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s4),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: 알림 화면
            },
          ),
        ],
      ),
    );
  }

  /// 우주선 영역: 중앙 우주선
  Widget _buildSpaceshipArea() {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
        onTapUp: (_) {
          setState(() => _isSpaceshipPressed = false);
          _showSpaceshipSelector();
        },
        onTapCancel: () => setState(() => _isSpaceshipPressed = false),
        child: AnimatedScale(
          scale: _isSpaceshipPressed
              ? TossDesignTokens.buttonTapScale
              : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpaceshipAvatar(
                  icon: _selectedSpaceshipIcon,
                  size: 200,
                ),
                SizedBox(height: AppSpacing.s16),
                Text(
                  _selectedSpaceshipName,
                  style: AppTextStyles.heading_20.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
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
      ),
    );
  }

  /// 하단 시트: 할 일 + 활동 카드
  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.22,
      minChildSize: 0.22,
      maxChildSize: 0.6,
      snap: true,
      snapSizes: const [0.22, 0.6],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _isSheetExpanded
              ? _buildExpandedSheet(scrollController)
              : _buildCollapsedSheet(scrollController),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  /// 접힌 상태: 컴팩트 미리보기
  Widget _buildCollapsedSheet(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),
        GestureDetector(
          onTap: () {
            _sheetController.animateTo(
              0.6,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                Text(
                  '오늘의 할 일',
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                Text(
                  '· ${_todos.where((t) => !(t['completed'] as bool)).length}개',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textTertiary,
                  size: 24.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 펼친 상태: 할 일 미리보기
  Widget _buildExpandedSheet(ScrollController scrollController) {
    final previewTodos = _todos.take(3).toList();

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),

        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: _buildSectionTitle('오늘의 할 일'),
        ),
        SizedBox(height: AppSpacing.s16),

        if (previewTodos.isEmpty)
          Padding(
            padding: AppPadding.horizontal20,
            child: _buildEmptyTodoCard(),
          )
        else ...[
          ...previewTodos.map((todo) {
            final index = _todos.indexOf(todo);
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
              child: TodoItem(
                title: todo['title'] as String,
                subtitle: todo['subtitle'] as String?,
                isCompleted: todo['completed'] as bool,
                onToggle: () {
                  setState(() {
                    _todos[index]['completed'] =
                        !(_todos[index]['completed'] as bool);
                  });
                },
              ),
            );
          }),

          // "더보기" 버튼
          if (_todos.length > 3)
            Padding(
              padding: AppPadding.horizontal20,
              child: TextButton(
                onPressed: () => context.push(RoutePaths.todoList),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '더보기',
                      style: AppTextStyles.label_16.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16.w,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],

        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmptyTodoCard() {
    return AppCard(
      style: AppCardStyle.outlined,
      padding: AppPadding.all24,
      child: SpaceEmptyState(
        icon: Icons.edit_note_rounded,
        title: '오늘의 할 일이 없어요',
        subtitle: '할 일을 추가해보세요',
        iconSize: 40,
        animated: false,
      ),
    );
  }

}
