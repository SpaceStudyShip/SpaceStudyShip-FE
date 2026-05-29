// 탐험 해금 도메인 예외.
//
// 연료 부족(`INSUFFICIENT_FUEL`)은 별도 클래스를 만들지 않고 fuel 도메인의
// 기존 `InsufficientFuelException`을 재사용한다 (showUnlockDialog가 이미 catch).
// 아래 예외들은 화면 사전검증을 통과한 레이스 상황의 안전망이다.

/// 이미 해금된 노드 (`ALREADY_UNLOCKED`)
class NodeAlreadyUnlockedException implements Exception {
  const NodeAlreadyUnlockedException([this.message = '이미 해금된 곳입니다.']);
  final String message;
  @override
  String toString() => 'NodeAlreadyUnlockedException: $message';
}

/// 상위 행성이 잠겨 지역을 해금할 수 없음 (`PLANET_LOCKED`)
class PlanetLockedException implements Exception {
  const PlanetLockedException([this.message = '먼저 행성을 해금해야 합니다.']);
  final String message;
  @override
  String toString() => 'PlanetLockedException: $message';
}

/// 선행 행성 미클리어로 해금 불가 (`PREREQUISITE_NOT_CLEARED`)
class PrerequisiteNotClearedException implements Exception {
  const PrerequisiteNotClearedException([
    this.message = '이전 행성을 먼저 클리어해야 합니다.',
  ]);
  final String message;
  @override
  String toString() => 'PrerequisiteNotClearedException: $message';
}

/// 노드 미존재 (`REGION_NOT_FOUND` / `PLANET_NOT_FOUND`)
class ExplorationNodeNotFoundException implements Exception {
  const ExplorationNodeNotFoundException([
    this.message = '해당 탐험 지점을 찾을 수 없습니다.',
  ]);
  final String message;
  @override
  String toString() => 'ExplorationNodeNotFoundException: $message';
}
