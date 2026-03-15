import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/planet_icons.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/utils/unlock_dialog_helper.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/navigation_providers.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../providers/exploration_provider.dart';
import '../widgets/exploration_progress_bar.dart';
import '../widgets/region_card.dart';

/// 탐험 상세 스크린 - 3D 카드 플립
///
/// 앞면: 행성 정보 (아이콘, 이름, 설명, 진행도)
/// 뒷면: 지역 카드 리스트 (연료 게이지 + 스크롤)
/// "지역 탐험하기" 탭 시 Y축 3D 플립으로 전환됩니다.
class ExplorationDetailScreen extends ConsumerStatefulWidget {
  const ExplorationDetailScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<ExplorationDetailScreen> createState() =>
      _ExplorationDetailScreenState();
}

class _ExplorationDetailScreenState
    extends ConsumerState<ExplorationDetailScreen>
    with TickerProviderStateMixin {
  // 플립 애니메이션
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _showFront = true;

  // 바운스 애니메이션 (앞면 "지역 탐험하기")
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // 플로팅 네비 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showFloatingNavProvider.notifier).state = false;
    });

    // 플립 애니메이션
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    );

    // 면 전환 리스너: 0.5 지점에서 앞↔뒤 토글
    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_flipController.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    // 바운스 애니메이션 (기존 유지)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // 플로팅 네비 복원 (위젯 트리 빌드 후 안전하게 실행)
    Future(() {
      if (ref.context.mounted) {
        ref.read(showFloatingNavProvider.notifier).state = true;
      }
    });
    _flipController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// 앞면 → 뒷면 플립
  void _flipToBack() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
  }

  /// 뒷면 → 앞면 역플립
  void _flipToFront() {
    if (_flipController.isAnimating) return;
    _flipController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) =>
            planets.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );
    if (planet == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }
    final regions = ref.watch(regionListNotifierProvider(widget.planetId));
    final progress = ref.watch(explorationProgressProvider(widget.planetId));
    final currentFuel = ref.watch(currentFuelProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),

          // 3D 플립 카드
          AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, _) {
              final angle = _flipAnimation.value * pi;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: _showFront
                    ? _buildFrontFace(planet, progress)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _buildBackFace(
                          planet,
                          regions,
                          currentFuel,
                          progress,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 앞면: 행성 정보
  Widget _buildFrontFace(
    ExplorationNodeEntity planet,
    ExplorationProgressEntity progress,
  ) {
    final planetColor = PlanetIcons.colorOf(planet.icon);
    final percent = (progress.progressRatio * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            planetColor.withValues(alpha: 0.15),
            AppColors.spaceBackground,
          ],
          stops: const [0.0, 0.85],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AppBar 영역
            _buildAppBarRow(),

            const Spacer(flex: 3),

            // 행성 아이콘
            PlanetIcons.buildIcon(planet.icon, size: 160.w),
            SizedBox(height: AppSpacing.s20),

            // 행성 이름
            Text(
              planet.name,
              style: AppTextStyles.heading_24.copyWith(color: Colors.white),
            ),

            // 설명
            if (planet.description.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s8),
              Text(
                planet.description,
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            SizedBox(height: AppSpacing.s40),

            // 진행도
            Padding(
              padding: AppPadding.horizontal20,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '탐험 진행도',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: AppTextStyles.tag_12.copyWith(
                          color: progress.isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                          fontFamily: 'Pretendard-SemiBold',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s8),
                  ExplorationProgressBar(progress: progress, height: 4.h),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // "지역 탐험하기" → 플립
            GestureDetector(
              onTap: _flipToBack,
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Text(
                      '지역 탐험하기',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                      size: 24.w,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }

  /// 뒷면: 지역 목록
  Widget _buildBackFace(
    ExplorationNodeEntity planet,
    List<ExplorationNodeEntity> regions,
    int currentFuel,
    ExplorationProgressEntity progress,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColors.spaceBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar (행성 이름 + 플립 복귀)
            _buildAppBarRow(
              title: planet.name,
              showFlipButton: true,
            ),

            // 연료 게이지 (우측 정렬)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FuelGauge(
                    currentFuel: currentFuel,
                    showLabel: true,
                    size: FuelGaugeSize.medium,
                  ),
                ],
              ),
            ),

            // 지역 리스트
            Expanded(
              child: regions.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        AppSpacing.s12,
                        AppSpacing.s20,
                        AppSpacing.s32 + bottomPadding,
                      ),
                      itemCount: regions.length,
                      itemBuilder: (context, index) {
                        final region = regions[index];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 60 * index),
                          child: RegionCard(
                            node: region,
                            currentFuel: currentFuel,
                            onUnlock: () => _handleUnlock(
                              context,
                              region,
                              currentFuel,
                              ref,
                            ),
                            onTap: () {
                              if (region.isCleared) {
                                AppSnackBar.info(
                                  context,
                                  '${region.name} - 이미 클리어한 지역입니다!',
                                );
                              }
                            },
                          ),
                        );
                      },
                    )
                  : SpaceEmptyState(
                      icon: Icons.public_rounded,
                      color: AppColors.secondary,
                      title: '아직 탐험할 지역이 없습니다',
                      subtitle: '향후 업데이트에서 추가됩니다!',
                      iconSize: 64,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 공통 AppBar 행
  Widget _buildAppBarRow({
    String? title,
    bool showFlipButton = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s4,
        0,
      ),
      child: Row(
        children: [
          // ← 뒤로가기 (양면 공통)
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20.w,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // 타이틀 (뒷면에서만)
          if (title != null) ...[
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
            const Spacer(),
          ] else
            const Spacer(),

          // 플립 복귀 버튼 (뒷면에서만)
          if (showFlipButton)
            IconButton(
              icon: Icon(
                Icons.flip_rounded,
                color: Colors.white,
                size: 22.w,
              ),
              onPressed: _flipToFront,
            )
          else
            SizedBox(width: 48.w),
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
          .read(regionListNotifierProvider(widget.planetId).notifier)
          .unlockRegion(region.id, region.requiredFuel),
    );
  }
}
