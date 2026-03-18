import '../entities/ranking_entry_entity.dart';

enum RankingType { all, friends }

enum RankingPeriod { today, weekly, monthly }

abstract class RankingRepository {
  List<RankingEntryEntity> getRanking({
    required RankingType type,
    required RankingPeriod period,
  });
}
