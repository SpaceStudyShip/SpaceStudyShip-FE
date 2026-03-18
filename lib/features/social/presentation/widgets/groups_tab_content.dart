import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../providers/group_provider.dart';
import 'group_ticket_card.dart';

class GroupsTabContent extends ConsumerStatefulWidget {
  const GroupsTabContent({super.key});

  @override
  ConsumerState<GroupsTabContent> createState() => _GroupsTabContentState();
}

class _GroupsTabContentState extends ConsumerState<GroupsTabContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupListProvider);

    if (groups.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpaceEmptyState(
            icon: Icons.groups_rounded,
            color: AppColors.secondary,
            title: '참여 중인 그룹이 없어요',
            subtitle: '그룹에 참여해서 함께 목표를 달성해요',
          ),
          SizedBox(height: AppSpacing.s24),
          _buildActionButtons(),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: AppPadding.horizontal8,
                child: GroupTicketCard(
                  group: group,
                  onTap: () =>
                      context.push(RoutePaths.groupDetailPath(group.id)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: AppPadding.all20,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          text: '그룹 만들기',
          onPressed: () {},
          width: 140,
        ),
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
