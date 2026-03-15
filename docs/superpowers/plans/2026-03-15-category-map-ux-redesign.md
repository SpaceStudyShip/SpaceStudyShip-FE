# 카테고리 맵 UX 재설계 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 카테고리 2열 그리드를 InteractiveViewer 기반 우주 맵 캔버스로 교체하고, 카테고리 상세를 바텀시트로 전환한다.

**Architecture:** Clean 3-Layer (Presentation → Domain ← Data) + Riverpod. Entity/Model에 position 필드 추가 후 Freezed 재생성. 새 화면(CategoryMapScreen)이 기존 TodoListScreen을 대체하며, CategoryTodoScreen은 DraggableScrollableSheet 바텀시트로 대체된다.

**Tech Stack:** Flutter 3.9+, Riverpod 2.6, Freezed 2.5, flutter_svg, flutter_screenutil

**Spec:** `docs/superpowers/specs/2026-03-15-category-map-ux-redesign.md`

---

## Chunk 1: 데이터 모델 & Provider 변경

### Task 1: Entity에 position 필드 추가

**Files:**
- Modify: `lib/features/todo/domain/entities/todo_category_entity.dart`

- [ ] **Step 1: Entity에 positionX/Y 필드 추가**

```dart
@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,
    String? iconId,
    double? positionX,
    double? positionY,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoCategoryEntity;
}
```

`positionX`와 `positionY`를 `iconId` 아래에 추가. 둘 다 nullable — null이면 자동 배치 알고리즘 적용.

- [ ] **Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: 이 시점에서는 Model의 toEntity/toModel 불일치로 에러 발생 가능 — Task 2에서 해결.

---

### Task 2: Model에 position 필드 추가 + toEntity/toModel 업데이트

**Files:**
- Modify: `lib/features/todo/data/models/todo_category_model.dart`

- [ ] **Step 1: Model에 positionX/Y 필드 추가**

```dart
@freezed
class TodoCategoryModel with _$TodoCategoryModel {
  const factory TodoCategoryModel({
    required String id,
    required String name,
    @JsonKey(name: 'icon_id') String? iconId,
    @JsonKey(name: 'position_x') double? positionX,
    @JsonKey(name: 'position_y') double? positionY,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TodoCategoryModelFromJson(json);
}
```

- [ ] **Step 2: toEntity/toModel 확장에 position 필드 추가**

```dart
extension TodoCategoryModelX on TodoCategoryModel {
  TodoCategoryEntity toEntity() => TodoCategoryEntity(
    id: id,
    name: name,
    iconId: iconId,
    positionX: positionX,
    positionY: positionY,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TodoCategoryEntityToModelX on TodoCategoryEntity {
  TodoCategoryModel toModel() => TodoCategoryModel(
    id: id,
    name: name,
    iconId: iconId,
    positionX: positionX,
    positionY: positionY,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

- [ ] **Step 3: Freezed/json_serializable 코드 재생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `.freezed.dart`와 `.g.dart` 파일 재생성 성공.

- [ ] **Step 4: flutter analyze 통과 확인**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 5: 커밋**

```bash
git add lib/features/todo/domain/entities/todo_category_entity.dart \
  lib/features/todo/domain/entities/todo_category_entity.freezed.dart \
  lib/features/todo/data/models/todo_category_model.dart \
  lib/features/todo/data/models/todo_category_model.freezed.dart \
  lib/features/todo/data/models/todo_category_model.g.dart
