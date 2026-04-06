import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_add_bottom_sheet.dart';
import '../widgets/category_todo_bottom_sheet.dart';
import '../widgets/planet_context_menu.dart';
import '../widgets/planet_map_node.dart';
import '../widgets/space_station_node.dart';

class CategoryMapScreen extends ConsumerStatefulWidget {
  const CategoryMapScreen({super.key});

  @override
  ConsumerState<CategoryMapScreen> createState() => _CategoryMapScreenState();
}

class _CategoryMapScreenState extends ConsumerState<CategoryMapScreen> {
  final _transformationController = TransformationController();
  final _zoomTierNotifier = ValueNotifier<ZoomTier>(ZoomTier.normal);

  // 드래그 모드 로컬 상태
  String? _draggingId;
  Offset? _dragLocalPosition;

  bool _isBottomSheetOpen = false;
  bool _initialCentered = false;
  bool _isListView = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _zoomTierNotifier.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final ZoomTier newTier;
    if (scale < 1.0) {
      newTier = ZoomTier.far;
    } else if (scale <= 1.5) {
      newTier = ZoomTier.normal;
    } else {
      newTier = ZoomTier.close;
    }
    if (_zoomTierNotifier.value != newTier) {
      _zoomTierNotifier.value = newTier;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);
    final todosHasValue = ref.watch(
      todoListNotifierProvider.select((s) => s.hasValue),
    );

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: AppSpacing.s48,
              minHeight: AppSpacing.s48,
            ),
            onPressed: () => setState(() => _isListView = !_isListView),
            icon: _isListView
                ? Icon(Icons.grid_view_rounded, size: AppSpacing.s32)
                : AppIcons.menu(size: AppSpacing.s40),
          ),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: AppSpacing.s48,
              minHeight: AppSpacing.s48,
            ),
            onPressed: () => _addCategory(context),
            icon: AppIcons.plus(size: AppSpacing.s40),
          ),
          SizedBox(width: AppSpacing.s4),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          categoriesAsync.when(
            data: (categories) {
              if (!todosHasValue) {
                return const Center(child: AppLoading());
              }
              return _isListView
                  ? _buildListView(categories)
                  : _buildCanvas(categories);
            },
            loading: () => const Center(child: AppLoading()),
            error: (_, _) => Center(
              child: Text(
                '데이터를 불러오지 못했어요',
                style: AppTextStyles.label_16.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<TodoCategoryEntity> categories) {
    return SafeArea(
      child: ListView(
        padding: AppPadding.horizontal20.copyWith(top: AppSpacing.s8),
        children: [
          // 미분류 할일
          Consumer(
            builder: (context, ref, _) {
              final stats = ref.watch(categoryTodoStatsProvider(null));
              return _CategoryListTile(
                icon: Icon(
                  Icons.space_dashboard_rounded,
                  size: 32.w,
                  color: AppColors.textSecondary,
                ),
                name: '미분류',
                todoCount: stats.todoCount,
                completedCount: stats.completedCount,
                onTap: () => _openBottomSheet(
                  context,
                  categoryId: null,
                  categoryName: '미분류',
                ),
              );
            },
          ),
          if (categories.isNotEmpty)
            Divider(color: AppColors.spaceDivider, height: 1),
          // 카테고리 목록
          ...categories.map((cat) {
            return Consumer(
              builder: (context, ref, _) {
                final stats = ref.watch(categoryTodoStatsProvider(cat.id));
                return _CategoryListTile(
                  icon: CategoryIcons.buildIcon(cat.iconId, size: 32.w),
                  name: cat.name,
                  todoCount: stats.todoCount,
                  completedCount: stats.completedCount,
                  onTap: () => _openBottomSheet(
                    context,
                    categoryId: cat.id,
                    categoryName: cat.name,
                    categoryIconId: cat.iconId,
                  ),
                  onLongPressStart: (details) =>
                      _showContextMenu(cat, details.globalPosition),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCanvas(List<TodoCategoryEntity> categories) {
    final canvasSize = _canvasSize(categories.length);
    final positions = _computeAutoPositions(categories);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 초기 로드 시 캔버스 중앙이 화면 중앙에 오도록 오프셋 설정
        if (!_initialCentered) {
          _initialCentered = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final viewportW = constraints.maxWidth;
            final viewportH = constraints.maxHeight;
            final offsetX = -(canvasSize / 2 - viewportW / 2);
            final offsetY = -(canvasSize / 2 - viewportH / 2);
            _transformationController.value = Matrix4.identity()
              ..setTranslationRaw(offsetX, offsetY, 0);
          });
        }

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 3.0,
          panEnabled: _draggingId == null && !_isBottomSheetOpen,
          scaleEnabled: !_isBottomSheetOpen,
          constrained: false,
          boundaryMargin: EdgeInsets.all(canvasSize * 0.2),
          child: SizedBox(
            width: canvasSize,
            height: canvasSize,
            child: ValueListenableBuilder<ZoomTier>(
              valueListenable: _zoomTierNotifier,
              builder: (context, zoomTier, _) {
                return Stack(
                  children: [
                    // 우주 정거장 (중앙)
                    Positioned(
                      left: canvasSize * 0.5 - 32.w,
                      top: canvasSize * 0.5 - 32.w,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final stats = ref.watch(
                            categoryTodoStatsProvider(null),
                          );
                          return SpaceStationNode(
                            uncategorizedCount: stats.todoCount,
                            zoomTier: zoomTier,
                            onTap: () => _openBottomSheet(
                              context,
                              categoryId: null,
                              categoryName: '미분류',
                            ),
                          );
                        },
                      ),
                    ),

                    // 행성 노드들
                    ...categories.map((cat) {
                      final pos = positions[cat.id] ?? const Offset(0.5, 0.5);
                      final isDragging = _draggingId == cat.id;
                      final effectivePos =
                          isDragging && _dragLocalPosition != null
                          ? _dragLocalPosition!
                          : Offset(pos.dx * canvasSize, pos.dy * canvasSize);

                      return Positioned(
                        left: effectivePos.dx - 40.w,
                        top: effectivePos.dy - 40.w,
                        child: isDragging
                            ? GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _dragLocalPosition = Offset(
                                      (_dragLocalPosition?.dx ??
                                              effectivePos.dx) +
                                          details.delta.dx,
                                      (_dragLocalPosition?.dy ??
                                              effectivePos.dy) +
                                          details.delta.dy,
                                    );
                                  });
                                },
                                onPanEnd: (_) => _endDrag(cat.id, canvasSize),
                                child: _buildPlanetNode(
                                  cat,
                                  zoomTier,
                                  isDragging,
                                ),
                              )
                            : _buildPlanetNode(cat, zoomTier, isDragging),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanetNode(
    TodoCategoryEntity cat,
    ZoomTier zoomTier,
    bool isDragging,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final stats = ref.watch(categoryTodoStatsProvider(cat.id));
        return PlanetMapNode(
          categoryId: cat.id,
          name: cat.name,
          iconId: cat.iconId,
          todoCount: stats.todoCount,
          completedCount: stats.completedCount,
          zoomTier: zoomTier,
          isDragging: isDragging,
          onTap: () => _openBottomSheet(
            context,
            categoryId: cat.id,
            categoryName: cat.name,
            categoryIconId: cat.iconId,
          ),
          onLongPress: (details) =>
              _showContextMenu(cat, details.globalPosition),
        );
      },
    );
  }

  void _openBottomSheet(
    BuildContext context, {
    String? categoryId,
    required String categoryName,
    String? categoryIconId,
  }) {
    setState(() => _isBottomSheetOpen = true);

    showAppBottomSheet<void>(
      context: context,
      builder: (_, bottomPadding) => CategoryTodoBottomSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIconId: categoryIconId,
        bottomPadding: bottomPadding,
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isBottomSheetOpen = false);
    });
  }

  Future<void> _showContextMenu(TodoCategoryEntity cat, Offset position) async {
    final action = await showPlanetContextMenu(
      context: context,
      position: position,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case PlanetMenuAction.edit:
        _editCategory(context, cat);
      case PlanetMenuAction.move:
        _startDrag(cat);
      case PlanetMenuAction.delete:
        _deleteCategory(context, cat);
    }
  }

  void _startDrag(TodoCategoryEntity cat) {
    final canvasSize = _canvasSize(
      ref.read(categoryListNotifierProvider).valueOrNull?.length ?? 0,
    );
    setState(() {
      _draggingId = cat.id;
      _dragLocalPosition = Offset(
        (cat.positionX ?? 0.5) * canvasSize,
        (cat.positionY ?? 0.5) * canvasSize,
      );
    });
  }

  void _endDrag(String catId, double canvasSize) {
    if (_dragLocalPosition == null) return;
    final normalizedX = (_dragLocalPosition!.dx / canvasSize).clamp(0.05, 0.95);
    final normalizedY = (_dragLocalPosition!.dy / canvasSize).clamp(0.05, 0.95);

    ref
        .read(categoryListNotifierProvider.notifier)
        .updateCategoryPosition(catId, normalizedX, normalizedY);

    setState(() {
      _draggingId = null;
      _dragLocalPosition = null;
    });
  }

  Future<void> _editCategory(
    BuildContext context,
    TodoCategoryEntity cat,
  ) async {
    final result = await showCategoryAddBottomSheet(
      context: context,
      initialCategory: (id: cat.id, name: cat.name, iconId: cat.iconId),
    );
    if (result != null && mounted) {
      ref
          .read(categoryListNotifierProvider.notifier)
          .updateCategory(
            cat.copyWith(
              name: result['name'] as String,
              iconId: result['iconId'] as String?,
            ),
          );
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    TodoCategoryEntity cat,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '카테고리 삭제',
      message: '"${cat.name}" 카테고리를 삭제하시겠습니까?\n할일은 미분류로 이동됩니다.',
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      ref.read(categoryListNotifierProvider.notifier).deleteCategory(cat.id);
    }
  }

  Future<void> _addCategory(BuildContext context) async {
    final categories = ref.read(categoryListNotifierProvider).valueOrNull ?? [];
    if (categories.length >= 20) {
      if (mounted) {
        AppSnackBar.info(context, '카테고리는 최대 20개까지 추가할 수 있어요');
      }
      return;
    }

    final result = await showCategoryAddBottomSheet(context: context);
    if (result != null && mounted) {
      ref
          .read(categoryListNotifierProvider.notifier)
          .addCategory(
            name: result['name'] as String,
            iconId: result['iconId'] as String?,
          );
    }
  }
}

// === List View Tile ===

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.icon,
    required this.name,
    required this.todoCount,
    required this.completedCount,
    required this.onTap,
    this.onLongPressStart,
  });

  final Widget icon;
  final String name;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final progress = todoCount > 0 ? completedCount / todoCount : 0.0;

    return GestureDetector(
      onLongPressStart: onLongPressStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.large,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.s12,
              horizontal: AppSpacing.s4,
            ),
            child: Row(
              children: [
                icon,
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.label_16.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.s4),
                      Text(
                        '$completedCount/$todoCount 완료',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.s12),
                // 진행률 바
                SizedBox(
                  width: 48.w,
                  height: 4.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.spaceDivider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// === Private Utility Functions ===

/// 나선형 자동 배치 알고리즘
Map<String, Offset> _computeAutoPositions(List<TodoCategoryEntity> categories) {
  final positions = <String, Offset>{};
  final needsPlacement = categories
      .where((c) => c.positionX == null || c.positionY == null)
      .toList();
  final hasPosition = categories.where(
    (c) => c.positionX != null && c.positionY != null,
  );

  for (final cat in hasPosition) {
    positions[cat.id] = Offset(cat.positionX!, cat.positionY!);
  }

  const center = Offset(0.5, 0.5);
  const rings = [(radius: 0.15, maxCount: 6), (radius: 0.30, maxCount: 12)];

  var placementIndex = 0;
  for (final cat in needsPlacement) {
    var ringIdx = 0;
    var indexInRing = placementIndex;
    for (var i = 0; i < rings.length; i++) {
      if (indexInRing < rings[i].maxCount) {
        ringIdx = i;
        break;
      }
      indexInRing -= rings[i].maxCount;
      if (i == rings.length - 1) {
        ringIdx = i;
        indexInRing = indexInRing % rings[i].maxCount;
      }
    }

    final ring = rings[ringIdx];
    final angle = (2 * pi * indexInRing) / ring.maxCount;
    final x = center.dx + ring.radius * cos(angle);
    final y = center.dy + ring.radius * sin(angle);

    positions[cat.id] = Offset(x.clamp(0.05, 0.95), y.clamp(0.05, 0.95));
    placementIndex++;
  }

  return positions;
}

/// 카테고리 수에 따른 캔버스 크기
double _canvasSize(int categoryCount) {
  if (categoryCount <= 6) return 800;
  if (categoryCount <= 12) return 1200;
  return 1600;
}
