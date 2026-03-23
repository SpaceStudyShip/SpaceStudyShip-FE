import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../providers/group_provider.dart';

class GroupsTabContent extends ConsumerWidget {
  const GroupsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupListProvider);

    if (groups.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpaceEmptyState(
            icon: Icons.rocket_launch_rounded,
            color: AppColors.secondary,
            title: '참여 중인 우주선이 없어요',
            subtitle: '우주선을 만들거나 초대코드로 탑승해요',
          ),
          SizedBox(height: AppSpacing.s24),
          _buildActionButtons(),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: AppPadding.screenPadding,
            itemCount: groups.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final group = groups[index];
              return _ShipCard(
                group: group,
                onTap: () => context.push(RoutePaths.groupDetailPath(group.id)),
              );
            },
          ),
        ),
        Padding(padding: AppPadding.all20, child: _buildActionButtons()),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(text: '우주선 만들기', onPressed: () {}, width: 140),
        SizedBox(width: AppSpacing.s12),
        AppButton(
          text: '초대코드 입력',
          onPressed: () {},
          width: 140,
          backgroundColor: AppColors.spaceElevated,
        ),
      ],
    );
  }
}

/// 우주선 외관 카드
class _ShipCard extends StatefulWidget {
  const _ShipCard({required this.group, this.onTap});

  final GroupEntity group;
  final VoidCallback? onTap;

  @override
  State<_ShipCard> createState() => _ShipCardState();
}

class _ShipCardState extends State<_ShipCard> {
  bool _isPressed = false;

  int get _onlineCount =>
      widget.group.members.where((m) => m.status == OnlineStatus.online).length;

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
          padding: AppPadding.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.xlarge,
            border: Border.all(
              color: AppColors.spaceDivider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // 우주선 아이콘
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.large,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 28.w,
                  color: AppColors.secondaryLight,
                ),
              ),
              SizedBox(width: AppSpacing.s16),

              // 그룹 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      style: AppTextStyles.label_16.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Row(
                      children: [
                        // 탑승 인원
                        Icon(
                          Icons.people_rounded,
                          size: 14.w,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: AppSpacing.s4),
                        Text(
                          '${widget.group.members.length}/${widget.group.maxSeats}',
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s12),
                        // 온라인
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
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.online,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right_rounded,
                size: 24.w,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
