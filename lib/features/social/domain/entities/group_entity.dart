import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_member_entity.dart';

part 'group_entity.freezed.dart';

@freezed
class GroupEntity with _$GroupEntity {
  const factory GroupEntity({
    required String id,
    required String name,
    required int maxSeats,
    required List<GroupMemberEntity> members,
    required String inviteCode,
  }) = _GroupEntity;
}
