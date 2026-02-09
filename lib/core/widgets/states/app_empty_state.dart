import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/app_button.dart';

/// 빈 상태 타입
enum AppEmptyType {
  /// 데이터 없음
  noData,

  /// 검색 결과 없음
  noSearch,

  /// 에러
  error,

  /// 오프라인
  offline,
}

/// 앱 전역에서 사용하는 빈 상태 컴포넌트
///
/// **사용 예시**:
/// ```dart
/// // 기본 빈 상태
/// AppEmptyState(
///   icon: Icons.inbox,
///   title: '아직 할 일이 없어요',
///   description: '첫 번째 할 일을 만들어볼까요?',
///   actionText: '할 일 만들기',
///   onAction: () => createTodo(),
/// )
///
/// // 검색 결과 없음
/// AppEmptyState(
///   type: AppEmptyType.noSearch,
///   title: '검색 결과가 없어요',
///   description: '다른 검색어로 찾아볼까요?',
/// )
///
/// // 오프라인
/// AppEmptyState(
///   type: AppEmptyType.offline,
///   title: '인터넷 연결이 끊겼어요',
///   description: '연결 상태를 확인해 주세요',
///   actionText: '다시 시도',
///   onAction: () => retry(),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.type = AppEmptyType.noData,
    this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.iconSize,
    this.iconColor,
  });

  /// 빈 상태 타입 (기본 아이콘 결정)
  final AppEmptyType type;

  /// 커스텀 아이콘 (null이면 타입별 기본 아이콘)
  final IconData? icon;

  /// 제목 (필수)
  final String title;

  /// 설명 (선택)
  final String? description;

  /// 액션 버튼 텍스트 (null이면 버튼 없음)
  final String? actionText;

  /// 액션 콜백
  final VoidCallback? onAction;

  /// 아이콘 크기 (기본: 64px)
  final double? iconSize;

  /// 아이콘 색상
  final Color? iconColor;

  IconData get _effectiveIcon {
    if (icon != null) return icon!;

    switch (type) {
      case AppEmptyType.noData:
        return Icons.inbox_outlined;
      case AppEmptyType.noSearch:
        return Icons.search_off;
      case AppEmptyType.error:
        return Icons.error_outline;
      case AppEmptyType.offline:
        return Icons.wifi_off;
    }
  }

  Color get _effectiveIconColor {
    if (iconColor != null) return iconColor!;
    return AppColors.textTertiary;
  }

  double get _effectiveIconSize => iconSize ?? 64.w;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: _effectiveIconSize * 1.5,
              height: _effectiveIconSize * 1.5,
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _effectiveIcon,
                size: _effectiveIconSize,
                color: _effectiveIconColor,
              ),
            ),
            SizedBox(height: AppSpacing.s24),

            // 제목
            Text(
              title,
              style: AppTextStyles.heading_20.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            // 설명
            if (description != null) ...[
              SizedBox(height: AppSpacing.s8),
              Text(
                description!,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppSpacing.s24),
              AppButton(
                text: actionText!,
                width: 200.w,
                height: 48.h,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
