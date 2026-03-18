import '../../domain/entities/ranking_entry_entity.dart';
import '../../domain/repositories/ranking_repository.dart';

class MockRankingRepository implements RankingRepository {
  @override
  List<RankingEntryEntity> getRanking({
    required RankingType type,
    required RankingPeriod period,
  }) {
    final baseMinutes = switch (period) {
      RankingPeriod.today => 60,
      RankingPeriod.weekly => 420,
      RankingPeriod.monthly => 1800,
    };

    final entries = [
      RankingEntryEntity(
        rank: 1,
        userId: 'u1',
        name: '김우주',
        studyTimeMinutes: baseMinutes,
        isMe: false,
      ),
      RankingEntryEntity(
        rank: 2,
        userId: 'u2',
        name: '이별님',
        studyTimeMinutes: (baseMinutes * 0.85).toInt(),
        isMe: false,
      ),
      RankingEntryEntity(
        rank: 3,
        userId: 'u3',
        name: '박성운',
        studyTimeMinutes: (baseMinutes * 0.7).toInt(),
        isMe: false,
      ),
      RankingEntryEntity(
        rank: 4,
        userId: 'u4',
        name: '최은하',
        studyTimeMinutes: (baseMinutes * 0.6).toInt(),
        isMe: false,
      ),
      RankingEntryEntity(
        rank: 5,
        userId: 'u5',
        name: '정항성',
        studyTimeMinutes: (baseMinutes * 0.5).toInt(),
        isMe: false,
      ),
      RankingEntryEntity(
        rank: 12,
        userId: 'me',
        name: '나',
        studyTimeMinutes: (baseMinutes * 0.2).toInt(),
        isMe: true,
      ),
    ];

    if (type == RankingType.friends) {
      return entries
          .where((e) => e.isMe || ['u1', 'u2', 'u3'].contains(e.userId))
          .toList();
    }
    return entries;
  }
}
