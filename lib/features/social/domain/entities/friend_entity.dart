import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_entity.freezed.dart';

enum OnlineStatus { online, away, offline }

@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    String? avatarUrl,
    required OnlineStatus status,
    required int slotIndex,
  }) = _FriendEntity;
}
