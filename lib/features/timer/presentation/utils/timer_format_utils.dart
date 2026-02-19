/// DateTime을 날짜만(시·분·초 제거)으로 정규화
DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 분 단위 시간을 '시간 분' 포맷으로 변환
///
/// 예: 90 → '1시간 30분', 60 → '1시간', 25 → '25분'
String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0 && minutes > 0) return '$hours시간 $minutes분';
  if (hours > 0) return '$hours시간';
  return '$minutes분';
}
