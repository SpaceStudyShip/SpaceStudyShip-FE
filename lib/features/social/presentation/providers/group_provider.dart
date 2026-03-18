import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/group_entity.dart';
import 'social_providers.dart';

part 'group_provider.g.dart';

@riverpod
List<GroupEntity> groupList(Ref ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroups();
}

@riverpod
GroupEntity? groupDetail(Ref ref, String groupId) {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroupById(groupId);
}
