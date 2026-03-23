import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../providers/group_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupDetailProvider(groupId));

    if (group == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }

    // 좌석을 좌/우로 나누기 (비행기 좌석 배치)
    final halfSeats = (group.maxSeats / 2).ceil();

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                // 상단: 뒤로 버튼만
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s4,
                    AppSpacing.s8,
                    AppSpacing.s16,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20.w,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // 그룹명
                Text(
                  group.name,
                  style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                ),

                SizedBox(height: AppSpacing.s32),

                // 우주선 내부 영역
                Expanded(
                  child: Padding(
                    padding: AppPadding.horizontal20,
                    child: Column(
                      children: [
                        // 조종석 (그룹장 = seatIndex 0)
                        _buildCockpit(
                          group.members
                              .where((m) => m.seatIndex == 0)
                              .firstOrNull,
                        ),

                        SizedBox(height: AppSpacing.s24),

                        // 통로 구분선
                        _buildAisleDivider(),

                        SizedBox(height: AppSpacing.s24),

                        // 좌석 영역 (좌/우 배치)
                        Expanded(
                          child: Row(
                            children: [
                              // 왼쪽 좌석
                              Expanded(
                                child: Column(
                                  children: [
                                    for (int i = 1; i < halfSeats; i++) ...[
                                      if (i > 1)
                                        SizedBox(height: AppSpacing.s12),
                                      _buildSeat(
                                        group.members
                                            .where((m) => m.seatIndex == i)
                                            .firstOrNull,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // 통로 (가운데)
                              SizedBox(
                                width: 48.w,
                                child: Column(
                                  children: [
                                    // 통로 점선
                                    for (int i = 0; i < 3; i++) ...[
                                      Container(
                                        width: 2,
                                        height: 12.h,
                                        color: AppColors.spaceDivider
                                            .withValues(alpha: 0.3),
                                      ),
                                      SizedBox(height: AppSpacing.s8),
                                    ],
                                  ],
                                ),
                              ),

                              // 오른쪽 좌석
                              Expanded(
                                child: Column(
                                  children: [
                                    for (
                                      int i = halfSeats;
                                      i < group.maxSeats;
                                      i++
                                    ) ...[
                                      if (i > halfSeats)
                                        SizedBox(height: AppSpacing.s12),
                                      _buildSeat(
                                        group.members
                                            .where((m) => m.seatIndex == i)
                                            .firstOrNull,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSpacing.s16),

                        // 초대코드 — 우주선 번호판 (가운데 크게)
                        GestureDetector(
                          onTap: () =>
                              _copyInviteCode(context, group.inviteCode),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s24,
                              vertical: AppSpacing.s16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.spaceElevated,
                              borderRadius: AppRadius.xlarge,
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '초대코드',
                                  style: AppTextStyles.tag_12.copyWith(
                                    color: AppColors.textTertiary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.s8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      group.inviteCode,
                                      style: AppTextStyles.heading_24.copyWith(
                                        color: AppColors.secondaryLight,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.s8),
                                    SvgPicture.asset(
                                      'assets/icons/icon_copy.svg',
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.s20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 조종석 (그룹장)
  Widget _buildCockpit(GroupMemberEntity? captain) {
    final isFilled = captain != null;
    final statusColor = isFilled ? _statusColor(captain.status) : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.spaceSurface,
          ],
        ),
        borderRadius: AppRadius.xlarge,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 조종석 아이콘
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled
                  ? AppColors.spaceSurface
                  : AppColors.spaceSurface.withValues(alpha: 0.3),
              border: isFilled
                  ? Border.all(color: statusColor!, width: 2)
                  : Border.all(
                      color: AppColors.spaceDivider.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
              boxShadow: isFilled && captain.status == OnlineStatus.online
                  ? [
                      BoxShadow(
                        color: AppColors.online.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isFilled ? Icons.person_rounded : Icons.event_seat_rounded,
              size: 24.w,
              color: isFilled ? Colors.white : AppColors.textDisabled,
            ),
          ),
          SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFilled ? captain.name : '빈 좌석',
                  style: AppTextStyles.label_16.copyWith(
                    color: isFilled ? Colors.white : AppColors.textDisabled,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  '선장',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.stars_rounded,
            size: 20.w,
            color: AppColors.secondaryLight,
          ),
        ],
      ),
    );
  }

  /// 통로 구분선
  Widget _buildAisleDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.spaceDivider.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: AppPadding.horizontal8,
          child: Text(
            '좌석',
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.spaceDivider.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  /// 일반 좌석
  Widget _buildSeat(GroupMemberEntity? member) {
    final isFilled = member != null;
    final statusColor = isFilled ? _statusColor(member.status) : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
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
        boxShadow: isFilled && member.status == OnlineStatus.online
            ? [
                BoxShadow(
                  color: AppColors.online.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? AppColors.spaceSurface : Colors.transparent,
              border: isFilled
                  ? Border.all(color: statusColor!, width: 2)
                  : null,
            ),
            child: Icon(
              isFilled ? Icons.person_rounded : Icons.event_seat_rounded,
              size: 20.w,
              color: isFilled ? Colors.white : AppColors.textDisabled,
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          Text(
            isFilled ? member.name : '빈 좌석',
            style: AppTextStyles.tag_12.copyWith(
              color: isFilled ? Colors.white : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OnlineStatus status) => switch (status) {
    OnlineStatus.online => AppColors.online,
    OnlineStatus.away => AppColors.away,
    OnlineStatus.offline => AppColors.offline,
  };

  void _copyInviteCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('초대코드가 복사되었습니다: $code'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
