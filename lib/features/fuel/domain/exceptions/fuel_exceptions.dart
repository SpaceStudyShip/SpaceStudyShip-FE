/// 연료 부족 예외
///
/// 연료 소비 시 보유량이 부족할 때 발생합니다.
class InsufficientFuelException implements Exception {
  final int requiredAmount;
  final int available;

  InsufficientFuelException({
    required this.requiredAmount,
    required this.available,
  });

  @override
  String toString() => '연료가 부족합니다 (필요: $requiredAmount통, 보유: $available통)';
}
