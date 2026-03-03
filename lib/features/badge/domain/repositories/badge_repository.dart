import '../entities/badge_entity.dart';

abstract class BadgeRepository {
  /// 전체 배지 목록 (시드 + 해금 상태 병합)
  List<BadgeEntity> getAllBadges();

  /// 해금된 배지 목록
  List<BadgeEntity> getUnlockedBadges();

  /// 배지 해금 처리
  Future<void> unlockBadge(String badgeId);

  /// 해금 상태 초기화 (로그아웃 시)
  Future<void> clearAll();
}
