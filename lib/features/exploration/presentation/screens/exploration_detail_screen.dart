import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../widgets/exploration_progress_bar.dart';
import '../widgets/region_card.dart';

/// 탐험 상세 스크린 - 지역 목록
///
/// 특정 행성의 하위 지역(Region) 목록을 표시합니다.
/// 연료를 소비하여 지역을 해금하고 클리어할 수 있습니다.
class ExplorationDetailScreen extends StatelessWidget {
  const ExplorationDetailScreen({super.key, required this.planetId});

  /// 행성 ID
  final String planetId;

  @override
  Widget build(BuildContext context) {
    // TODO: Riverpod Provider 연결 후 제거
    final planet = _getSamplePlanet(planetId);
    final regions = _getSampleRegions(planetId);
    final progress = _getSampleProgress(planetId, regions);
    final currentFuel = 3.5;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          CustomScrollView(
            slivers: [
              // 행성 헤더 (SliverAppBar)
              SliverAppBar(
                expandedHeight: 200.h,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    planet.name,
                    style: AppTextStyles.label_16.copyWith(color: Colors.white),
                  ),
                  background: _buildPlanetHeader(planet, progress),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: FuelGauge(
                      currentFuel: currentFuel,
                      showLabel: false,
                      size: FuelGaugeSize.medium,
                    ),
                  ),
                ],
              ),

              // 진행도 섹션
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: _buildProgressSection(progress),
                ),
              ),

              // 지역 목록
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final region = regions[index];
                    return RegionCard(
                      node: region,
                      currentFuel: currentFuel,
                      onUnlock: () =>
                          _handleUnlock(context, region, currentFuel),
                      onTap: () {
                        // 클리어된 지역 재방문 시
                        if (region.isCleared) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${region.name} - 이미 클리어한 지역입니다!'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  }, childCount: regions.length),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetHeader(
    ExplorationNodeEntity planet,
    ExplorationProgressEntity progress,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.spaceBackground,
          ],
          stops: const [0.0, 0.9],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: AppSpacing.s16),
            // 행성 아이콘
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  planet.icon,
                  style: TextStyle(
                    fontSize: 36.sp,
                  ), // 이모지 아이콘 크기 (typography 아님)
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            // 설명
            if (planet.description.isNotEmpty)
              Text(
                planet.description,
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(ExplorationProgressEntity progress) {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '탐험 진행도',
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progress.progressRatio * 100).toInt()}%',
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: progress.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ExplorationProgressBar(progress: progress, height: 8.h),
        ],
      ),
    );
  }

  void _handleUnlock(
    BuildContext context,
    ExplorationNodeEntity region,
    double currentFuel,
  ) {
    if (currentFuel < region.requiredFuel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '연료가 부족합니다! (필요: ${region.requiredFuel.toStringAsFixed(1)}통)',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 해금 확인 다이얼로그
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.spaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlarge),
        title: Text(
          '${region.name} 해금',
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        ),
        content: Text(
          '연료 ${region.requiredFuel.toStringAsFixed(1)}통을 소비하여\n${region.name}을(를) 해금하시겠습니까?',
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Riverpod Provider로 해금 처리
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${region.name}이(가) 해금되었습니다! 🎉'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              '해금하기',
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // 임시 샘플 데이터 (Riverpod Provider 연결 후 제거)
  // ═══════════════════════════════════════════════════

  ExplorationNodeEntity _getSamplePlanet(String id) {
    final planets = {
      'earth': const ExplorationNodeEntity(
        id: 'earth',
        name: '지구',
        nodeType: ExplorationNodeType.planet,
        depth: 2,
        icon: '🌍',
        requiredFuel: 0,
        isUnlocked: true,
        sortOrder: 0,
        description: '우리의 출발지, 고향 행성',
      ),
      'moon': const ExplorationNodeEntity(
        id: 'moon',
        name: '달',
        nodeType: ExplorationNodeType.planet,
        depth: 2,
        icon: '🌙',
        requiredFuel: 5.0,
        isUnlocked: false,
        sortOrder: 1,
        description: '지구의 유일한 자연 위성',
      ),
      'mars': const ExplorationNodeEntity(
        id: 'mars',
        name: '화성',
        nodeType: ExplorationNodeType.planet,
        depth: 2,
        icon: '🔴',
        requiredFuel: 15.0,
        isUnlocked: false,
        sortOrder: 2,
        description: '붉은 행성, 탐험의 꿈',
      ),
    };
    return planets[id] ?? planets['earth']!;
  }

  List<ExplorationNodeEntity> _getSampleRegions(String planetId) {
    if (planetId == 'earth') {
      return const [
        ExplorationNodeEntity(
          id: 'korea',
          name: '대한민국',
          nodeType: ExplorationNodeType.region,
          depth: 3,
          icon: '🇰🇷',
          parentId: 'earth',
          requiredFuel: 0,
          isUnlocked: true,
          isCleared: true,
          sortOrder: 0,
          description: '한반도 남쪽, K-컬쳐의 중심',
        ),
        ExplorationNodeEntity(
          id: 'japan',
          name: '일본',
          nodeType: ExplorationNodeType.region,
          depth: 3,
          icon: '🇯🇵',
          parentId: 'earth',
          requiredFuel: 1.0,
          isUnlocked: false,
          sortOrder: 1,
          description: '동아시아의 섬나라',
        ),
        ExplorationNodeEntity(
          id: 'china',
          name: '중국',
          nodeType: ExplorationNodeType.region,
          depth: 3,
          icon: '🇨🇳',
          parentId: 'earth',
          requiredFuel: 1.5,
          isUnlocked: false,
          sortOrder: 2,
          description: '세계 최대 인구 대국',
        ),
        ExplorationNodeEntity(
          id: 'usa',
          name: '미국',
          nodeType: ExplorationNodeType.region,
          depth: 3,
          icon: '🇺🇸',
          parentId: 'earth',
          requiredFuel: 2.0,
          isUnlocked: false,
          sortOrder: 3,
          description: '자유의 나라',
        ),
        ExplorationNodeEntity(
          id: 'brazil',
          name: '브라질',
          nodeType: ExplorationNodeType.region,
          depth: 3,
          icon: '🇧🇷',
          parentId: 'earth',
          requiredFuel: 2.5,
          isUnlocked: false,
          sortOrder: 4,
          description: '남미의 최대 국가',
        ),
      ];
    }
    return [];
  }

  ExplorationProgressEntity _getSampleProgress(
    String planetId,
    List<ExplorationNodeEntity> regions,
  ) {
    final cleared = regions.where((r) => r.isCleared).length;
    return ExplorationProgressEntity(
      nodeId: planetId,
      clearedChildren: cleared,
      totalChildren: regions.length,
    );
  }
}
