import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/friend_entity.dart';
import 'social_providers.dart';

part 'friend_provider.g.dart';

@riverpod
List<FriendEntity> friendList(Ref ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
}
