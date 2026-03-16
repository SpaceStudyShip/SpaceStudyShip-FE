/// 타이머 모드 식별 상수
const basicTimerAsset = 'basic';

/// 타이머 애니메이션 데이터
class TimerAnimationData {
  const TimerAnimationData({required this.asset, required this.name});

  final String asset;
  final String name;

  /// 기본값: 기본 타이머 (원형 링 + 숫자)
  static const defaultAsset = basicTimerAsset;

  static const List<TimerAnimationData> animations = [
    TimerAnimationData(asset: basicTimerAsset, name: '기본 타이머'),
    TimerAnimationData(
      asset: 'assets/lotties/Earth_and_Connections.json',
      name: '지구와 연결',
    ),
    TimerAnimationData(
      asset: 'assets/lotties/Travel_the_World.json',
      name: '세계 여행',
    ),
  ];

  static bool isValidAsset(String asset) {
    return animations.any((a) => a.asset == asset);
  }

  /// Lottie 애니메이션인지 여부
  bool get isLottie => asset != basicTimerAsset;
}
