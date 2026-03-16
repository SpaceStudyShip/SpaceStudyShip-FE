import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/planet_icons.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/navigation_providers.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../providers/exploration_provider.dart';
import '../widgets/exploration_progress_bar.dart';
import '../widgets/region_flag_icon.dart';

/// 탐험 상세 스크린 - 우주 티켓 3D 플립
///
/// 앞면: 우주 탐험 티켓 (행성 정보 + 바코드 + CTA)
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
    with SingleTickerProviderStateMixin {
  // 플립 애니메이션
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _showFront = true;

  // 플로팅 네비 notifier 캐싱
  late final StateController<bool> _navNotifier;

  @override
  void initState() {
    super.initState();
    _navNotifier = ref.read(showFloatingNavProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navNotifier.state = false;
    });

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );
    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_flipController.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });
  }

  @override
  void dispose() {
    try {
      _navNotifier.state = true;
    } catch (_) {}
    _flipController.dispose();
    super.dispose();
  }

  void _flipToBack() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
  }

  void _flipToFront() {
    if (_flipController.isAnimating) return;
    _flipController.reverse();
  }

  void _goBack() {
    _navNotifier.state = true;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) => planets.where((p) => p.id == widget.planetId).firstOrNull,
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

          // AppBar (카드 바깥, 항상 보임)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(bottom: false, child: _buildAppBarRow(title: null)),
          ),

          // 티켓 카드 (3D 플립)
          Positioned(
            left: AppSpacing.s20,
            right: AppSpacing.s20,
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.s20,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, _) {
                final angle = _flipAnimation.value * pi;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: _showFront
                      ? _buildTicketFront(planet, progress)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildTicketBack(planet, regions, currentFuel),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 앞면: 우주 탐험 티켓 ──────────────────────────────

  Widget _buildTicketFront(
    ExplorationNodeEntity planet,
    ExplorationProgressEntity progress,
  ) {
    final planetColor = PlanetIcons.colorOf(planet.icon);
    final percent = (progress.progressRatio * 100).toInt();
    final ticketCode = _generateTicketCode(planet.id);

    return GestureDetector(
      onTap: _flipToBack,
      child: SizedBox.expand(
        child: ClipPath(
          clipper: _TicketClipper(notchRadius: 12.w),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  planetColor.withValues(alpha: 0.15),
                  AppColors.spaceSurface,
                ],
                stops: const [0.0, 0.85],
              ),
            ),
            child: Column(
              children: [
                // ① Primary / Strong — 티켓 코드
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticketCode,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'SPACE PASS',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ② 중심 시각 앵커 — 행성 아이콘 + 이름
                PlanetIcons.buildIcon(planet.icon, size: 220.w),
                SizedBox(height: AppSpacing.s16),
                Text(
                  planet.name,
                  style: AppTextStyles.heading_24.copyWith(color: Colors.white),
                ),
                if (planet.description.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.s8),
                  Text(
                    planet.description,
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                SizedBox(height: AppSpacing.s32),

                // ③ 진행도
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.s8),
                      ExplorationProgressBar(progress: progress, height: 4.h),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // ── 절취선 + 펀치홀 ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  child: _buildTearLine(),
                ),

                const Spacer(flex: 1),

                // ④ Weak Fallow — 바코드
                Padding(
                  padding: AppPadding.horizontal20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pass',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s8),
                      SizedBox(
                        height: 48.h,
                        width: double.infinity,
                        child: SvgPicture.asset(
                          progress.isCompleted
                              ? 'assets/icons/barcode_mint.svg'
                              : 'assets/icons/barcode_lavender.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.s64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 뒷면: 지역 목록 ──────────────────────────────────

  Widget _buildTicketBack(
    ExplorationNodeEntity planet,
    List<ExplorationNodeEntity> regions,
    int currentFuel,
  ) {
    return SizedBox.expand(
      child: ClipPath(
        clipper: _TicketClipper(notchRadius: 12.w),
        child: Container(
          color: AppColors.spaceSurface,
          child: Column(
            children: [
              // 상단: 티켓코드 + 연료 + 시각적 플립 유도 (탭 → 플립 복귀)
              GestureDetector(
                onTap: _flipToFront,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _generateTicketCode(planet.id),
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.textTertiary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          FuelGauge(
                            currentFuel: currentFuel,
                            showLabel: true,
                            size: FuelGaugeSize.medium,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.s12),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20.w,
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: AppSpacing.s4),
                      _buildTearLine(),
                      SizedBox(height: AppSpacing.s12),
                    ],
                  ),
                ),
              ),

              // 3열 아이콘 그리드
              Expanded(
                child: regions.isNotEmpty
                    ? GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.s20,
                          AppSpacing.s20,
                          AppSpacing.s20,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: AppSpacing.s12,
                          mainAxisSpacing: AppSpacing.s12,
                        ),
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          return _buildGridCell(planet, region);
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
      ),
    );
  }

  /// 그리드 셀: 국기 + 이름 + 상태 텍스트
  Widget _buildGridCell(
    ExplorationNodeEntity planet,
    ExplorationNodeEntity region,
  ) {
    final isLocked = !region.isUnlocked;
    final statusText = region.isCleared
        ? '클리어'
        : isLocked
        ? '잠김'
        : '';
    final statusColor = region.isCleared
        ? AppColors.success
        : AppColors.textTertiary;

    // 외부 라디우스 = 내부 라디우스(4) x 2 = 8 (AppRadius.medium)
    return GestureDetector(
      onTap: () =>
          context.push('/explore/location/${region.id}?planetId=${planet.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.medium,
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: region.isCleared
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.spaceDivider.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RegionFlagIcon(icon: region.icon, size: 40.w, isLocked: isLocked),
            SizedBox(height: AppSpacing.s8),
            Text(
              region.name,
              style: AppTextStyles.tag_12.copyWith(
                color: isLocked ? AppColors.textTertiary : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (statusText.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s4),
              Text(
                statusText,
                style: AppTextStyles.tag_10.copyWith(color: statusColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── 공용 위젯 ─────────────────────────────────────────

  Widget _buildAppBarRow({String? title}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s4,
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
            onPressed: _goBack,
          ),
          if (title != null) ...[
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
            const Spacer(),
          ] else
            const Spacer(),
        ],
      ),
    );
  }

  /// 절취선 (점선 + 펀치홀은 ClipPath에서 처리)
  Widget _buildTearLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 4.w;
        final dashSpace = 4.w;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dashCount, (_) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dashSpace / 2),
              child: Container(
                width: dashWidth,
                height: 1,
                color: AppColors.spaceDivider.withValues(alpha: 0.5),
              ),
            );
          }),
        );
      },
    );
  }

  /// 행성 ID 기반 티켓 코드 생성
  String _generateTicketCode(String planetId) {
    final code = planetId.toUpperCase().replaceAll('_', '-');
    return 'SP-$code';
  }
}

// ─── 티켓 펀치홀 클리퍼 ─────────────────────────────────

/// 티켓 양쪽에 반원 노치를 만드는 CustomClipper
///
/// 카드 높이의 약 65% 지점에 펀치홀을 배치합니다 (절취선 위치).
class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({required this.notchRadius});

  final double notchRadius;

  @override
  Path getClip(Size size) {
    final notchY = size.height * 0.65;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(24.r), // AppRadius.xxlarge 값
        ),
      )
      // 왼쪽 펀치홀
      ..addOval(Rect.fromCircle(center: Offset(0, notchY), radius: notchRadius))
      // 오른쪽 펀치홀
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, notchY),
          radius: notchRadius,
        ),
      )
      ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius;
}
