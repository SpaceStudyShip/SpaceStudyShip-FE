import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../exploration/domain/entities/exploration_node_entity.dart';
import '../../../exploration/presentation/providers/exploration_provider.dart';
import '../../../exploration/presentation/widgets/planet_node.dart';
import '../../../exploration/presentation/widgets/space_map_background.dart';
import '../../../exploration/presentation/widgets/space_map_painter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../../../core/utils/unlock_dialog_helper.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';

/// 탐험 스크린 - 우주 항로맵
///
/// 수직 스크롤 우주 맵에서 행성들을 탐색합니다.
/// 행성들이 지그재그로 배치되며 곡선 경로로 연결됩니다.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  /// 행성 간 세로 간격
  static final double _planetSpacing = 160.h;

  /// 맵 상단/하단 여백
  static final double _mapTopPadding = 40.h;
  static final double _mapBottomPadding = 80.h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFuel = ref.watch(currentFuelProvider);
    final isGuest = ref.watch(isGuestProvider);
    final planets = ref.watch(explorationNotifierProvider);

    // 현재 위치: 가장 마지막으로 해금된 행성
    var currentPlanetId = '';
    for (int i = planets.length - 1; i >= 0; i--) {
      if (planets[i].isUnlocked) {
        currentPlanetId = planets[i].id;
        break;
      }
    }

    // 상단/하단 inset 계산 (AppBar + 바텀 네비 영역까지 별 배경 확장)
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final bottomInset = MediaQuery.of(context).padding.bottom + 72.h;

    // 맵 전체 높이 계산 (AppBar + 바텀 네비 영역 포함)
    final mapHeight =
        topInset +
        _mapTopPadding +
        (planets.length - 1) * _planetSpacing +
        _mapBottomPadding +
        bottomInset;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '우주 탐험',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
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
      body: planets.isEmpty
          ? _buildEmptyState()
          : _buildSpaceMap(
              context,
              ref,
              planets,
              currentPlanetId,
              currentFuel,
              isGuest,
              mapHeight,
              topInset,
            ),
    );
  }

  Widget _buildSpaceMap(
    BuildContext context,
    WidgetRef ref,
    List<ExplorationNodeEntity> planets,
    String currentPlanetId,
    int currentFuel,
    bool isGuest,
    double mapHeight,
    double topInset,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // 행성 실제 위치 계산
        final planetOffsets = _calculatePlanetPositions(
          planets,
          screenWidth,
          mapHeight,
          topInset,
        );

        // 경로 페인터용 데이터
        final planetPositions = planets.map((p) {
          final offset = planetOffsets[p.id]!;
          return MapEntry(p.id, offset);
        }).toList();

        final unlockedIds = planets
            .where((p) => p.isUnlocked)
            .map((p) => p.id)
            .toSet();

        return SingleChildScrollView(
          child: SizedBox(
            width: screenWidth,
            height: mapHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Layer 1: 별 배경 (반짝임)
                Positioned.fill(child: SpaceMapBackground(height: mapHeight)),

                // Layer 2: 경로선 (CustomPainter)
                Positioned.fill(
                  child: CustomPaint(
                    painter: SpaceMapPainter(
                      planetPositions: planetPositions,
                      unlockedIds: unlockedIds,
                    ),
                  ),
                ),

                // Layer 3: 행성 노드들 (Positioned + ScaleIn)
                for (int i = 0; i < planets.length; i++)
                  Positioned(
                    left: planetOffsets[planets[i].id]!.dx - 40.w,
                    top: planetOffsets[planets[i].id]!.dy - 30.h,
                    child: ScaleIn(
                      delay: Duration(milliseconds: 100 + i * 80),
                      child: PlanetNode(
                        node: planets[i],
                        isCurrentLocation: planets[i].id == currentPlanetId,
                        onTap: () => _handlePlanetTap(
                          context,
                          ref,
                          planets[i],
                          currentFuel,
                          isGuest,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 행성 위치 계산 (지그재그 배치)
  Map<String, Offset> _calculatePlanetPositions(
    List<ExplorationNodeEntity> planets,
    double screenWidth,
    double mapHeight,
    double topInset,
  ) {
    final positions = <String, Offset>{};
    final nodeWidth = 80.w;
    final horizontalPadding = 20.w;
    final usableWidth = screenWidth - nodeWidth - horizontalPadding * 2;

    for (int i = 0; i < planets.length; i++) {
      final planet = planets[i];
      // mapX 비율을 실제 좌표로 변환
      final x = horizontalPadding + (nodeWidth / 2) + planet.mapX * usableWidth;
      final y = topInset + _mapTopPadding + i * _planetSpacing;
      positions[planet.id] = Offset(x, y);
    }
    return positions;
  }

  void _handlePlanetTap(
    BuildContext context,
    WidgetRef ref,
    ExplorationNodeEntity planet,
    int currentFuel,
    bool isGuest,
  ) {
    if (planet.isUnlocked) {
      context.push('/explore/planet/${planet.id}');
      return;
    }

    // 게스트 모드: 지구 외 행성은 로그인 필요
    if (isGuest) {
      _showLoginPrompt(context, ref);
      return;
    }

    // 이전 행성 미해금: 순서대로만 해금 가능
    final canUnlock = ref
        .read(explorationNotifierProvider.notifier)
        .canUnlockPlanet(planet.id);
    if (!canUnlock) {
      final planets = ref.read(explorationNotifierProvider);
      final targetIndex = planets.indexWhere((p) => p.id == planet.id);
      if (targetIndex > 0) {
        final prevPlanet = planets[targetIndex - 1];
        AppSnackBar.info(context, '${prevPlanet.name}을(를) 먼저 해금해야 합니다!');
      } else {
        AppSnackBar.info(context, '이전 행성을 먼저 해금해야 합니다!');
      }
      return;
    }

    // 잠긴 행성: 연료 부족
    if (currentFuel < planet.requiredFuel) {
      AppSnackBar.warning(context, '연료가 부족합니다! (필요: ${planet.requiredFuel}통)');
      return;
    }

    // 잠긴 행성: 연료 충분 + 이전 행성 해금됨 → 해금 다이얼로그
    showUnlockDialog(
      context: context,
      nodeName: planet.name,
      requiredFuel: planet.requiredFuel,
      onUnlock: () => ref
          .read(explorationNotifierProvider.notifier)
          .unlockPlanet(planet.id, planet.requiredFuel),
    );
  }

  Future<void> _showLoginPrompt(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '로그인하시겠어요?',
      message: '게스트 모드의 데이터가\n모두 초기화돼요',
      confirmText: '로그인',
      cancelText: '취소',
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  Widget _buildEmptyState() {
    return SpaceEmptyState(
      icon: Icons.explore_rounded,
      color: AppColors.secondary,
      title: '탐험할 행성이 없습니다',
      subtitle: '곧 새로운 행성이 추가됩니다!',
      iconSize: 80,
    );
  }
}
