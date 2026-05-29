/// 지역 해금 결과
///
/// 게스트는 연료를 Notifier가 별도 차감하므로 [currentFuel]은 `-1`(미사용 센티넬).
/// 인증(서버) 경로는 서버가 차감 후 반환한 잔량을 담는다.
class RegionUnlockResultEntity {
  const RegionUnlockResultEntity({
    required this.planetCleared,
    required this.currentFuel,
  });

  /// 이 지역 해금으로 상위 행성이 모두 클리어되었는지
  final bool planetCleared;

  /// 해금 후 잔여 연료 (게스트: -1 센티넬)
  final int currentFuel;
}

/// 행성 해금 결과
class PlanetUnlockResultEntity {
  const PlanetUnlockResultEntity({required this.currentFuel});

  /// 해금 후 잔여 연료 (게스트: -1 센티넬)
  final int currentFuel;
}
