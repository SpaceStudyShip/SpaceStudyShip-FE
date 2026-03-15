import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../providers/todo_provider.dart';

/// 다중 카테고리 선택 바텀시트
///
/// 체크박스 방식으로 여러 카테고리를 선택/해제할 수 있습니다.
/// 아무것도 선택하지 않으면 '미분류' 상태가 됩니다.
class CategorySelectBottomSheet extends ConsumerStatefulWidget {
  const CategorySelectBottomSheet({
    super.key,
    this.currentCategoryIds = const [],
    required this.bottomPadding,
  });

  final List<String> currentCategoryIds;
  final double bottomPadding;

  @override
  ConsumerState<CategorySelectBottomSheet> createState() =>
      _CategorySelectBottomSheetState();
}

class _CategorySelectBottomSheetState
    extends ConsumerState<CategorySelectBottomSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.currentCategoryIds);
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectUncategorized() {
    setState(() => _selectedIds.clear());
  }

  void _confirm() {
    Navigator.of(context).pop(List<String>.from(_selectedIds));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          const DragHandle(),

          // 제목
          Padding(
            padding: AppPadding.bottomSheetTitlePadding,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '카테고리 선택',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 미분류 옵션
          _CategoryOption(
            iconId: null,
            name: '미분류',
            isSelected: _selectedIds.isEmpty,
            onTap: _selectUncategorized,
          ),

          // 구분선
          Padding(
            padding: AppPadding.horizontal20,
            child: Divider(color: AppColors.spaceDivider, height: 1),
          ),

          // 카테고리 목록
          categoriesAsync.when(
            data: (categories) => Column(
              children: categories.map((cat) {
                final isSelected = _selectedIds.contains(cat.id);
                return _CategoryOption(
                  iconId: cat.iconId,
                  name: cat.name,
                  isSelected: isSelected,
                  onTap: () => _toggleCategory(cat.id),
                );
              }).toList(),
            ),
            loading: () => Padding(
              padding: AppPadding.all16,
              child: const Center(child: AppLoading()),
            ),
            error: (e, st) => Padding(
              padding: AppPadding.all16,
              child: Text(
                '카테고리 목록을 불러오지 못했어요',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.error),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.s12),

          // 확인 버튼
          Padding(
            padding: AppPadding.horizontal20,
            child: AppButton(
              text: '확인',
              onPressed: _confirm,
              width: double.infinity,
            ),
          ),

          SizedBox(height: widget.bottomPadding),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.iconId,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String? iconId;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            CategoryIcons.buildIcon(iconId, size: 20.w),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
            ),
            AnimatedContainer(
              duration: TossDesignTokens.animationFast,
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.w, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 선택 바텀시트를 표시하는 헬퍼 함수
/// 반환값: 카테고리 ID 리스트 (빈 리스트 = 미분류, null = 취소)
Future<List<String>?> showCategorySelectBottomSheet({
  required BuildContext context,
  List<String> currentCategoryIds = const [],
}) {
  return showAppBottomSheet<List<String>>(
    context: context,
    builder: (context, bottomPadding) => CategorySelectBottomSheet(
      currentCategoryIds: currentCategoryIds,
      bottomPadding: bottomPadding,
    ),
  );
}
