import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../providers/todo_provider.dart';

class TodoAddBottomSheet extends ConsumerStatefulWidget {
  const TodoAddBottomSheet({
    super.key,
    this.initialCategoryId,
    this.initialScheduledDate,
  });

  final String? initialCategoryId;
  final DateTime? initialScheduledDate;

  @override
  ConsumerState<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}

class _TodoAddBottomSheetState extends ConsumerState<TodoAddBottomSheet> {
  final _titleController = TextEditingController();
  String? _selectedCategoryId;
  DateTime? _selectedScheduledDate;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _selectedScheduledDate = widget.initialScheduledDate ?? DateTime.now();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop({
      'title': title,
      'categoryId': _selectedCategoryId,
      'scheduledDate': _selectedScheduledDate,
    });
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedScheduledDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.spaceSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedScheduledDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                  '할 일 추가',
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 제목 입력 필드
            Padding(
              padding: AppPadding.horizontal20,
              child: AppTextField(
                controller: _titleController,
                hintText: '할 일을 입력하세요',
                onSubmitted: (_) => _submit(),
                autofocus: true,
              ),
            ),
            SizedBox(height: AppSpacing.s16),

            // 카테고리 칩 선택
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppPadding.horizontal20,
                      child: Text(
                        '카테고리',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s8),
                    SizedBox(
                      height: 36.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: AppPadding.horizontal20,
                        children: [
                          // 미분류 칩
                          _CategoryChip(
                            label: '미분류',
                            isSelected: _selectedCategoryId == null,
                            onTap: () =>
                                setState(() => _selectedCategoryId = null),
                          ),
                          SizedBox(width: AppSpacing.s8),
                          // 카테고리 칩들
                          ...categories.map(
                            (cat) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _CategoryChip(
                                label: '${cat.emoji ?? "📁"} ${cat.name}',
                                isSelected: _selectedCategoryId == cat.id,
                                onTap: () => setState(
                                  () => _selectedCategoryId = cat.id,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            SizedBox(height: AppSpacing.s16),

            // 날짜 선택 칩
            Padding(
              padding: AppPadding.horizontal20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예정일',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.chip,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14.w,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: AppSpacing.s4),
                              Text(
                                _selectedScheduledDate != null
                                    ? DateFormat('M/d (E)', 'ko_KR')
                                        .format(_selectedScheduledDate!)
                                    : '날짜 미지정',
                                style: AppTextStyles.tag_12.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      if (_selectedScheduledDate != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedScheduledDate = null),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.chip,
                              border:
                                  Border.all(color: AppColors.spaceDivider),
                            ),
                            child: Text(
                              '미지정',
                              style: AppTextStyles.tag_12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s16),

            // 추가 버튼
            Padding(
              padding: AppPadding.horizontal20,
              child: AppButton(
                text: '추가하기',
                onPressed: _titleController.text.trim().isEmpty
                    ? null
                    : _submit,
                width: double.infinity,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.tag_12.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 할일 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  String? initialCategoryId,
  DateTime? initialScheduledDate,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TodoAddBottomSheet(
      initialCategoryId: initialCategoryId,
      initialScheduledDate: initialScheduledDate,
    ),
  );
}
