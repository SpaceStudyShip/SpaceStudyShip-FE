/// 탐험 진행도 엔티티
///
/// 특정 노드(행성/지역)의 클리어 진행 상태를 표현합니다.
///
/// **사용 예시**:
/// ```dart
/// final progress = ExplorationProgressEntity(
///   nodeId: 'earth',
///   clearedChildren: 3,
///   totalChildren: 5,
/// );
/// print(progress.progressRatio); // 0.6
/// ```
class ExplorationProgressEntity {
  const ExplorationProgressEntity({
    required this.nodeId,
    required this.clearedChildren,
    required this.totalChildren,
    this.clearedAt,
  });

  /// 대상 노드 ID
  final String nodeId;

  /// 클리어된 자식 노드 수
  final int clearedChildren;

  /// 전체 자식 노드 수
  final int totalChildren;

  /// 클리어 완료 일시
  final DateTime? clearedAt;

  /// 진행률 (0.0 ~ 1.0)
  double get progressRatio =>
      totalChildren > 0 ? clearedChildren / totalChildren : 0.0;

  /// 클리어 완료 여부
  bool get isCompleted => clearedChildren >= totalChildren && totalChildren > 0;

  /// copyWith
  ExplorationProgressEntity copyWith({
    String? nodeId,
    int? clearedChildren,
    int? totalChildren,
    DateTime? clearedAt,
  }) {
    return ExplorationProgressEntity(
      nodeId: nodeId ?? this.nodeId,
      clearedChildren: clearedChildren ?? this.clearedChildren,
      totalChildren: totalChildren ?? this.totalChildren,
      clearedAt: clearedAt ?? this.clearedAt,
    );
  }
}
