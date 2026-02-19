import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// 바텀시트 드래그 핸들
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
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
}
