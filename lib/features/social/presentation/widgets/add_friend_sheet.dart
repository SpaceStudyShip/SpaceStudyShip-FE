import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

/// 친구 추가 바텀시트 (Mock UI)
///
/// 검색창 + 더미 검색 결과 리스트.
/// 실제 API 명세 확정 시 SearchProvider + Repository 연결 예정.
class AddFriendSheet extends StatefulWidget {
  const AddFriendSheet({super.key});

  /// 바텀시트 표시 진입점
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.spaceSurface,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modal),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const AddFriendSheet(),
      ),
    );
  }

  @override
  State<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<AddFriendSheet> {
  final _controller = TextEditingController();
  String _query = '';

  // 더미 검색 결과 — API 연결 시 Repository로 교체
  static const _mockUsers = <_MockUser>[
    _MockUser(id: 'mock1', name: '강하늘', tag: '@skylar'),
    _MockUser(id: 'mock2', name: '서지우', tag: '@jiwoo'),
    _MockUser(id: 'mock3', name: '윤채린', tag: '@chaerin'),
    _MockUser(id: 'mock4', name: '백승호', tag: '@seungho'),
    _MockUser(id: 'mock5', name: '문가람', tag: '@garam'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_MockUser> get _filtered {
    if (_query.isEmpty) return _mockUsers;
    final q = _query.toLowerCase();
    return _mockUsers
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.tag.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s12,
          AppSpacing.s20,
          AppSpacing.s20 + FloatingNavMetrics.totalHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DragHandle(),
            SizedBox(height: AppSpacing.s16),
            Text(
              '친구 추가',
              style: AppTextStyles.heading_20.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              '이름이나 태그로 검색해보세요',
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: _controller,
              hintText: '이름 또는 @태그',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _query = v),
            ),
            SizedBox(height: AppSpacing.s16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 320.h),
              child: _filtered.isEmpty
                  ? _EmptyResult()
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: AppSpacing.s8),
                      itemBuilder: (_, i) {
                        final user = _filtered[i];
                        return _UserRow(
                          user: user,
                          onRequest: () => _onRequest(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRequest(_MockUser user) {
    Navigator.of(context).pop();
    AppSnackBar.success(context, '${user.name}님에게 친구 요청을 보냈어요');
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.spaceDivider,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s32),
      child: Center(
        child: Text(
          '검색 결과가 없어요',
          style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onRequest});

  final _MockUser user;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.spaceSurface,
              border: Border.all(color: AppColors.spaceDivider),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : '?',
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.tag,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRequest,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.button,
              ),
              child: Text(
                '요청',
                style: AppTextStyles.tag_12.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockUser {
  const _MockUser({required this.id, required this.name, required this.tag});

  final String id;
  final String name;
  final String tag;
}
