import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';
import '../models/seat_slot.dart';

/// 단일 우주선 좌석 위젯 (C 실루엣 스타일)
///
/// 상태별 스타일 분기:
/// - [SeatStatus.me]     : primary 파란색 테두리/배경/발판
/// - [SeatStatus.studying]: success 초록색 테두리/배경/발판
/// - [SeatStatus.docked] : divider 회색 + grayscale + opacity 0.5
/// - [SeatStatus.empty]  : 저채도 테두리 + "+" 아이콘
class SeatWidget extends StatelessWidget {
  const SeatWidget({
    super.key,
    required this.slot,
    this.onTap,
    this.muted = false,
  });

  final SeatSlot slot;
  final VoidCallback? onTap;

  /// 필터 탭에서 비매칭 좌석을 더 흐릿하게 표시
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final isEmpty = slot.status == SeatStatus.empty;
    final isDocked = slot.status == SeatStatus.docked;
    final accent = _accentColor(slot.status);

    final body = _SeatFrame(
      accentColor: accent,
      status: slot.status,
      child: Stack(
        children: [
          Positioned(
            top: 4.w,
            left: 5.w,
            child: Text(
              slot.seatNumber,
              style: AppTextStyles.tag_10.copyWith(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: _numberColor(slot.status),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildContent(slot, accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final rendered = isDocked || muted
        ? Opacity(
            opacity: muted ? 0.3 : 0.5,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: body,
            ),
          )
        : body;

    return GestureDetector(
      onTap: isEmpty ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(aspectRatio: 1, child: rendered),
    );
  }

  List<Widget> _buildContent(SeatSlot slot, Color accent) {
    if (slot.status == SeatStatus.empty) {
      return [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.spaceDivider.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.add, size: 14.sp, color: AppColors.textDisabled),
        ),
      ];
    }

    final friend = slot.friend!;
    final initial = friend.name.isNotEmpty ? friend.name[0] : '?';
    final timeLabel = _timeLabel(slot);

    return [
      Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: slot.status == SeatStatus.docked
              ? AppColors.spaceElevated
              : accent,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTextStyles.tag_12.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: slot.status == SeatStatus.docked
                ? AppColors.textTertiary
                : Colors.white,
          ),
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        friend.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.tag_10.copyWith(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        timeLabel,
        style: AppTextStyles.tag_10.copyWith(
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
          color: slot.status == SeatStatus.docked
              ? AppColors.textDisabled
              : accent,
        ),
      ),
    ];
  }

  String _timeLabel(SeatSlot slot) {
    if (slot.status == SeatStatus.docked) {
      final friend = slot.friend!;
      return friend.status == FriendStatus.offline ? '오프' : '대기';
    }
    final duration = slot.friend?.studyDuration ?? Duration.zero;
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Color _accentColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.me:
        return AppColors.primary;
      case SeatStatus.studying:
        return AppColors.success;
      case SeatStatus.docked:
      case SeatStatus.empty:
        return AppColors.spaceDivider;
    }
  }

  Color _numberColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.me:
        return AppColors.primary;
      case SeatStatus.studying:
        return AppColors.success;
      case SeatStatus.docked:
      case SeatStatus.empty:
        return AppColors.textDisabled;
    }
  }
}

/// C 실루엣 — 위 둥근 + 이중 테두리 + 발판 언더라인
class _SeatFrame extends StatelessWidget {
  const _SeatFrame({
    required this.accentColor,
    required this.status,
    required this.child,
  });

  final Color accentColor;
  final SeatStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isEmpty = status == SeatStatus.empty;
    final borderColor =
        (status == SeatStatus.me || status == SeatStatus.studying)
            ? accentColor
            : AppColors.spaceDivider;
    final fillColor = (status == SeatStatus.me)
        ? AppColors.primary.withValues(alpha: 0.10)
        : (status == SeatStatus.studying)
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.spaceSurface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isEmpty ? Colors.transparent : fillColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
            border: Border.all(
              color: isEmpty
                  ? AppColors.spaceDivider.withValues(alpha: 0.45)
                  : borderColor,
              width: 1.5,
            ),
          ),
          child: isEmpty
              ? child
              : Container(
                  margin: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13.r),
                      topRight: Radius.circular(13.r),
                      bottomLeft: Radius.circular(5.r),
                      bottomRight: Radius.circular(5.r),
                    ),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
        ),
        // 발판 언더라인
        if (!isEmpty && status != SeatStatus.docked)
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
