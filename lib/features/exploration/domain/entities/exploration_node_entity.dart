/// 탐험 노드 타입
///
/// 우주 계층 구조에 맞는 노드 분류입니다.
/// MVP: planet, region만 사용. galaxy, starSystem은 확장용으로 선언.
enum ExplorationNodeType {
  /// 은하 (확장용)
  galaxy,

  /// 항성계 (확장용)
  starSystem,

  /// 행성 - MVP (지구, 화성 등)
  planet,

  /// 지역 - MVP (대한민국, 일본 등)
  region,
}

/// 탐험 노드 엔티티 - 통합 트리 구조
///
/// 모든 탐험 계층(은하, 항성계, 행성, 지역)을 하나의 엔티티로 표현합니다.
/// 트리 구조로 무한 확장 가능합니다.
///
/// **클리어 조건**:
/// - Region: 연료를 소비하여 해금 → 클리어
/// - Planet: 하위 Region 전부 클리어 시 자동 클리어
class ExplorationNodeEntity {
  const ExplorationNodeEntity({
    required this.id,
    required this.name,
    required this.nodeType,
    required this.depth,
    required this.icon,
    this.parentId,
    required this.requiredFuel,
    this.isUnlocked = false,
    this.isCleared = false,
    this.sortOrder = 0,
    this.description = '',
    this.mapX = 0.5,
    this.mapY = 0.0,
  });

  /// 노드 고유 ID
  final String id;

  /// 노드 이름 (지구, 대한민국 등)
  final String name;

  /// 노드 타입 (galaxy, starSystem, planet, region)
  final ExplorationNodeType nodeType;

  /// 계층 깊이 (0=galaxy, 1=starSystem, 2=planet, 3=region)
  final int depth;

  /// 아이콘 (행성: 이모지 🌍 / 지역: 국가 코드 KR)
  final String icon;

  /// 상위 노드 ID (null = 최상위)
  final String? parentId;

  /// 해금에 필요한 연료
  final int requiredFuel;

  /// 해금 여부
  final bool isUnlocked;

  /// 클리어 여부
  final bool isCleared;

  /// 표시 순서
  final int sortOrder;

  /// 간단한 설명
  final String description;

  /// 맵 가로 위치 (0.0 ~ 1.0 비율)
  final double mapX;

  /// 맵 세로 위치 (0.0 ~ 1.0 비율)
  final double mapY;

  /// copyWith
  ExplorationNodeEntity copyWith({
    String? id,
    String? name,
    ExplorationNodeType? nodeType,
    int? depth,
    String? icon,
    String? parentId,
    int? requiredFuel,
    bool? isUnlocked,
    bool? isCleared,
    int? sortOrder,
    String? description,
    double? mapX,
    double? mapY,
  }) {
    return ExplorationNodeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nodeType: nodeType ?? this.nodeType,
      depth: depth ?? this.depth,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      requiredFuel: requiredFuel ?? this.requiredFuel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCleared: isCleared ?? this.isCleared,
      sortOrder: sortOrder ?? this.sortOrder,
      description: description ?? this.description,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
    );
  }
}
