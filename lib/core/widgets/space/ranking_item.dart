import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_gradients.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';

/// 랭킹 아이템 위젯 - 순위 표시용
///
/// **사용 예시**:
/// ```dart
/// RankingItem(
///   rank: 1,
///   userName: '김우주',
///   avatarEmoji: '🧑‍🚀',
///   studyTime: Duration(hours: 5, minutes: 30),
///   isCurrentUser: true,
///   onTap: () => showProfile(userId),
/// )
/// ```
class RankingItem extends StatefulWidget {
  const RankingItem({
    super.key,
    required this.rank,
    required this.userName,
    required this.studyTime,
    this.avatarEmoji = '🧑‍🚀',
    this.isCurrentUser = false,
    this.onTap,
  });

  /// 순위 (1, 2, 3...)
  final int rank;

  /// 사용자 이름
  final String userName;

  /// 공부 시간
  final Duration studyTime;

  /// 아바타 이모지
  final String avatarEmoji;

  /// 현재 사용자 여부
  final bool isCurrentUser;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  State<RankingItem> createState() => _RankingItemState();
}

class _RankingItemState extends State<RankingItem> {
  bool _isPressed = false;

  LinearGradient get _medalGradient {
    switch (widget.rank) {
      case 1:
        return AppGradients.goldMedal;
      case 2:
        return AppGradients.silverMedal;
      case 3:
        return AppGradients.bronzeMedal;
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.grey]);
    }
  }

  Color get _rankColor {
    switch (widget.rank) {
      case 1:
        return AppColors.accentGold;
      case 2:
        return AppColors.textSecondary;
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textTertiary;
    }
  }

  String get _studyTimeText {
    final hours = widget.studyTime.inHours;
    final minutes = widget.studyTime.inMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '$hours시간 $minutes분' : '$hours시간';
    }
    return '$minutes분';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.spaceSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: widget.isCurrentUser
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 순위
              SizedBox(
                width: 36.w,
                child: widget.rank <= 3
                    ? Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _medalGradient,
                          boxShadow: [
                            BoxShadow(
                              color: _rankColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.rank}',
                            style: AppTextStyles.tag_12.copyWith(
                              color: widget.rank == 2 ? Colors.black87 : Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        '${widget.rank}',
                        style: AppTextStyles.heading_20.copyWith(
                          color: _rankColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              SizedBox(width: 12.w),

              // 아바타
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.spaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.rank <= 3
                        ? _rankColor
                        : AppColors.spaceDivider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 22.w,
                    color: widget.rank <= 3 ? _rankColor : AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // 이름
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.userName,
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: Colors.white,
                              fontWeight: widget.isCurrentUser
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isCurrentUser) ...[
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '나',
                              style: AppTextStyles.tag_12.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.rank <= 3)
                      Text(
                        widget.rank == 1
                            ? '이번 주 1등!'
                            : widget.rank == 2
                            ? '조금만 더!'
                            : '분발하세요!',
                        style: AppTextStyles.tag_12.copyWith(color: _rankColor),
                      ),
                  ],
                ),
              ),

              // 공부 시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _studyTimeText,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: widget.rank <= 3
                          ? _rankColor
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '공부 시간',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
