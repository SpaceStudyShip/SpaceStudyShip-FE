import '../../domain/entities/badge_entity.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_local_datasource.dart';
import '../models/badge_model.dart';
import '../seed/badge_seed_data.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeLocalDataSource _localDataSource;

  BadgeRepositoryImpl(this._localDataSource);

  @override
  List<BadgeEntity> getAllBadges() {
    final unlocked = _localDataSource.getUnlockedBadges();
    return BadgeSeedData.allBadges.map((badge) {
      final unlock = unlocked[badge.id];
      if (unlock != null) {
        return badge.copyWith(isUnlocked: true, unlockedAt: unlock.unlockedAt);
      }
      return badge;
    }).toList();
  }

  @override
  List<BadgeEntity> getUnlockedBadges() {
    return getAllBadges().where((b) => b.isUnlocked).toList();
  }

  @override
  Future<void> unlockBadge(String badgeId) async {
    final unlocked = _localDataSource.getUnlockedBadges();
    if (unlocked.containsKey(badgeId)) return; // 이미 해금됨

    await _localDataSource.unlockBadge(
      BadgeUnlockModel(badgeId: badgeId, unlockedAt: DateTime.now()),
    );
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
