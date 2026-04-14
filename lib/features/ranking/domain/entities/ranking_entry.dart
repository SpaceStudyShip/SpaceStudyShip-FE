/// 랭킹 항목 (한 명의 랭커)
///
/// 랭킹 화면에서 한 줄로 표시될 데이터.
/// API 연결 시 freezed로 교체 가능.
class RankingEntry {
  const RankingEntry({
    required this.userId,
    required this.userName,
    required this.studyDuration,
    this.isCurrentUser = false,
  });

  final String userId;
  final String userName;
  final Duration studyDuration;
  final bool isCurrentUser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingEntry &&
          other.userId == userId &&
          other.userName == userName &&
          other.studyDuration == studyDuration &&
          other.isCurrentUser == isCurrentUser;

  @override
  int get hashCode =>
      Object.hash(userId, userName, studyDuration, isCurrentUser);
}

/// 랭킹 기간 필터
enum RankingPeriod { daily, weekly, monthly }
