import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_member_entity.dart';

class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.maxSeats,
    required this.members,
    this.onMemberTap,
    this.onEmptySeatTap,
  });

  final int maxSeats;
  final List<GroupMemberEntity> members;
  final void Function(GroupMemberEntity member)? onMemberTap;
  final VoidCallback? onEmptySeatTap;

  int get _crossAxisCount => maxSeats <= 4 ? 2 : 3;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppPadding.all20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.s16,
        mainAxisSpacing: AppSpacing.s16,
      ),
      itemCount: maxSeats,
      itemBuilder: (context, index) {
        final member =
            members.where((m) => m.seatIndex == index).firstOrNull;
        return _buildSeat(member);
      },
    );
  }

  Widget _buildSeat(GroupMemberEntity? member) {
    final isFilled = member != null;
    final statusColor = isFilled
        ? switch (member.status) {
            OnlineStatus.online => AppColors.online,
            OnlineStatus.away => AppColors.away,
            OnlineStatus.offline => AppColors.offline,
          }
        : null;

    return GestureDetector(
      onTap: isFilled
          ? () => onMemberTap?.call(member)
          : onEmptySeatTap,
      child: Container(
        decoration: BoxDecoration(
          color: isFilled
              ? AppColors.spaceElevated
              : AppColors.spaceSurface.withValues(alpha: 0.3),
          borderRadius: AppRadius.large,
          border: Border.all(
            color: isFilled
                ? (statusColor ?? AppColors.offline).withValues(alpha: 0.4)
                : AppColors.spaceDivider.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow:
              isFilled && member.status == OnlineStatus.online
                  ? [
                      BoxShadow(
                        color: AppColors.online.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.spaceSurface : Colors.transparent,
                border: isFilled
                    ? Border.all(color: statusColor!, width: 2)
                    : null,
              ),
              child: Icon(
                isFilled ? Icons.person_rounded : Icons.event_seat_rounded,
                size: 28.w,
                color: isFilled ? Colors.white : AppColors.textDisabled,
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            Text(
              isFilled ? member.name : '빈 좌석',
              style: AppTextStyles.tag_12.copyWith(
                color: isFilled ? Colors.white : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