git commit -m "feat : TodoCategoryEntity/Model에 positionX/Y 필드 추가 #56"
```

---

### Task 3: Provider에 updateCategoryPosition + 맵 UI 상태 추가

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

- [ ] **Step 1: CategoryListNotifier에 updateCategoryPosition 메서드 추가**

`updateCategory` 메서드 아래에 추가:

```dart
Future<void> updateCategoryPosition(String id, double x, double y) async {
  final categories = state.valueOrNull ?? [];
  final target = categories.where((c) => c.id == id).firstOrNull;
  if (target == null) return;
  await updateCategory(target.copyWith(positionX: x, positionY: y));
}
```

기존 `updateCategory`에 위임하므로 optimistic update + rollback이 자동 적용됨.

- [ ] **Step 2: 맵 UI 상태 Provider 추가**

파일 하단(기존 `todoCompletionStatsForDate` 아래)에 추가:

```dart
// === 카테고리 맵 UI 상태 ===

/// 드래그 모드 중인 행성 ID (null = 일반 모드)
final draggingPlanetIdProvider = StateProvider<String?>((ref) => null);

/// 바텀시트에서 열린 카테고리 ID (null = 닫힘, '' = 미분류)
final openCategoryIdProvider = StateProvider<String?>((ref) => null);
```

- [ ] **Step 3: flutter analyze 통과 확인**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart \
  lib/features/todo/presentation/providers/todo_provider.g.dart
git commit -m "feat : 카테고리 위치 업데이트 및 맵 UI 상태 Provider 추가 #56"
```

---

## Chunk 2: 위젯 구현

### Task 4: PlanetMapNode 위젯

**Files:**
- Create: `lib/features/todo/presentation/widgets/planet_map_node.dart`

- [ ] **Step 1: 행성 노드 위젯 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

/// 줌 티어 — 캔버스 확대 수준에 따라 노드 정보 표시 범위 결정
enum ZoomTier { far, normal, close }

/// 카테고리 맵 캔버스 위의 행성 노드
///
/// [zoomTier]에 따라 표시 정보가 달라짐:
/// - far: 아이콘만
/// - normal: 아이콘 + 이름
/// - close: 아이콘 + 이름 + 진행률
class PlanetMapNode extends StatefulWidget {
  const PlanetMapNode({
    super.key,
    required this.categoryId,
    required this.name,
    this.iconId,
    required this.todoCount,
    required this.completedCount,
    required this.zoomTier,
    required this.onTap,
    required this.onLongPress,
    this.isDragging = false,
  });

  final String categoryId;
  final String name;
  final String? iconId;
  final int todoCount;
  final int completedCount;
  final ZoomTier zoomTier;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails) onLongPress;
  final bool isDragging;

  @override
  State<PlanetMapNode> createState() => _PlanetMapNodeState();
}

class _PlanetMapNodeState extends State<PlanetMapNode> {
  bool _isPressed = false;

  /// 할일 수에 따른 행성 크기: 48.w ~ 80.w
  double get _planetSize {
    final base = 48.w;
    final scaled = base + (widget.todoCount * 4.w);
    return scaled.clamp(base, 80.w);
  }

