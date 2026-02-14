import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

class TodoAddBottomSheet extends StatefulWidget {
  const TodoAddBottomSheet({super.key});

  @override
  State<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}

class _TodoAddBottomSheetState extends State<TodoAddBottomSheet> {
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    Navigator.of(context).pop({'title': title});
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
            SizedBox(height: AppSpacing.s20),

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

/// 할일 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const TodoAddBottomSheet(),
  );
}
