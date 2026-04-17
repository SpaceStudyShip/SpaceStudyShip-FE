import '../../domain/entities/friend_entity.dart';

/// 좌석의 시각적 상태
///
/// - [me]: 현재 사용자(선장) 좌석
/// - [studying]: 공부 중인 친구 좌석
/// - [docked]: idle 또는 offline 친구 좌석 (충전 중)
/// - [empty]: 비어 있는 좌석
enum SeatStatus { me, studying, docked, empty }

/// 좌석 하나를 나타내는 불변 모델
///
/// [SeatStatus.empty]인 경우 [friend]는 null이다.
class SeatSlot {
  const SeatSlot({required this.seatNumber, required this.status, this.friend});

  final String seatNumber;
  final SeatStatus status;
  final FriendEntity? friend;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatSlot &&
          other.seatNumber == seatNumber &&
          other.status == status &&
          other.friend == friend;

  @override
  int get hashCode => Object.hash(seatNumber, status, friend);
}
