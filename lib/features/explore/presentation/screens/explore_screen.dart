import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../exploration/domain/entities/exploration_node_entity.dart';
import '../../../exploration/domain/entities/exploration_progress_entity.dart';
import '../../../exploration/presentation/widgets/planet_node.dart';
import '../../../exploration/presentation/widgets/space_map_background.dart';
import '../../../exploration/presentation/widgets/space_map_painter.dart';
import '../../../../core/widgets/space/fuel_gauge.dart';

/// 탐험 스크린 - 우주 항로맵
///
/// 수직 스크롤 우주 맵에서 행성들을 탐색합니다.
/// 행성들이 지그재그로 배치되며 곡선 경로로 연결됩니다.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  /// 행성 간 세로 간격
  static final double _planetSpacing = 160.h;

  /// 맵 상단/하단 여백
  static final double _mapTopPadding = 40.h;
  static final double _mapBottomPadding = 80.h;

  @override
  Widget build(BuildContext context) {
    // TODO: Riverpod Provider 연결 후 제거
    final currentFuel = 3.5;
    final planets = _samplePlanets;
    final progressMap = _sampleProgressMap;

    // 현재 위치: 가장 마지막으로 해금된 행성
    final currentPlanetId = planets
        .where((p) => p.isUnlocked)
        .toList()
        .last
        .id;

    // 상단/하단 inset 계산 (AppBar + 바텀 네비 영역까지 별 배경 확장)
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final bottomInset = MediaQuery.of(context).padding.bottom + 72.h;

    // 맵 전체 높이 계산 (AppBar + 바텀 네비 영역 포함)
    final mapHeight = topInset +
        _mapTopPadding +
        (planets.length - 1) * _planetSpacing +
        _mapBottomPadding +
        bottomInset;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '우주 탐험',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: AppRadius.xlarge,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: FuelGauge(
              currentFuel: currentFuel,
              showLabel: false,
              size: FuelGaugeSize.small,
            ),
          ),
        ],
      ),
      body: planets.isEmpty
          ? _buildEmptyState()
          : _buildSpaceMap(
              context, planets, progressMap, currentPlanetId, mapHeight,
              topInset),
    );
  }

  Widget _buildSpaceMap(
    BuildContext context,
    List<ExplorationNodeEntity> planets,
    Map<String, ExplorationProgressEntity> progressMap,
    String currentPlanetId,
    double mapHeight,
    double topInset,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // 행성 실제 위치 계산
        final planetOffsets = _calculatePlanetPositions(
          planets, screenWidth, mapHeight, topInset,
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
                Positioned.fill(
                  child: SpaceMapBackground(height: mapHeight),
                ),

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
                        progress: progressMap[planets[i].id],
                        isCurrentLocation: planets[i].id == currentPlanetId,
                        onTap: () => _handlePlanetTap(context, planets[i]),
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

  void _handlePlanetTap(BuildContext context, ExplorationNodeEntity planet) {
    if (!planet.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '연료 ${planet.requiredFuel.toStringAsFixed(1)}통이 필요합니다',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    context.push('/explore/planet/${planet.id}');
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

  // ═══════════════════════════════════════════════════
  // 임시 샘플 데이터 (Riverpod Provider 연결 후 제거)
  // ═══════════════════════════════════════════════════

  List<ExplorationNodeEntity> get _samplePlanets => [
        const ExplorationNodeEntity(
          id: 'earth',
          name: '지구',
          nodeType: ExplorationNodeType.planet,
          depth: 2,
          icon: '🌍',
          requiredFuel: 0,
          isUnlocked: true,
          sortOrder: 0,
          description: '우리의 출발지, 고향 행성',
          mapX: 0.5,
          mapY: 0.08,
        ),
        const ExplorationNodeEntity(
          id: 'moon',
          name: '달',
          nodeType: ExplorationNodeType.planet,
          depth: 2,
          icon: '🌙',
          requiredFuel: 5.0,
          isUnlocked: false,
          sortOrder: 1,
          description: '지구의 유일한 자연 위성',
          mapX: 0.15,
          mapY: 0.30,
        ),
        const ExplorationNodeEntity(
          id: 'mars',
          name: '화성',
          nodeType: ExplorationNodeType.planet,
          depth: 2,
          icon: '🔴',
          requiredFuel: 15.0,
          isUnlocked: false,
          sortOrder: 2,
          description: '붉은 행성, 탐험의 꿈',
          mapX: 0.75,
          mapY: 0.55,
        ),
        const ExplorationNodeEntity(
          id: 'jupiter',
          name: '목성',
          nodeType: ExplorationNodeType.planet,
          depth: 2,
          icon: '🟤',
          requiredFuel: 30.0,
          isUnlocked: false,
          sortOrder: 3,
          description: '태양계 최대의 가스 행성',
          mapX: 0.3,
          mapY: 0.78,
        ),
      ];

  Map<String, ExplorationProgressEntity> get _sampleProgressMap => {
        'earth': const ExplorationProgressEntity(
          nodeId: 'earth',
          clearedChildren: 1,
          totalChildren: 5,
        ),
      };
}
