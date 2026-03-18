import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/group_repository.dart';

class MockGroupRepository implements GroupRepository {
  @override
  List<GroupEntity> getGroups() {
    return const [
      GroupEntity(
        id: 'g1',
        name: '알고리즘 스터디',
        maxSeats: 4,
        inviteCode: 'ALG-7X2',
        members: [
          GroupMemberEntity(
            id: 'me',
            name: '나',
            status: OnlineStatus.online,
            seatIndex: 0,
          ),
          GroupMemberEntity(
            id: '1',
            name: '김우주',
            status: OnlineStatus.online,
            seatIndex: 1,
          ),
        ],
      ),
      GroupEntity(
        id: 'g2',
        name: '토익 900+',
        maxSeats: 4,
        inviteCode: 'TOE-3K9',
        members: [
          GroupMemberEntity(
            id: 'me',
            name: '나',
            status: OnlineStatus.online,
            seatIndex: 0,
          ),
          GroupMemberEntity(
            id: '2',
            name: '이별님',
            status: OnlineStatus.away,
            seatIndex: 1,
          ),
          GroupMemberEntity(
            id: '3',
            name: '박성운',
            status: OnlineStatus.offline,
            seatIndex: 2,
          ),
          GroupMemberEntity(
            id: '4',
            name: '최은하',
            status: OnlineStatus.online,
            seatIndex: 3,
          ),
        ],
      ),
    ];
  }

  @override
  GroupEntity? getGroupById(String id) {
    return getGroups().where((g) => g.id == id).firstOrNull;
  }

  @override
  Future<GroupEntity> createGroup(String name) async {
    return GroupEntity(
      id: 'new',
      name: name,
      maxSeats: 4,
      inviteCode: 'NEW-001',
      members: const [],
    );
  }

  @override
  Future<void> joinGroup(String inviteCode) async {}
}
