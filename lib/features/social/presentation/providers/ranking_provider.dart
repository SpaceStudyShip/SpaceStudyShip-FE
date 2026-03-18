import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/ranking_entry_entity.dart';
import '../../domain/repositories/ranking_repository.dart';
import 'social_providers.dart';

part 'ranking_provider.g.dart';

@riverpod
List<RankingEntryEntity> rankingList(
  Ref ref,
  RankingType type,
  RankingPeriod period,
) {
  final repository = ref.watch(rankingRepositoryProvider);
  return repository.getRanking(type: type, period: period);
}
