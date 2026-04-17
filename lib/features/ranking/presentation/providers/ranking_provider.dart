import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ranking_entry.dart';

/// 현재 선택된 기간 (기본: 주간)
final rankingPeriodProvider = StateProvider<RankingPeriod>(
  (ref) => RankingPeriod.weekly,
);

/// 더미 랭킹 데이터 — API 연결 시 Repository로 교체
///
/// 기간별로 다른 시간이 나오도록 시뮬레이션.
final rankingProvider = Provider<List<RankingEntry>>((ref) {
  final period = ref.watch(rankingPeriodProvider);
  return _generateMockRanking(period);
});

/// 내 순위 (rankingProvider 안에서 isCurrentUser=true 인 항목의 인덱스 + 1)
final myRankProvider = Provider<int?>((ref) {
  final list = ref.watch(rankingProvider);
  final i = list.indexWhere((e) => e.isCurrentUser);
  return i == -1 ? null : i + 1;
});

List<RankingEntry> _generateMockRanking(RankingPeriod period) {
  // 기간에 따라 시간 스케일만 다르게
  final scale = switch (period) {
    RankingPeriod.daily => 1,
    RankingPeriod.weekly => 7,
    RankingPeriod.monthly => 30,
  };

  Duration h(int hours, [int minutes = 0]) =>
      Duration(hours: hours * scale, minutes: minutes);

  return [
    RankingEntry(userId: 'u1', userName: '김우주', studyDuration: h(8, 30)),
    RankingEntry(userId: 'u2', userName: '박탐험', studyDuration: h(7, 15)),
    RankingEntry(userId: 'u3', userName: '이별자리', studyDuration: h(6, 45)),
    RankingEntry(
      userId: 'me',
      userName: '나',
      studyDuration: h(5, 30),
      isCurrentUser: true,
    ),
    RankingEntry(userId: 'u5', userName: '강하늘', studyDuration: h(4, 50)),
    RankingEntry(userId: 'u6', userName: '서지우', studyDuration: h(3, 20)),
    RankingEntry(userId: 'u7', userName: '윤채린', studyDuration: h(2, 40)),
    RankingEntry(userId: 'u8', userName: '백승호', studyDuration: h(2, 10)),
    RankingEntry(userId: 'u9', userName: '문가람', studyDuration: h(1, 50)),
    RankingEntry(userId: 'u10', userName: '한은하', studyDuration: h(1, 0)),
  ];
}
