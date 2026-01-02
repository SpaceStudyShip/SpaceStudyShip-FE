import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';
import '../../../constants/text_styles.dart';
import '../../atoms/buttons/space_primary_button.dart';

/// 우주공부선 Empty State
///
/// 데이터가 없을 때 표시하는 빈 상태 위젯입니다.
/// 아이콘, 제목, 설명, 액션 버튼을 포함할 수 있습니다.
///
/// **기본 사용**:
/// ```dart
/// SpaceEmptyState(
///   icon: Icons.inbox,
///   title: '데이터가 없습니다',
///   description: '새로운 항목을 추가해보세요',
/// )
/// ```
///
/// **액션 버튼 포함**:
/// ```dart
/// SpaceEmptyState(
///   icon: Icons.add_circle_outline,
///   title: 'Todo가 없습니다',
///   description: '첫 번째 Todo를 만들어보세요',
///   actionText: 'Todo 추가',
///   onAction: () {
///     // Todo 추가 로직
///   },
/// )
/// ```
///
/// **커스텀 아이콘**:
/// ```dart
/// SpaceEmptyState(
///   iconWidget: Image.asset('assets/images/empty.png'),
///   title: '검색 결과 없음',
///   description: '다른 키워드로 검색해보세요',
/// )
/// ```
class SpaceEmptyState extends StatelessWidget {
  /// Empty State 생성자
  const SpaceEmptyState({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
  }) : assert(
          icon != null || iconWidget != null,
          'icon 또는 iconWidget 중 하나는 필수입니다',
        );

  /// 아이콘 (IconData)
  final IconData? icon;

  /// 커스텀 아이콘 위젯
  final Widget? iconWidget;

  /// 제목
  final String title;

  /// 설명 (선택적)
  final String? description;

  /// 액션 버튼 텍스트 (선택적)
  final String? actionText;

  /// 액션 버튼 클릭 콜백
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.all24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: 24.h),
            _buildTitle(),
            if (description != null) ...[
              SizedBox(height: 12.h),
              _buildDescription(),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 32.h),
              _buildActionButton(),
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

    return Icon(
      icon,
      size: 80.w,
      color: AppColors.textTertiary,
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppTextStyles.heading4.semiBold().copyWith(
            color: AppColors.textPrimary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      description!,
      style: AppTextStyles.body2.regular().copyWith(
            color: AppColors.textSecondary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return SpacePrimaryButton(
      text: actionText!,
      onPressed: onAction,
      width: 200.w,
    );
  }
}
