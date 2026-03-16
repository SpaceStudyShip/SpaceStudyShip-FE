import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

class CategoryAddBottomSheet extends StatefulWidget {
  const CategoryAddBottomSheet({
    super.key,
    this.initialCategory,
    required this.bottomPadding,
  });

  final ({String id, String name, String? iconId})? initialCategory;
  final double bottomPadding;

  @override
  State<CategoryAddBottomSheet> createState() => _CategoryAddBottomSheetState();
}

class _CategoryAddBottomSheetState extends State<CategoryAddBottomSheet> {
  final _nameController = TextEditingController();
  String _selectedIconId = CategoryIcons.defaultIconId;

  bool get _isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _nameController.text = widget.initialCategory!.name;
      _selectedIconId =
          widget.initialCategory!.iconId ?? CategoryIcons.defaultIconId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop({
      if (_isEditMode) 'id': widget.initialCategory!.id,
      'name': name,
      'iconId': _selectedIconId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
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
                    _isEditMode ? '카테고리 수정' : '카테고리 추가',
                    style: AppTextStyles.subHeading_18.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 이름 입력 필드
              Padding(
                padding: AppPadding.horizontal20,
                child: AppTextField(
                  controller: _nameController,
                  hintText: '카테고리 이름 (예: 수학, 영어)',
                  onSubmitted: (_) => _submit(),
                  showBorder: false,
                  autofocus: true,
                ),
              ),
              SizedBox(height: AppSpacing.s16),

              // 아이콘 선택
              Padding(
                padding: AppPadding.horizontal20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '아이콘 선택',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s16),
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppPadding.horizontal20,
                  itemCount: CategoryIcons.presets.length,
                  itemBuilder: (context, index) {
                    final iconId = CategoryIcons.presets[index];
                    final isSelected = iconId == _selectedIconId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconId = iconId),
                      child: Container(
                        width: 44.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: AppRadius.medium,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.spaceDivider,
                          ),
                        ),
                        child: Center(
                          child: CategoryIcons.buildIcon(iconId, size: 28.w),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.s20),

              // 추가 버튼
              Padding(
                padding: AppPadding.horizontal20,
                child: ListenableBuilder(
                  listenable: _nameController,
                  builder: (context, _) => AppButton(
                    text: _isEditMode ? '수정하기' : '추가하기',
                    onPressed: _nameController.text.trim().isEmpty
                        ? null
                        : _submit,
                    width: double.infinity,
                  ),
                ),
              ),

              SizedBox(height: widget.bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카테고리 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showCategoryAddBottomSheet({
  required BuildContext context,
  ({String id, String name, String? iconId})? initialCategory,
}) {
  return showAppBottomSheet<Map<String, dynamic>>(
    context: context,
    builder: (context, bottomPadding) => CategoryAddBottomSheet(
      initialCategory: initialCategory,
      bottomPadding: bottomPadding,
    ),
  );
}