  @override
  Widget build(BuildContext context) {
    final showName = widget.zoomTier != ZoomTier.far;
    final showProgress = widget.zoomTier == ZoomTier.close;

    return Semantics(
      label: '${widget.name} 카테고리, 할일 ${widget.todoCount}개',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPressStart: widget.onLongPress,
        child: AnimatedScale(
          scale: widget.isDragging
              ? 1.1
              : _isPressed
                  ? TossDesignTokens.cardTapScale
                  : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 중 그림자
              if (widget.isDragging)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CategoryIcons.buildIcon(
                    widget.iconId,
                    size: _planetSize,
                  ),
                )
              else
                CategoryIcons.buildIcon(widget.iconId, size: _planetSize),

              // 이름 (normal/close 줌 티어)
              AnimatedOpacity(
                opacity: showName ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    widget.name,
                    style: AppTextStyles.tag_12.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 진행률 (close 줌 티어만)
              AnimatedOpacity(
                opacity: showProgress ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Text(
                  '${widget.completedCount}/${widget.todoCount} 완료',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: flutter analyze 통과 확인**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/todo/presentation/widgets/planet_map_node.dart
git commit -m "feat : PlanetMapNode 위젯 구현 #56"
```

---

### Task 5: SpaceStationNode 위젯

**Files:**
- Create: `lib/features/todo/presentation/widgets/space_station_node.dart`

- [ ] **Step 1: 우주 정거장 노드 위젯 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import 'planet_map_node.dart'; // ZoomTier import

/// 캔버스 중앙의 우주 정거장 (미분류 할일 허브)
class SpaceStationNode extends StatefulWidget {
  const SpaceStationNode({
    super.key,
    required this.uncategorizedCount,
    required this.zoomTier,
    required this.onTap,
  });

  final int uncategorizedCount;
  final ZoomTier zoomTier;
  final VoidCallback onTap;

  @override
  State<SpaceStationNode> createState() => _SpaceStationNodeState();
}

class _SpaceStationNodeState extends State<SpaceStationNode> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final showLabel = widget.zoomTier != ZoomTier.far;
    final showCount = widget.zoomTier == ZoomTier.close;

    return Semantics(
      label: '미분류 할일 ${widget.uncategorizedCount}개',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.spaceSurface,
                  border: Border.all(
                    color: AppColors.spaceDivider,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.space_dashboard_rounded,
                  size: 32.w,
                  color: AppColors.textSecondary,
                ),
              ),

              // 라벨
              AnimatedOpacity(
                opacity: showLabel ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    '미분류',
                    style: AppTextStyles.tag_12.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 개수
              AnimatedOpacity(
                opacity: showCount ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Text(
                  '${widget.uncategorizedCount}개',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: flutter analyze 통과 + 커밋**

```bash
flutter analyze
git add lib/features/todo/presentation/widgets/space_station_node.dart
git commit -m "feat : SpaceStationNode 위젯 구현 #56"
```

---

### Task 6: PlanetContextMenu (롱프레스 컨텍스트 메뉴)

**Files:**
- Create: `lib/features/todo/presentation/widgets/planet_context_menu.dart`

- [ ] **Step 1: 컨텍스트 메뉴 헬퍼 함수 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 행성 롱프레스 시 표시되는 컨텍스트 메뉴 결과
enum PlanetMenuAction { edit, move, delete }

/// 행성 롱프레스 컨텍스트 메뉴 표시
///
/// [position]은 LongPressStartDetails.globalPosition에서 가져옴.
/// 반환: 선택된 액션 또는 null(취소)
Future<PlanetMenuAction?> showPlanetContextMenu({
  required BuildContext context,
  required Offset position,
}) {
  return showMenu<PlanetMenuAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    color: AppColors.spaceSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
      side: BorderSide(color: AppColors.spaceDivider),
    ),
    items: [
      PopupMenuItem(
        value: PlanetMenuAction.edit,
        child: Row(
          children: [
            Icon(Icons.edit_rounded, size: 18.w, color: Colors.white),
            SizedBox(width: 8.w),
            Text('수정', style: AppTextStyles.label_16.copyWith(color: Colors.white)),
          ],
        ),
      ),
      PopupMenuItem(
        value: PlanetMenuAction.move,
        child: Row(
          children: [
            Icon(Icons.open_with_rounded, size: 18.w, color: Colors.white),
            SizedBox(width: 8.w),
            Text('위치 이동', style: AppTextStyles.label_16.copyWith(color: Colors.white)),
          ],
        ),
      ),
      PopupMenuItem(
        value: PlanetMenuAction.delete,
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18.w, color: AppColors.error),
            SizedBox(width: 8.w),
            Text('삭제', style: AppTextStyles.label_16.copyWith(color: AppColors.error)),
          ],
        ),
      ),
    ],
  );
}
```

- [ ] **Step 2: flutter analyze 통과 + 커밋**

```bash
flutter analyze
git add lib/features/todo/presentation/widgets/planet_context_menu.dart
git commit -m "feat : PlanetContextMenu 헬퍼 구현 #56"
```

---

### Task 7: CategoryTodoBottomSheet (할일 바텀시트)

**Files:**
- Create: `lib/features/todo/presentation/widgets/category_todo_bottom_sheet.dart`

이 위젯은 기존 `CategoryTodoScreen`의 기능을 `DraggableScrollableSheet` 바텀시트로 재구현한다. 기존 `DismissibleTodoItem`을 재사용.

- [ ] **Step 1: 바텀시트 위젯 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../providers/todo_provider.dart';
import 'dismissible_todo_item.dart';
import 'todo_add_bottom_sheet.dart';

/// 카테고리 할일 바텀시트
///
/// 캔버스에서 행성/정거장 탭 시 표시.
/// [categoryId]가 null이면 미분류 할일 표시.
class CategoryTodoBottomSheet extends ConsumerWidget {
  const CategoryTodoBottomSheet({
    super.key,
    this.categoryId,
    this.categoryName = '미분류',
    this.categoryIconId,
  });

  final String? categoryId;
  final String categoryName;
  final String? categoryIconId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosForCategoryProvider(categoryId));
    final stats = ref.watch(categoryTodoStatsProvider(categoryId));

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.4, 0.7, 0.9],
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.modal,
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // 드래그 핸들
              const SliverToBoxAdapter(child: DragHandle()),

              // 헤더: 아이콘 + 이름 + 진행률
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppPadding.horizontal20,
                  child: Row(
                    children: [
                      if (categoryId != null)
                        CategoryIcons.buildIcon(categoryIconId, size: 24.w)
                      else
                        Icon(
                          Icons.space_dashboard_rounded,
                          size: 24.w,
                          color: AppColors.textSecondary,
                        ),
                      SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: AppTextStyles.subHeading_18.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${stats.completedCount}/${stats.todoCount} 완료',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

              // 할 일 추가 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppPadding.horizontal20,
                  child: AppButton(
                    text: '+ 할 일 추가',
                    onPressed: () async {
                      final result = await showTodoAddBottomSheet(
                        context: context,
                        initialCategoryIds:
                            categoryId != null ? [categoryId!] : null,
                      );
                      if (result != null && context.mounted) {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .addTodo(
                              title: result['title'] as String,
                              categoryIds:
                                  (result['categoryIds'] as List<String>?) ??
                                      [],
                              scheduledDates:
                                  result['scheduledDates'] as List<DateTime>?,
                            );
                      }
                    },
                    width: double.infinity,
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.textSecondary,
                    borderColor: AppColors.spaceDivider,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

              // 할일 목록
              if (todos.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s40),
                    child: const SpaceEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: '할 일이 없어요',
                      subtitle: '위 버튼으로 추가해보세요',
                      iconSize: 32,
                      animated: false,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: AppPadding.horizontal20,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final todo = todos[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: DismissibleTodoItem(todo: todo),
                        );
                      },
                      childCount: todos.length,
                    ),
                  ),
                ),

              // 하단 여백
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.s32),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: flutter analyze 통과 + 커밋**

```bash
flutter analyze
git add lib/features/todo/presentation/widgets/category_todo_bottom_sheet.dart
git commit -m "feat : CategoryTodoBottomSheet 바텀시트 위젯 구현 #56"
```

---

## Chunk 3: 메인 화면 & 라우트 연결

### Task 8: CategoryMapScreen (캔버스 메인 화면)

**Files:**
- Create: `lib/features/todo/presentation/screens/category_map_screen.dart`

이 파일이 가장 복잡한 위젯. `InteractiveViewer` + `TransformationController` + 줌 티어 + 자동 배치 알고리즘 + 드래그 모드를 모두 포함.

- [ ] **Step 1: 자동 배치 알고리즘 유틸 함수 작성**

파일 하단에 private 함수로:

```dart
/// 나선형 자동 배치 알고리즘
///
/// 중앙 (0.5, 0.5)을 기준으로 카테고리를 나선형으로 배치.
/// 첫 번째 고리: 반지름 0.15, 최대 6개
/// 두 번째 고리: 반지름 0.30, 최대 12개
Map<String, Offset> _computeAutoPositions(
  List<TodoCategoryEntity> categories,
) {
  final positions = <String, Offset>{};
  final needsPlacement = categories
      .where((c) => c.positionX == null || c.positionY == null)
      .toList();
  final hasPosition = categories
      .where((c) => c.positionX != null && c.positionY != null);

  // 기존 위치가 있는 카테고리는 그대로
  for (final cat in hasPosition) {
    positions[cat.id] = Offset(cat.positionX!, cat.positionY!);
  }

  // 자동 배치가 필요한 카테고리
  const center = Offset(0.5, 0.5);
  const rings = [
    (radius: 0.15, maxCount: 6),
    (radius: 0.30, maxCount: 12),
  ];

  var placementIndex = 0;
  for (final cat in needsPlacement) {
    // 어느 고리에 배치할지 결정
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
    final angle = (2 * 3.14159265 * indexInRing) / ring.maxCount;
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
```

- [ ] **Step 2: CategoryMapScreen 본체 작성**

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
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
        title: Text(
          '내 행성계',
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _addCategory(context),
            icon: Icon(Icons.add_rounded, size: 24.w),
          ),
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
              return _buildCanvas(categories);
            },
            loading: () => const Center(child: AppLoading()),
            error: (_, __) => Center(
              child: Text(
                '데이터를 불러오지 못했어요',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(List<TodoCategoryEntity> categories) {
    final canvasSize = _canvasSize(categories.length);
    final positions = _computeAutoPositions(categories);

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
                  final pos = positions[cat.id] ??
                      const Offset(0.5, 0.5);
                  final isDragging = _draggingId == cat.id;
                  final effectivePos = isDragging && _dragLocalPosition != null
                      ? _dragLocalPosition!
                      : Offset(
                          pos.dx * canvasSize,
                          pos.dy * canvasSize,
                        );

                  return Positioned(
                    left: effectivePos.dx - 40.w,
                    top: effectivePos.dy - 40.w,
                    child: isDragging
                        ? GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _dragLocalPosition = Offset(
                                  (_dragLocalPosition?.dx ?? effectivePos.dx) +
                                      details.delta.dx,
                                  (_dragLocalPosition?.dy ?? effectivePos.dy) +
                                      details.delta.dy,
                                );
                              });
                            },
                            onPanEnd: (_) => _endDrag(cat.id, canvasSize),
                            child: _buildPlanetNode(
                              cat, zoomTier, isDragging,
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
              _showContextMenu(context, cat, details.globalPosition),
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

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.barrier,
      isScrollControlled: true,
      builder: (_) => CategoryTodoBottomSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIconId: categoryIconId,
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isBottomSheetOpen = false);
    });
  }

  Future<void> _showContextMenu(
    BuildContext context,
    TodoCategoryEntity cat,
    Offset position,
  ) async {
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

    ref.read(categoryListNotifierProvider.notifier).updateCategoryPosition(
      catId,
      normalizedX,
      normalizedY,
    );

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
      ref.read(categoryListNotifierProvider.notifier).updateCategory(
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
      emotion: AppDialogEmotion.warning,
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      ref.read(categoryListNotifierProvider.notifier).deleteCategory(cat.id);
    }
  }

  Future<void> _addCategory(BuildContext context) async {
    // 카테고리 최대 20개 제한
    final categories =
        ref.read(categoryListNotifierProvider).valueOrNull ?? [];
    if (categories.length >= 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리는 최대 20개까지 추가할 수 있어요')),
        );
      }
      return;
    }

    final result = await showCategoryAddBottomSheet(context: context);
    if (result != null && mounted) {
      ref.read(categoryListNotifierProvider.notifier).addCategory(
        name: result['name'] as String,
        iconId: result['iconId'] as String?,
      );
    }
  }
}
```

참고: `dart:math`의 `cos`, `sin`을 `_computeAutoPositions`에서 사용하므로 상단 import 필요.

- [ ] **Step 3: flutter analyze 통과 + 커밋**

```bash
flutter analyze
git add lib/features/todo/presentation/screens/category_map_screen.dart
git commit -m "feat : CategoryMapScreen 캔버스 메인 화면 구현 #56"
```

---

### Task 9: 라우트 변경 + 기존 파일 정리

**Files:**
- Modify: `lib/routes/app_router.dart`
- Modify: `lib/routes/route_paths.dart`
- Delete: `lib/features/todo/presentation/screens/todo_list_screen.dart`
- Delete: `lib/features/todo/presentation/screens/category_todo_screen.dart`
- Delete: `lib/features/todo/presentation/widgets/category_card.dart`

- [ ] **Step 1: RoutePaths에서 categoryTodo 경로 제거**

`lib/routes/route_paths.dart`에서 다음 삭제:

```dart
// 삭제할 라인:
static const categoryTodo = '/home/todo/category/:categoryId';
static String categoryTodoPath(String categoryId) =>
    '/home/todo/category/$categoryId';
