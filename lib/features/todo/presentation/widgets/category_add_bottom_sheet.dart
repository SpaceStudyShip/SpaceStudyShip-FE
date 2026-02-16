import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

/// 이모지 프리셋 목록
const _emojiPresets = [
  '📁',
  '📚',
  '📐',
  '🔬',
  '🎨',
  '💻',
  '🎵',
  '🏃',
  '📝',
  '🌍',
  '🧮',
  '📖',
  '✏️',
  '🔭',
  '🎯',
  '💡',
  '🧪',
  '📊',
  '🗂️',
  '⭐',
];

class CategoryAddBottomSheet extends StatefulWidget {
  const CategoryAddBottomSheet({super.key, this.initialCategory});

  final ({String id, String name, String? emoji})? initialCategory;

  @override
  State<CategoryAddBottomSheet> createState() => _CategoryAddBottomSheetState();
}

class _CategoryAddBottomSheetState extends State<CategoryAddBottomSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📁';

  bool get _isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _nameController.text = widget.initialCategory!.name;
      _selectedEmoji = widget.initialCategory!.emoji ?? '📁';
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop({'name': name, 'emoji': _selectedEmoji});
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
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // 제목
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                  autofocus: true,
                ),
              ),
              SizedBox(height: AppSpacing.s16),

              // 이모지 선택
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
              SizedBox(height: AppSpacing.s8),
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppPadding.horizontal20,
                  itemCount: _emojiPresets.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojiPresets[index];
                    final isSelected = emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
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
                          child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
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
                child: AppButton(
                  text: _isEditMode ? '수정하기' : '추가하기',
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : _submit,
                  width: double.infinity,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
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
  ({String id, String name, String? emoji})? initialCategory,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) =>
        CategoryAddBottomSheet(initialCategory: initialCategory),
  );
}
