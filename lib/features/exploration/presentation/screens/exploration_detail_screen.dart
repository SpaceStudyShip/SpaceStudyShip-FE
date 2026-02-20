import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/utils/unlock_dialog_helper.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../providers/exploration_provider.dart';
import '../widgets/exploration_progress_bar.dart';
import '../widgets/region_card.dart';

/// 탐험 상세 스크린 - 지역 목록
///
/// 특정 행성의 하위 지역(Region) 목록을 표시합니다.
/// 연료를 소비하여 지역을 해금하고 클리어할 수 있습니다.
class ExplorationDetailScreen extends ConsumerWidget {
  const ExplorationDetailScreen({super.key, required this.planetId});

  /// 행성 ID
  final String planetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) => planets.where((p) => p.id == planetId).firstOrNull,
      ),
    );
    if (planet == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }
    final regions = ref.watch(regionListNotifierProvider(planetId));
    final progress = ref.watch(explorationProgressProvider(planetId));
    final currentFuel = ref.watch(currentFuelProvider);

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
              if (regions.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final region = regions[index];
                      return RegionCard(
                        node: region,
                        currentFuel: currentFuel,
                        onUnlock: () =>
                            _handleUnlock(context, region, currentFuel, ref),
                        onTap: () {
                          if (region.isCleared) {
                            AppSnackBar.info(
                              context,
                              '${region.name} - 이미 클리어한 지역입니다!',
                            );
                          }
                        },
                      );
                    }, childCount: regions.length),
                  ),
                ),

              // 지역이 없는 행성 (달, 화성, 목성 등)
              if (regions.isEmpty)
                SliverFillRemaining(
                  child: SpaceEmptyState(
                    icon: Icons.public_rounded,
                    color: AppColors.secondary,
                    title: '아직 탐험할 지역이 없습니다',
                    subtitle: '향후 업데이트에서 추가됩니다!',
                    iconSize: 64,
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
          SizedBox(height: AppSpacing.s12),
          ExplorationProgressBar(progress: progress, height: 8.h),
        ],
      ),
    );
  }

  void _handleUnlock(
    BuildContext context,
    ExplorationNodeEntity region,
    int currentFuel,
    WidgetRef ref,
  ) {
    if (currentFuel < region.requiredFuel) {
      AppSnackBar.error(context, '연료가 부족합니다! (필요: ${region.requiredFuel}통)');
      return;
    }

    showUnlockDialog(
      context: context,
      nodeName: region.name,
      requiredFuel: region.requiredFuel,
      onUnlock: () => ref
          .read(regionListNotifierProvider(planetId).notifier)
          .unlockRegion(region.id, region.requiredFuel),
    );
  }
}
