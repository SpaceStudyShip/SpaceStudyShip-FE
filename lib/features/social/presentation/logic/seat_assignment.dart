import '../../domain/entities/friend_entity.dart';
import '../models/seat_slot.dart';

/// 친구 리스트 -> 12개 좌석 슬롯 결정론적 할당
///
/// 순수 함수 (Flutter 의존성 없음). API 연결 시에도 동일하게 재사용 가능.
///
/// 배치 규칙:
/// 1. 나는 항상 1A
/// 2. studying 친구: studyDuration 내림차순으로 1B부터 채움
/// 3. idle/offline 친구: 이름 오름차순(가나다)으로 이어서 채움
/// 4. 12석 초과분은 잘림 (UI에서 +N명 서브텍스트로 처리)
/// 5. 남는 자리는 SeatStatus.empty
class SeatAssignment {
  const SeatAssignment._();

  static const List<String> seatNumbers = [
    '1A', '1B', '1C', '1D',
    '2A', '2B', '2C', '2D',
    '3A', '3B', '3C', '3D',
  ];

  static List<SeatSlot> from({
    required FriendEntity me,
    required List<FriendEntity> friends,
  }) {
    final studying = friends
        .where((f) => f.status == FriendStatus.studying)
        .toList()
      ..sort((a, b) {
        final da = a.studyDuration ?? Duration.zero;
        final db = b.studyDuration ?? Duration.zero;
        return db.compareTo(da);
      });

    final docked = friends
        .where((f) => f.status != FriendStatus.studying)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // 나 + studying + docked (최대 11명까지)
    final ordered = <_SeatEntry>[
      _SeatEntry(me, SeatStatus.me),
      ...studying.map((f) => _SeatEntry(f, SeatStatus.studying)),
      ...docked.map((f) => _SeatEntry(f, SeatStatus.docked)),
    ].take(12).toList();

    return List.generate(12, (i) {
      final seatNumber = seatNumbers[i];
      if (i >= ordered.length) {
        return SeatSlot(seatNumber: seatNumber, status: SeatStatus.empty);
      }
      final entry = ordered[i];
      return SeatSlot(
        seatNumber: seatNumber,
        status: entry.status,
        friend: entry.friend,
      );
    });
  }
}

class _SeatEntry {
  const _SeatEntry(this.friend, this.status);
  final FriendEntity friend;
  final SeatStatus status;
}
