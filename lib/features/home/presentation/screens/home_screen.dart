import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/space/spaceship_card.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../widgets/spaceship_header.dart';
import '../widgets/spaceship_selector.dart';

/// 홈 스크린
///
/// SliverAppBar를 사용하여 우주선 게이미피케이션 헤더를 표시합니다.
/// 스크롤 시 우주선이 축소되며 AppBar로 변환됩니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 임시 상태 (나중에 Riverpod Provider로 이동)
  String _selectedSpaceshipId = 'default';
  String _selectedSpaceshipIcon = '🚀';
  String _selectedSpaceshipName = '화성 탐사선';
  final double _fuel = 85.0;
  final int _experience = 1234;
  final int _streakDays = 5;
  final bool _isStreakActive = true;

  // 샘플 우주선 데이터
  final List<SpaceshipData> _spaceships = [
    const SpaceshipData(
      id: 'default',
      icon: '🚀',
      name: '화성 탐사선',
      isUnlocked: true,
      rarity: SpaceshipRarity.normal,
    ),
    const SpaceshipData(
      id: 'ufo',
      icon: '🛸',
      name: 'UFO',
      isUnlocked: true,
      rarity: SpaceshipRarity.rare,
    ),
    const SpaceshipData(
      id: 'satellite',
      icon: '🛰️',
      name: '인공위성',
      isUnlocked: true,
      isAnimated: true,
      rarity: SpaceshipRarity.epic,
    ),
    const SpaceshipData(
      id: 'star',
      icon: '🌟',
      name: '스타쉽',
      isUnlocked: false,
      rarity: SpaceshipRarity.legendary,
    ),
    const SpaceshipData(
      id: 'shuttle',
      icon: '🚁',
      name: '셔틀',
      isUnlocked: false,
      rarity: SpaceshipRarity.normal,
    ),
    const SpaceshipData(
      id: 'moon',
      icon: '🌙',
      name: '달 탐사선',
      isUnlocked: false,
      rarity: SpaceshipRarity.rare,
    ),
  ];

  void _showSpaceshipSelector() {
    showSpaceshipSelector(
      context: context,
      spaceships: _spaceships,
      selectedId: _selectedSpaceshipId,
      onSelect: (id) {
        final selected = _spaceships.firstWhere((s) => s.id == id);
        setState(() {
          _selectedSpaceshipId = id;
          _selectedSpaceshipIcon = selected.icon;
          _selectedSpaceshipName = selected.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          CustomScrollView(
            slivers: [
              // SliverAppBar - 우주선 헤더
              SliverAppBar(
                expandedHeight: 320.h,
                pinned: true,
                backgroundColor: Colors.transparent,
            elevation: 0,
            title: _buildCollapsedTitle(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24.w,
                ),
                onPressed: () {
                  // TODO: 알림 화면
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SpaceshipHeader(
                spaceshipIcon: _selectedSpaceshipIcon,
                spaceshipName: _selectedSpaceshipName,
                fuel: _fuel,
                experience: _experience,
                streakDays: _streakDays,
                isStreakActive: _isStreakActive,
                onSpaceshipTap: _showSpaceshipSelector,
              ),
            ),
          ),

          // 오늘의 할 일 섹션
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                child: _buildSectionTitle('오늘의 할 일'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Padding(
                padding: AppPadding.horizontal20,
                child: _buildEmptyTodoCard(),
              ),
            ),
          ),

          // 최근 활동 섹션
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                child: _buildSectionTitle('최근 활동'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: Padding(
                padding: AppPadding.horizontal20,
                child: _buildEmptyActivityCard(),
              ),
            ),
          ),

          // 바텀 여백
          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox(height: 100.h),
          ),
        ],
      ),
        ],
      ),
    );
  }

  /// 축소된 AppBar 제목 (스크롤 후 표시)
  Widget _buildCollapsedTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpaceIcons.buildIcon(_selectedSpaceshipIcon, size: 24.w),
        SizedBox(width: AppSpacing.s8),
        Text(
          _selectedSpaceshipName,
          style: AppTextStyles.label_16.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// 빈 할 일 카드
  Widget _buildEmptyTodoCard() {
    return AppCard(
      style: AppCardStyle.outlined,
      padding: AppPadding.all24,
      child: SpaceEmptyState(
        icon: Icons.edit_note_rounded,
        title: '오늘의 할 일이 없어요',
        subtitle: '할 일을 추가해보세요',
        iconSize: 40,
        animated: false,
      ),
    );
  }

  /// 빈 활동 카드
  Widget _buildEmptyActivityCard() {
    return AppCard(
      style: AppCardStyle.outlined,
      padding: AppPadding.all24,
      child: SpaceEmptyState(
        icon: Icons.auto_awesome_rounded,
        title: '아직 활동 기록이 없어요',
        subtitle: '타이머로 공부를 시작해보세요',
        iconSize: 40,
        animated: false,
      ),
    );
  }
}
