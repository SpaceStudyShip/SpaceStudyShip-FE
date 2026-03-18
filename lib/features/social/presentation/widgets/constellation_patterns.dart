import 'dart:ui';

/// 북두칠성 별자리 좌표 패턴
///
/// 좌표는 0.0~1.0 비율 (화면 크기에 맞춰 스케일링)
/// index 0~5: 친구 자리, polaris: 나(북극성)
class ConstellationPatterns {
  ConstellationPatterns._();

  /// 북극성 (나) 위치
  static const Offset polaris = Offset(0.5, 0.55);

  /// 친구 6자리 (북두칠성 국자 모양)
  static const List<Offset> bigDipperSlots = [
    Offset(0.20, 0.25), // slot 0: 국자 끝
    Offset(0.35, 0.22), // slot 1
    Offset(0.50, 0.28), // slot 2
    Offset(0.62, 0.35), // slot 3: 국자 꺾이는 점
    Offset(0.72, 0.45), // slot 4: 손잡이
    Offset(0.80, 0.55), // slot 5: 손잡이 끝
  ];

  /// 별 연결선 (index 쌍)
  /// -1 = polaris(나)
  static const List<(int, int)> connections = [
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 5),
    (5, -1),
  ];
}
