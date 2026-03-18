import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_entry_entity.freezed.dart';

@freezed
class RankingEntryEntity with _$RankingEntryEntity {
  const factory RankingEntryEntity({
    required int rank,
    required String userId,
    required String name,
    String? avatarUrl,
    required int studyTimeMinutes,
    required bool isMe,
  }) = _RankingEntryEntity;
}
