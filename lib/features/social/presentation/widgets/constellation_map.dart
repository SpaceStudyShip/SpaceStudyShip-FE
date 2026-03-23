import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../routes/route_paths.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/friend_provider.dart';
import 'constellation_painter.dart';
import 'constellation_patterns.dart';

class ConstellationMap extends ConsumerWidget {
  const ConstellationMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendListProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // 연결선
            CustomPaint(
              size: size,
              painter: ConstellationPainter(friends: friends),
            ),

            // 북극성 (나)
            _buildStar(
              context: context,
              position: ConstellationPatterns.polaris,
              size: size,
              label: '나',
              isPolaris: true,
              statusColor: AppColors.online,
            ),

            // 친구 별 / 빈 별
            for (
              int i = 0;
              i < ConstellationPatterns.bigDipperSlots.length;
              i++
            )
              _buildSlot(
                context: context,
                index: i,
                size: size,
                friend: friends.where((f) => f.slotIndex == i).firstOrNull,
              ),

            // 빈 상태 안내 텍스트
            if (friends.isEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.s64 + AppSpacing.s20,
                child: Text(
                  '친구를 추가해서 별자리를 완성해요',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // 친구 추가 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.s20,
              child: Center(
                child: AppButton(text: '친구 추가', onPressed: () {}, width: 140),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlot({
    required BuildContext context,
    required int index,
    required Size size,
    FriendEntity? friend,
  }) {
    final isFilled = friend != null;

    return _buildStar(
      context: context,
      position: ConstellationPatterns.bigDipperSlots[index],
      size: size,
      label: isFilled ? friend.name : '',
      isPolaris: false,
      isFilled: isFilled,
      statusColor: isFilled ? _statusColor(friend.status) : null,
      onTap: isFilled
          ? () => context.push(RoutePaths.friendDetailPath(friend.id))
          : () {},
    );
  }

  Widget _buildStar({
    required BuildContext context,
    required Offset position,
    required Size size,
    required String label,
    required bool isPolaris,
    bool isFilled = true,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    final starSize = isPolaris ? 48.w : 36.w;
    final px = position.dx * size.width - starSize / 2;
    final py = position.dy * size.height - starSize / 2;

    return Positioned(
      left: px,
      top: py,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: starSize,
              height: starSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? AppColors.spaceElevated
                    : AppColors.spaceSurface.withValues(alpha: 0.3),
                border: Border.all(
                  color: isFilled
                      ? (statusColor ?? AppColors.offline)
                      : AppColors.spaceDivider.withValues(alpha: 0.3),
                  width: isPolaris ? 2.5 : 1.5,
                ),
                boxShadow: isFilled && statusColor != null
                    ? [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isFilled ? Icons.person_rounded : Icons.add_rounded,
                  size: isPolaris ? 24.w : 18.w,
                  color: isFilled ? Colors.white : AppColors.textDisabled,
                ),
              ),
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s4),
              Text(
                label,
                style: AppTextStyles.tag_12.copyWith(
                  color: isPolaris
                      ? AppColors.primaryLight
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(OnlineStatus status) => switch (status) {
    OnlineStatus.online => AppColors.online,
    OnlineStatus.away => AppColors.away,
    OnlineStatus.offline => AppColors.offline,
  };
}
