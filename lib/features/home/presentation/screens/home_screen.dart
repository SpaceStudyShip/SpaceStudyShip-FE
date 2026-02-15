import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import '../../../todo/presentation/widgets/todo_add_bottom_sheet.dart';
import '../widgets/spaceship_selector.dart';

/// 홈 스크린
///
/// 우주선을 화면 중앙에 크게 배치하고,
/// 상단 바에 연료 등 재화 칩을 표시합니다.
/// 할 일/활동은 하단 시트로 제공합니다.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 임시 상태 (나중에 Riverpod Provider로 이동)
  String _selectedSpaceshipId = 'default';
  String _selectedSpaceshipIcon = '🚀';
  String? _selectedLottieAsset = 'assets/lotties/default_rocket.json';
  final int _streakDays = 5;
  final bool _isStreakActive = true;
  bool _isSpaceshipPressed = false;
  bool _isSheetExpanded = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // 샘플 우주선 데이터 (SpaceshipData.sampleList 공유)
  final List<SpaceshipData> _spaceships = SpaceshipData.sampleList;

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
          _selectedLottieAsset = selected.lottieAsset;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _streakDays > 0
            ? FadeSlideIn(
                child: StreakBadge(
                  days: _streakDays,
                  isActive: _isStreakActive,
                  showLabel: true,
                  size: StreakBadgeSize.large,
                ),
              )
            : null,
        centerTitle: false,
        actions: [
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
          SizedBox(width: 2.w),
        ],
      ),
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
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
                Expanded(child: _buildSpaceshipArea()),
                SizedBox(height: 80.h),
              ],
            ),
          ),

          // 하단 시트
          _buildBottomSheet(),
        ],
      ),
    );
  }

  /// 우주선 영역: 중앙보다 살짝 위
  Widget _buildSpaceshipArea() {
    return Align(
      alignment: const Alignment(0, -0.3),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
        onTapUp: (_) {
          setState(() => _isSpaceshipPressed = false);
          if (_isSheetExpanded) {
            _sheetController.animateTo(
              0.22,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _showSpaceshipSelector();
          }
        },
        onTapCancel: () => setState(() => _isSpaceshipPressed = false),
        child: AnimatedScale(
          scale: _isSpaceshipPressed ? TossDesignTokens.buttonTapScale : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpaceshipAvatar(
                  icon: _selectedSpaceshipIcon,
                  size: 320,
                  lottieAsset: _selectedLottieAsset,
                ),
                // 바텀시트와 우주선 간 여백 확보
                SizedBox(height: 58.h),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                Text(
                  '· ${ref.watch(todoListNotifierProvider).valueOrNull?.where((t) => !t.completed).length ?? 0}개',
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
    final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
    final previewTodos = todos.take(3).toList();

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),

        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: Row(
            children: [
              _buildSectionTitle('오늘의 할 일'),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final result = await showTodoAddBottomSheet(context: context);
                  if (result != null && mounted) {
                    ref
                        .read(todoListNotifierProvider.notifier)
                        .addTodo(
                          title: result['title'] as String,
                          categoryId: result['categoryId'] as String?,
                        );
                  }
                },
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s16),

        if (previewTodos.isEmpty)
          Padding(
            padding: AppPadding.horizontal20,
            child: _buildEmptyTodoCard(),
          )
        else
          ...previewTodos.map((todo) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
              child: Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: AppPadding.horizontal20,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: AppRadius.large,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 24.w,
                  ),
                ),
                onDismissed: (_) {
                  ref
                      .read(todoListNotifierProvider.notifier)
                      .deleteTodo(todo.id);
                },
                child: TodoItem(
                  title: todo.title,
                  subtitle:
                      todo.actualMinutes != null && todo.actualMinutes! > 0
                      ? '${todo.actualMinutes}분 공부'
                      : null,
                  isCompleted: todo.completed,
                  onToggle: () {
                    ref
                        .read(todoListNotifierProvider.notifier)
                        .toggleTodo(todo);
                  },
                ),
              ),
            );
          }),

        // "더보기" 버튼 (할일 유무와 관계없이 항상 표시)
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
                SizedBox(width: AppSpacing.s4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.w,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSpacing.s40),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
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
