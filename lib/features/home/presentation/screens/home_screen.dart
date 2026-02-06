import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/space/spaceship_card.dart';
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
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════
          // SliverAppBar - 우주선 헤더
          // ═══════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 320.h,
            pinned: true,
            backgroundColor: AppColors.spaceBackground,
            elevation: 0,
            // 축소 시 표시될 제목
            title: _buildCollapsedTitle(),
            // 액션 버튼
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
            // 확장 영역
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

          // ═══════════════════════════════════════════════════
          // 오늘의 할 일 섹션
          // ═══════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: _buildSectionTitle('오늘의 할 일'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildEmptyTodoCard(),
            ),
          ),

          // ═══════════════════════════════════════════════════
          // 최근 활동 섹션
          // ═══════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: _buildSectionTitle('최근 활동'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildEmptyActivityCard(),
            ),
          ),

          // ═══════════════════════════════════════════════════
          // 바텀 여백 (콘텐츠 부족 시에도 스크롤 가능하도록)
          // ═══════════════════════════════════════════════════
          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox(height: 100.h),
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
        Text(
          _selectedSpaceshipIcon,
          style: TextStyle(fontSize: 24.w),
        ),
        SizedBox(width: 8.w),
        Text(
          _selectedSpaceshipName,
          style: AppTextStyles.label_16.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 섹션 제목
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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        children: [
          Text('📝', style: TextStyle(fontSize: 40.w)),
          SizedBox(height: 12.h),
          Text(
            '오늘의 할 일이 없어요',
            style: AppTextStyles.paragraph_14.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '할 일을 추가해보세요',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 활동 카드
  Widget _buildEmptyActivityCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        children: [
          Text('🌟', style: TextStyle(fontSize: 40.w)),
          SizedBox(height: 12.h),
          Text(
            '아직 활동 기록이 없어요',
            style: AppTextStyles.paragraph_14.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '타이머로 공부를 시작해보세요',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
