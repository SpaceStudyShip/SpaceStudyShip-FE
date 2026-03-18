import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_entity.dart';

class GroupTicketCard extends StatefulWidget {
  const GroupTicketCard({
    super.key,
    required this.group,
    this.onTap,
  });

  final GroupEntity group;
  final VoidCallback? onTap;

  @override
  State<GroupTicketCard> createState() => _GroupTicketCardState();
}

class _GroupTicketCardState extends State<GroupTicketCard> {
  bool _isPressed = false;

  int get _onlineCount => widget.group.members
      .where((m) => m.status == OnlineStatus.online)
      .length;

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
        child: Hero(
          tag: 'group-ticket-${widget.group.id}',
          child: Container(
            width: 280.w,
            padding: AppPadding.all20,
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: AppRadius.xxlarge,
              border: Border.all(
                color: AppColors.spaceDivider.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: CREW PASS + 티켓 코드
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CREW PASS',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'GR-${widget.group.inviteCode}',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // 중앙: 그룹 이름
                Center(
                  child: Text(
                    widget.group.name,
                    style: AppTextStyles.heading_20
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSpacing.s16),

                // 좌석 현황
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < widget.group.maxSeats; i++) ...[
                        if (i > 0) SizedBox(width: AppSpacing.s4),
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.small,
                            color: i < widget.group.members.length
                                ? AppColors.secondary.withValues(alpha: 0.6)
                                : AppColors.spaceDivider
                                    .withValues(alpha: 0.3),
                          ),
                          child: Icon(
                            i < widget.group.members.length
                                ? Icons.person_rounded
                                : Icons.event_seat_rounded,
                            size: 12.w,
                            color: i < widget.group.members.length
                                ? Colors.white
                                : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.s8),

                // 좌석 수 + 활동 중
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.group.members.length}/${widget.group.maxSeats}',
                        style: AppTextStyles.tag_12
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.online,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Text(
                        '$_onlineCount명 활동 중',
                        style: AppTextStyles.tag_12
                            .copyWith(color: AppColors.online),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // 바코드
                SizedBox(
                  height: 36.h,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/icons/barcode_lavender.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
