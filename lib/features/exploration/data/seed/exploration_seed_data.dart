import '../../domain/entities/exploration_node_entity.dart';

/// 탐험 노드 시드 데이터
///
/// 정적 노드 정의. 해금/클리어 상태는 기본값(false).
/// 서버 연동 시 API 응답으로 교체 예정.
class ExplorationSeedData {
  ExplorationSeedData._();

  static const List<ExplorationNodeEntity> planets = [
    ExplorationNodeEntity(
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
    ExplorationNodeEntity(
      id: 'moon',
      name: '달',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🌙',
      requiredFuel: 5,
      sortOrder: 1,
      description: '지구의 유일한 자연 위성',
      mapX: 0.15,
      mapY: 0.30,
    ),
    ExplorationNodeEntity(
      id: 'mars',
      name: '화성',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🔴',
      requiredFuel: 15,
      sortOrder: 2,
      description: '붉은 행성, 탐험의 꿈',
      mapX: 0.75,
      mapY: 0.55,
    ),
    ExplorationNodeEntity(
      id: 'jupiter',
      name: '목성',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🟤',
      requiredFuel: 30,
      sortOrder: 3,
      description: '태양계 최대의 가스 행성',
      mapX: 0.3,
      mapY: 0.78,
    ),
  ];

  static const Map<String, List<ExplorationNodeEntity>> regions = {
    'earth': [
      // === 아시아 ===
      ExplorationNodeEntity(
        id: 'korea',
        name: '대한민국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'KR',
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
        icon: 'JP',
        parentId: 'earth',
        requiredFuel: 1,
        sortOrder: 1,
        description: '벚꽃과 기술의 나라',
      ),
      ExplorationNodeEntity(
        id: 'thailand',
        name: '태국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'TH',
        parentId: 'earth',
        requiredFuel: 1,
        sortOrder: 2,
        description: '미소의 나라, 동남아의 허브',
      ),
      ExplorationNodeEntity(
        id: 'china',
        name: '중국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'CN',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 3,
        description: '세계 최대 인구 대국',
      ),
      ExplorationNodeEntity(
        id: 'india',
        name: '인도',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'IN',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 4,
        description: 'IT 강국, 다양한 문화의 보고',
      ),
      // === 유럽 ===
      ExplorationNodeEntity(
        id: 'uk',
        name: '영국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'GB',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 5,
        description: '해가 지지 않는 나라',
      ),
      ExplorationNodeEntity(
        id: 'france',
        name: '프랑스',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'FR',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 6,
        description: '예술과 낭만의 나라',
      ),
      // === 북미 ===
      ExplorationNodeEntity(
        id: 'canada',
        name: '캐나다',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'CA',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 7,
        description: '단풍과 자연의 나라',
      ),
      ExplorationNodeEntity(
        id: 'usa',
        name: '미국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'US',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 8,
        description: '자유의 나라, 기회의 땅',
      ),
      // === 남미 ===
      ExplorationNodeEntity(
        id: 'brazil',
        name: '브라질',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'BR',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 9,
        description: '삼바와 축구의 나라',
      ),
      // === 오세아니아 ===
      ExplorationNodeEntity(
        id: 'australia',
        name: '호주',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'AU',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 10,
        description: '코알라와 캥거루의 대륙',
      ),
      // === 아프리카 ===
      ExplorationNodeEntity(
        id: 'egypt',
        name: '이집트',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'EG',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 11,
        description: '피라미드와 나일강의 나라',
      ),
    ],
  };

  /// 특정 행성의 지역 목록 반환
  static List<ExplorationNodeEntity> getRegions(String planetId) {
    return regions[planetId] ?? [];
  }

  /// 특정 행성 반환
  static ExplorationNodeEntity getPlanet(String planetId) {
    return planets.firstWhere(
      (p) => p.id == planetId,
      orElse: () => planets.first,
    );
  }
}
