import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/mock_friend_repository.dart';
import '../../data/repositories/mock_group_repository.dart';
import '../../data/repositories/mock_ranking_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/ranking_repository.dart';

part 'social_providers.g.dart';

@riverpod
FriendRepository friendRepository(Ref ref) => MockFriendRepository();

@riverpod
GroupRepository groupRepository(Ref ref) => MockGroupRepository();

@riverpod
RankingRepository rankingRepository(Ref ref) => MockRankingRepository();
