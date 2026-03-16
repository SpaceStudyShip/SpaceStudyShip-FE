import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/planet_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/utils/unlock_dialog_helper.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/space/circular_progress.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../providers/exploration_provider.dart';
import '../widgets/region_flag_icon.dart';

/// 지역 상세 스크린 - PageView 좌우 스와이프
///
/// 행성 내 지역들을 좌우 스와이프로 탐색합니다.
/// 해금, 상태 확인, 정보 열람이 가능합니다.
class LocationDetailScreen extends ConsumerStatefulWidget {
  const LocationDetailScreen({
    super.key,
    required this.planetId,
    required this.initialRegionId,
  });

  final String planetId;
  final String initialRegionId;

  @override
  ConsumerState<LocationDetailScreen> createState() =>
      _LocationDetailScreenState();
}

class _LocationDetailScreenState extends ConsumerState<LocationDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // regionListNotifierProvider는 동기 StateNotifier로 항상 즉시 데이터 반환
    final regions = ref.read(regionListNotifierProvider(widget.planetId));
    final initialIndex = regions.indexWhere(
      (r) => r.id == widget.initialRegionId,
    );
    _currentPage = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: TossDesignTokens.entranceFast,
        curve: TossDesignTokens.smoothCurve,
      );
    }
  }

  void _goToNext(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: TossDesignTokens.entranceFast,
        curve: TossDesignTokens.smoothCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final regions = ref.watch(regionListNotifierProvider(widget.planetId));
    final progress = ref.watch(explorationProgressProvider(widget.planetId));
    final currentFuel = ref.watch(currentFuelProvider);
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) => planets.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );

    if (planet == null || regions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.spaceBackground,
        body: Stack(
          children: [
            const Positioned.fill(child: SpaceBackground()),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16),
                  Text(
                    '지역 정보를 불러오는 중...',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),

          // AppBar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s4,
                  AppSpacing.s8,
                  AppSpacing.s16,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentPage + 1} / ${regions.length}',
                      style: AppTextStyles.label16Medium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // PageView
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: regions.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _buildRegionPage(
                  planet: planet,
                  region: regions[index],
                  progress: progress,
                  currentFuel: currentFuel,
                  totalPages: regions.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionPage({
    required ExplorationNodeEntity planet,
    required ExplorationNodeEntity region,
    required ExplorationProgressEntity progress,
    required int currentFuel,
    required int totalPages,
  }) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s8,
        AppSpacing.s20,
        bottomPadding,
      ),
      child: Column(
        children: [
          // 상단: 행성 + 지역 아이콘 + 원형 진행도
          _buildHeroSection(planet, region, progress),

          SizedBox(height: AppSpacing.s32),

          // 지역명
          Text(
            region.name,
            style: AppTextStyles.heading_24.copyWith(color: Colors.white),
          ),

          SizedBox(height: AppSpacing.s32),

          // 2x2 정보 그리드 (남은 공간 채움)
          Expanded(child: _buildInfoGrid(region)),

          SizedBox(height: AppSpacing.s16),

          // 하단: < 해금하기 >
          _buildBottomBar(region, currentFuel, totalPages),

          SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  /// 상단 히어로: 좌측 행성, 우측 지역 국기 + 원형 진행도
  Widget _buildHeroSection(
    ExplorationNodeEntity planet,
    ExplorationNodeEntity region,
    ExplorationProgressEntity progress,
  ) {
    return Row(
      children: [
        // 좌측: 행성 아이콘
        Expanded(child: PlanetIcons.buildIcon(planet.icon, size: 160.w)),

        SizedBox(width: AppSpacing.s16),

        // 우측: 국기 + 원형 진행도
        Expanded(
          child: Column(
            children: [
              RegionFlagIcon(
                icon: region.icon,
                size: 64.w,
                isLocked: !region.isUnlocked,
                isCircular: true,
              ),
              SizedBox(height: AppSpacing.s12),
              SpaceCircularProgress(progress: progress.progressRatio, size: 56),
              SizedBox(height: AppSpacing.s8),
              Text(
                region.description.isNotEmpty
                    ? region.description
                    : planet.name,
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2x2 정보 그리드 (Expanded로 감싸져 남은 공간 채움)
  Widget _buildInfoGrid(ExplorationNodeEntity region) {
    final statusText = region.isCleared
        ? '클리어'
        : region.isUnlocked
        ? '해금됨'
        : '잠김';
    final statusIcon = region.isCleared
        ? Icons.check_circle_rounded
        : region.isUnlocked
        ? Icons.lock_open_rounded
        : Icons.lock_rounded;
    final statusColor = region.isCleared
        ? AppColors.success
        : region.isUnlocked
        ? AppColors.primary
        : AppColors.textTertiary;

    final dateText = region.unlockedAt != null
        ? DateFormat('yyyy.MM.dd').format(region.unlockedAt!)
        : region.isUnlocked
        ? '기본 해금'
        : '-';

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: statusIcon,
                  iconColor: statusColor,
                  title: '상태',
                  value: statusText,
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.local_gas_station_rounded,
                  iconColor: AppColors.accentGold,
                  title: '필요 연료',
                  value: '${region.requiredFuel}통',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.secondary,
                  title: '해금일',
                  value: dateText,
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.description_rounded,
                  iconColor: AppColors.textSecondary,
                  title: '설명',
                  value: region.description.isNotEmpty
                      ? region.description
                      : '-',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하단: < AppButton >
  Widget _buildBottomBar(
    ExplorationNodeEntity region,
    int currentFuel,
    int totalPages,
  ) {
    final isLocked = !region.isUnlocked;
    final hasEnoughFuel = currentFuel >= region.requiredFuel;

    return Row(
      children: [
        // < 이전
        _NavArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 0,
          onTap: _goToPrevious,
        ),

        SizedBox(width: AppSpacing.s12),

        // CTA 버튼
        Expanded(
          child: isLocked
              ? AppButton(
                  text: '해금하기',
                  onPressed: hasEnoughFuel
                      ? () => _handleUnlock(region, currentFuel)
                      : null,
                  width: double.infinity,
                )
              : AppButton(
                  text: region.isCleared ? '탐험 완료' : '해금됨',
                  onPressed: null,
                  width: double.infinity,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: region.isCleared
                      ? AppColors.success
                      : AppColors.textSecondary,
                  showBorder: true,
                  borderColor: region.isCleared
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.spaceDivider,
                ),
        ),

        SizedBox(width: AppSpacing.s12),

        // > 다음
        _NavArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages - 1,
          onTap: () => _goToNext(totalPages),
        ),
      ],
    );
  }

  void _handleUnlock(ExplorationNodeEntity region, int currentFuel) {
    if (currentFuel < region.requiredFuel) {
      AppSnackBar.error(context, '연료가 부족합니다! (필요: ${region.requiredFuel}통)');
      return;
    }

    showUnlockDialog(
      context: context,
      nodeName: region.name,
      requiredFuel: region.requiredFuel,
      onUnlock: () => ref
          .read(regionListNotifierProvider(widget.planetId).notifier)
          .unlockRegion(region.id, region.requiredFuel),
    );
  }
}

// ─── 정보 카드 ──────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
        border: Border.all(
          color: AppColors.spaceDivider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 16.w, color: iconColor),
            ],
          ),
          SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── 좌/우 화살표 버튼 ──────────────────────────────────

class _NavArrowButton extends StatelessWidget {
  const _NavArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: icon == Icons.chevron_left_rounded ? '이전 지역' : '다음 지역',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            borderRadius: AppRadius.medium,
            border: Border.all(
              color: enabled
                  ? AppColors.spaceDivider
                  : AppColors.spaceDivider.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : AppColors.textTertiary,
            size: 24.w,
          ),
        ),
      ),
    );
  }
}
