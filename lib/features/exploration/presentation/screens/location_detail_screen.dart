import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/planet_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/utils/unlock_dialog_helper.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../providers/exploration_provider.dart';
import '../widgets/boarding_pass_ticket.dart';
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

          SizedBox(height: AppSpacing.s24),

          // 지역명
          Text(
            region.name,
            style: AppTextStyles.heading_24.copyWith(color: Colors.white),
          ),

          SizedBox(height: AppSpacing.s24),

          // 탑승권 티켓 (정보 + 해금 인터랙션)
          Expanded(
            child: BoardingPassTicket(
              planet: planet,
              region: region,
              progress: progress,
              currentFuel: currentFuel,
              onTear: () => _handleUnlock(region, currentFuel),
            ),
          ),

          // 좌우 네비게이션 화살표
          SizedBox(height: AppSpacing.s12),
          _buildNavigationArrows(totalPages),

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
              ),
              SizedBox(height: AppSpacing.s12),
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

  /// 좌우 네비게이션 화살표
  Widget _buildNavigationArrows(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 0,
          onTap: _goToPrevious,
        ),
        SizedBox(width: AppSpacing.s24),
        _NavArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages - 1,
          onTap: () => _goToNext(totalPages),
        ),
      ],
    );
  }

  Future<bool> _handleUnlock(
    ExplorationNodeEntity region,
    int currentFuel,
  ) async {
    if (currentFuel < region.requiredFuel) {
      AppSnackBar.error(context, '연료가 부족합니다! (필요: ${region.requiredFuel}통)');
      return false;
    }

    var unlocked = false;

    await showUnlockDialog(
      context: context,
      nodeName: region.name,
      requiredFuel: region.requiredFuel,
      onUnlock: () async {
        await ref
            .read(regionListNotifierProvider(widget.planetId).notifier)
            .unlockRegion(region.id, region.requiredFuel);
        unlocked = true;
      },
    );

    return unlocked;
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
