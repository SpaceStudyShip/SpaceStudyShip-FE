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
import '../providers/group_provider.dart';
import '../widgets/seat_grid.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupDetailProvider(groupId));

    if (group == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                // AppBar: 뒤로 + 초대코드 복사
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
                      GestureDetector(
                        onTap: () => _copyInviteCode(context, group.inviteCode),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              group.inviteCode,
                              style: AppTextStyles.tag_12
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(width: AppSpacing.s4),
                            SvgPicture.asset(
                              'assets/icons/icon_copy.svg',
                              width: 18.w,
                              height: 18.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.s16),

                // 그룹 제목
                Text(
                  group.name,
                  style:
                      AppTextStyles.heading_20.copyWith(color: Colors.white),
                ),

                SizedBox(height: AppSpacing.s32),

                // 좌석 그리드
                Expanded(
                  child: SeatGrid(
                    maxSeats: group.maxSeats,
                    members: group.members,
                    onMemberTap: (member) {
                      // TODO: 멤버 프로필로 이동
                    },
                    onEmptySeatTap: () =>
                        _copyInviteCode(context, group.inviteCode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