```

- [ ] **Step 2: app_router.dart 수정**

import 변경:
- 삭제: `todo_list_screen.dart`, `category_todo_screen.dart` import
- 추가: `category_map_screen.dart` import

라우트 변경: `/home/todo` GoRoute의 builder를 `CategoryMapScreen`으로 교체하고, `category/:categoryId` 하위 라우트 제거.

```dart
// 변경 전:
GoRoute(
  path: 'todo',
  name: 'todoList',
  builder: (context, state) => const TodoListScreen(),
  routes: [
    GoRoute(
      path: 'category/:categoryId',
      name: 'categoryTodo',
      builder: (context, state) { ... },
    ),
  ],
),

// 변경 후:
GoRoute(
  path: 'todo',
  name: 'todoList',
  builder: (context, state) => const CategoryMapScreen(),
),
```

`todo/:id` (todoDetail) 라우트도 유지하되 `category/:categoryId` 블록 전체 제거.

- [ ] **Step 3: 기존 파일 삭제**

```bash
git rm lib/features/todo/presentation/screens/todo_list_screen.dart
git rm lib/features/todo/presentation/screens/category_todo_screen.dart
git rm lib/features/todo/presentation/widgets/category_card.dart
```

- [ ] **Step 4: 삭제된 파일 import 참조 확인**

Run: `grep -r "todo_list_screen\|category_todo_screen\|category_card\|categoryTodoPath" lib/ --include="*.dart"`

모든 참조가 제거되었는지 확인. 남아있으면 수정.

- [ ] **Step 5: flutter analyze 통과 확인**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor : CategoryMapScreen으로 라우트 교체 및 기존 화면/위젯 삭제 #56"
```

---

## Chunk 4: 검증 & 마무리

### Task 10: 전체 통합 검증

- [ ] **Step 1: flutter analyze 최종 확인**

```bash
flutter analyze
```

- [ ] **Step 2: 기능 확인 체크리스트**

기기 또는 시뮬레이터에서 확인:

1. 홈 탭 → 할일 목록 진입 → 캔버스 맵 표시
2. 핀치 줌 인/아웃 동작 확인
3. 줌 레벨별 정보 표시 (아이콘만 → +이름 → +진행률)
4. 우주 정거장(중앙) 탭 → 미분류 할일 바텀시트
5. 행성 탭 → 카테고리 할일 바텀시트
6. 행성 롱프레스 → 컨텍스트 메뉴 (수정/위치이동/삭제)
7. 위치 이동 → 드래그 → 좌표 저장 확인
8. 카테고리 추가 시 자동 배치
9. 바텀시트 열린 상태에서 캔버스 터치 비활성화 확인

- [ ] **Step 3: 최종 커밋 (필요 시)**

잔여 수정사항이 있으면 커밋.
