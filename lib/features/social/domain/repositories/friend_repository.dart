import '../entities/friend_entity.dart';

abstract class FriendRepository {
  List<FriendEntity> getFriends();
  Future<void> addFriend(String friendId);
  Future<void> removeFriend(String friendId);
}
