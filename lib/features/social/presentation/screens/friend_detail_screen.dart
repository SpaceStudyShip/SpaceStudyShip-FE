import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../domain/entities/friend_entity.dart';

/// 친구 상세 화면
///
/// ShipNode 또는 DockedShipNode 탭 시 Navigator.push로 이동
class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({super.key, required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;
    final borderColor = isStudying ? AppColors.success : AppColors.spaceDivider;

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SpaceBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppPadding.screenPadding,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // 아바타
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.spaceElevated,
                      border: Border.all(color: borderColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      friend.name.isNotEmpty ? friend.name[0] : '?',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  // 이름
                  Text(
                    friend.name,
                    style: AppTextStyles.heading_20.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  // 상태
                  _StatusBadge(status: friend.status),
                  SizedBox(height: AppSpacing.s24),
                  // 현재 과목 카드 (공부 중일 때만)
                  if (isStudying && friend.currentSubject != null)
                    _SubjectCard(
                      subject: friend.currentSubject!,
                      studyDuration: friend.studyDuration ?? Duration.zero,
                    ),
                  if (isStudying && friend.currentSubject != null)
                    SizedBox(height: AppSpacing.s12),
                  // 오늘 / 이번 주 통계
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: _formatDuration(
                            friend.studyDuration ?? Duration.zero,
                          ),
                          label: '오늘 공부',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _StatCard(
                          value: _formatDuration(
                            friend.weeklyStudyDuration ?? Duration.zero,
                          ),
                          label: '이번 주',
                        ),
                      ),
                    ],
                  ),
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final FriendStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FriendStatus.studying => ('지금 공부 중', AppColors.success),
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
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.tag_12.copyWith(color: color)),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.studyDuration});

  final String subject;
  final Duration studyDuration;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.spaceElevated,
              borderRadius: AppRadius.medium,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 과목',
                style: AppTextStyles.tag_10.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subject,
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatDuration(studyDuration),
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading_20.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.tag_10.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
