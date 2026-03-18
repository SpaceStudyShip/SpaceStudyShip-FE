import 'package:freezed_annotation/freezed_annotation.dart';

import 'friend_entity.dart';

part 'group_member_entity.freezed.dart';

@freezed
class GroupMemberEntity with _$GroupMemberEntity {
  const factory GroupMemberEntity({
    required String id,
    required String name,
    String? avatarUrl,
    required OnlineStatus status,
    required int seatIndex,
  }) = _GroupMemberEntity;
}
