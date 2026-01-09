import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/space_button.dart';

/// 빈 상태 타입
enum SpaceEmptyType {
  /// 데이터 없음
  noData,

  /// 검색 결과 없음
  noSearch,

  /// 에러 발생
  error,

  /// 오프라인
  offline,
}

/// 우주공부선 Empty State
///
/// Toss UX 원칙이 적용된 빈 상태 위젯입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 피크엔드 법칙: 친근한 비격식체 + 귀여운 아이콘으로 빈 상태 불편함 최소화
/// - 심미적 사용성: 일러스트레이션 지원
/// - Predictable Hint: 다음 단계 안내 (actionText)
///
/// **Toss 라이팅 원칙:**
/// - title: "아직 할 일이 없어요" (X: "데이터가 없습니다")
/// - description: "첫 번째 할 일을 만들어볼까요?" (감정 공감)
/// - actionText: "할 일 만들기" (다음 화면 예측 가능)
///
/// **사용 예시:**
/// ```dart
/// SpaceEmptyState(
///   icon: Icons.inbox,
///   title: '아직 할 일이 없어요',
///   description: '첫 번째 할 일을 만들어볼까요?',
///   actionText: '할 일 만들기',
///   onAction: () => createTodo(),
/// )
///
/// SpaceEmptyState(
///   type: SpaceEmptyType.noSearch,
///   icon: Icons.search_off,
///   title: '검색 결과가 없어요',
///   description: '다른 검색어로 찾아볼까요?',
/// )
/// ```
class SpaceEmptyState extends StatelessWidget {
  /// SpaceEmptyState 생성자
  const SpaceEmptyState({
    super.key,
    this.type = SpaceEmptyType.noData,
    this.icon,
    this.iconWidget,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  }) : assert(
         icon != null || iconWidget != null,
         'icon 또는 iconWidget 중 하나는 필수입니다',
       );

  /// 빈 상태 타입
  final SpaceEmptyType type;

  /// 아이콘 (IconData)
  final IconData? icon;

  /// 커스텀 아이콘/일러스트 위젯
  final Widget? iconWidget;

  /// 제목 (Toss 라이팅: "아직 할 일이 없어요")
  final String title;

  /// 설명 (감정 공감)
  final String? description;

  /// 주요 액션 버튼 텍스트 (Predictable Hint)
  final String? actionText;

  /// 주요 액션 콜백
  final VoidCallback? onAction;

  /// 보조 액션 버튼 텍스트
  final String? secondaryActionText;

  /// 보조 액션 콜백
  final VoidCallback? onSecondaryAction;

  /// 타입별 기본 아이콘
  IconData get _defaultIcon {
    switch (type) {
      case SpaceEmptyType.noData:
        return Icons.inbox_outlined;
      case SpaceEmptyType.noSearch:
        return Icons.search_off;
      case SpaceEmptyType.error:
        return Icons.error_outline;
      case SpaceEmptyType.offline:
        return Icons.wifi_off;
    }
  }

  /// 타입별 아이콘 색상
  Color get _iconColor {
    switch (type) {
      case SpaceEmptyType.noData:
      case SpaceEmptyType.noSearch:
        return AppColors.textTertiary;
      case SpaceEmptyType.error:
        return AppColors.error.withValues(alpha: 0.7);
      case SpaceEmptyType.offline:
        return AppColors.warning.withValues(alpha: 0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.all24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘/일러스트
            _buildIcon(),
            SizedBox(height: 24.h),

            // 제목
            Text(
              title,
              style: AppTextStyles.heading4.semiBold().copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // 설명
            if (description != null) ...[
              SizedBox(height: 12.h),
              Text(
                description!,
                style: AppTextStyles.body2.regular().copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 32.h),
              SizedBox(
                width: 200.w,
                child: SpaceButton(text: actionText!, onPressed: onAction),
              ),
            ],

            // 보조 액션 버튼
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: 200.w,
                child: SpaceButton(
                  text: secondaryActionText!,
                  type: SpaceButtonType.text,
                  onPressed: onSecondaryAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconWidget != null) {
      return iconWidget!;
    }

    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: _iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon ?? _defaultIcon, size: 48.w, color: _iconColor),
    );
  }
}
