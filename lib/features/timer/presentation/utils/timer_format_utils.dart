/// 분 단위 시간을 '시간 분' 포맷으로 변환
///
/// 예: 90 → '1시간 30분', 25 → '25분'
String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0) return '$hours시간 $minutes분';
  return '$minutes분';
}
