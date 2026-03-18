import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';

class MockFriendRepository implements FriendRepository {
  @override
  List<FriendEntity> getFriends() {
    return const [
      FriendEntity(
        id: '1',
        name: '김우주',
        status: OnlineStatus.online,
        slotIndex: 0,
      ),
      FriendEntity(
        id: '2',
        name: '이별님',
        status: OnlineStatus.away,
        slotIndex: 1,
      ),
      FriendEntity(
        id: '3',
        name: '박성운',
        status: OnlineStatus.offline,
        slotIndex: 2,
      ),
    ];
  }

  @override
  Future<void> addFriend(String friendId) async {}

  @override
  Future<void> removeFriend(String friendId) async {}
}
