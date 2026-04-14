import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_entity.freezed.dart';

enum FriendStatus { studying, idle, offline }

@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    required FriendStatus status,
    Duration? studyDuration,
    String? currentSubject,
    Duration? weeklyStudyDuration,
  }) = _FriendEntity;
}
