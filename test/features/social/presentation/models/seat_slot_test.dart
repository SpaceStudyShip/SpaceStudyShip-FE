import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/models/seat_slot.dart';

void main() {
  group('SeatStatus', () {
    test('4개 상태 enum 값을 가진다', () {
      expect(SeatStatus.values, hasLength(4));
      expect(SeatStatus.values, contains(SeatStatus.me));
      expect(SeatStatus.values, contains(SeatStatus.studying));
      expect(SeatStatus.values, contains(SeatStatus.docked));
      expect(SeatStatus.values, contains(SeatStatus.empty));
    });
  });

  group('SeatSlot', () {
    const friend = FriendEntity(
      id: 'u1',
      name: '김우주',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 2, minutes: 35),
    );

    test('studying 슬롯 생성', () {
      const slot = SeatSlot(
        seatNumber: '1B',
        status: SeatStatus.studying,
        friend: friend,
      );
      expect(slot.seatNumber, '1B');
      expect(slot.status, SeatStatus.studying);
      expect(slot.friend, friend);
    });

    test('empty 슬롯은 friend가 null', () {
      const slot = SeatSlot(seatNumber: '3D', status: SeatStatus.empty);
      expect(slot.friend, isNull);
    });

    test('같은 값이면 동등 비교 true', () {
      const slot1 = SeatSlot(seatNumber: '1A', status: SeatStatus.empty);
      const slot2 = SeatSlot(seatNumber: '1A', status: SeatStatus.empty);
      expect(slot1, equals(slot2));
    });
  });
}
