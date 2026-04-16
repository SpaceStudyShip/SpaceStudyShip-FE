import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/friend_entity.dart';
import '../widgets/live_session_ring.dart';

/// 친구 상세 화면 (D2 — 원형 프로그레스)
///
/// 구성: 헤더 행(아바타+이름+상태) → LiveSessionRing → 통계 2개 → 응원 버튼
class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({super.key, required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            color: AppColors.textSecondary,
            onPressed: () => _showActionsSheet(context),
          ),
          SizedBox(width: AppSpacing.s4),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.s8),
                  _HeaderRow(friend: friend),
                  SizedBox(height: AppSpacing.s24),
                  Center(
                    child: LiveSessionRing(
                      duration: friend.studyDuration ?? Duration.zero,
                      active: isStudying,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: _formatDuration(
                            friend.weeklyStudyDuration ?? Duration.zero,
                          ),
                          label: '이번 주',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _StatBox(
                          // TODO(#67): friend_entity에 streak 필드 추가 후 교체
                          value: '5일',
                          label: '연속 학습',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16),
                  AppButton(
                    text: '응원 보내기',
                    onPressed: isStudying ? () => _onCheer(context) : null,
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                  ),
                  SizedBox(height: AppSpacing.s24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  void _onCheer(BuildContext context) {
    AppSnackBar.success(context, '${friend.name}님에게 응원을 보냈어요');
  }

  Future<void> _showActionsSheet(BuildContext context) async {
    final action = await showModalBottomSheet<_FriendAction>(
      context: context,
      backgroundColor: AppColors.spaceSurface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modal),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.spaceDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.s12),
              ListTile(
                leading: Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  '친구 삭제',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, _FriendAction.delete),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == _FriendAction.delete) {
      await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppDialog.confirm(
      context: context,
      title: '${friend.name}님을 친구에서 삭제할까요?',
      message: '삭제하면 우주선에서 내려요. 다시 추가하려면 친구 요청을 보내야 해요.',
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );

    if (!context.mounted) return;
    if (ok == true) {
      context.pop();
      AppSnackBar.success(context, '${friend.name}님을 삭제했어요');
    }
  }
}

enum _FriendAction { delete }

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;
    final borderColor =
        isStudying ? AppColors.success : AppColors.spaceDivider;

    return Row(
      children: [
        _FriendAvatar(name: friend.name, borderColor: borderColor),
        SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.name,
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              _StatusLine(friend: friend),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.name, required this.borderColor});

  final String name;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.spaceElevated,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.heading_24.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (friend.status) {
      FriendStatus.studying => (
        friend.currentSubject == null
            ? '지금 공부 중'
            : '지금 공부 중 · ${friend.currentSubject}',
        AppColors.success,
      ),
      FriendStatus.idle => ('대기 중', AppColors.textTertiary),
      FriendStatus.offline => ('오프라인', AppColors.textTertiary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: AppSpacing.s4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tag_12.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: SpaceStatItem(
        value: value,
        label: label,
        valueFirst: true,
      ),
    );
  }
}
