import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/todo_provider.dart';

class CategorySelectBottomSheet extends ConsumerWidget {
  const CategorySelectBottomSheet({super.key, this.currentCategoryId});

  final String? currentCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                '카테고리 선택',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 미분류 옵션
          _CategoryOption(
            emoji: '📋',
            name: '미분류',
            isSelected: currentCategoryId == null,
            onTap: () {
              if (currentCategoryId == null) {
                Navigator.of(context).pop(); // 이미 미분류 → 닫기만
              } else {
                Navigator.of(context).pop(''); // 미분류로 이동
              }
            },
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
                final isSelected = cat.id == currentCategoryId;
                return _CategoryOption(
                  emoji: cat.emoji ?? '📁',
                  name: cat.name,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      Navigator.of(context).pop(); // 이미 같은 카테고리 → 닫기만
                    } else {
                      Navigator.of(context).pop(cat.id); // 해당 카테고리로 이동
                    }
                  },
                );
              }).toList(),
            ),
            loading: () => Padding(
              padding: AppPadding.all16,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12.h),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.emoji,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
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
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20.w, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 선택 바텀시트를 표시하는 헬퍼 함수
/// 반환값: 카테고리 ID (빈 문자열 = 미분류, null = 취소 또는 변경 없음)
Future<String?> showCategorySelectBottomSheet({
  required BuildContext context,
  String? currentCategoryId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) =>
        CategorySelectBottomSheet(currentCategoryId: currentCategoryId),
  );
}
