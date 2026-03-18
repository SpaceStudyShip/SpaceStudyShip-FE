import '../entities/group_entity.dart';

abstract class GroupRepository {
  List<GroupEntity> getGroups();
  GroupEntity? getGroupById(String id);
  Future<GroupEntity> createGroup(String name);
  Future<void> joinGroup(String inviteCode);
}
