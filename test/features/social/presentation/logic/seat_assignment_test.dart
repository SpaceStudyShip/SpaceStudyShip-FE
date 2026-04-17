import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/logic/seat_assignment.dart';
import 'package:space_study_ship/features/social/presentation/models/seat_slot.dart';

void main() {
  const me = FriendEntity(
    id: 'me',
    name: '나',
    status: FriendStatus.studying,
    studyDuration: Duration(hours: 1, minutes: 30),
  );

  group('SeatAssignment.from', () {
    test('12개 슬롯을 반환한다', () {
      final slots = SeatAssignment.from(me: me, friends: const []);
      expect(slots, hasLength(12));
    });

    test('좌석 번호는 1A, 1B, 1C, 1D, 2A, ..., 3D 순서', () {
      final slots = SeatAssignment.from(me: me, friends: const []);
      expect(slots.map((s) => s.seatNumber).toList(), [
        '1A',
        '1B',
        '1C',
        '1D',
        '2A',
        '2B',
        '2C',
        '2D',
        '3A',
        '3B',
        '3C',
        '3D',
      ]);
    });

    test('나는 항상 1A 좌석에 배치되고 status는 me', () {
      final slots = SeatAssignment.from(me: me, friends: const []);
      expect(slots.first.seatNumber, '1A');
      expect(slots.first.status, SeatStatus.me);
      expect(slots.first.friend, me);
    });

    test('친구 없을 때 1B~3D는 모두 empty', () {
      final slots = SeatAssignment.from(me: me, friends: const []);
      final rest = slots.skip(1);
      expect(rest.every((s) => s.status == SeatStatus.empty), isTrue);
      expect(rest.every((s) => s.friend == null), isTrue);
    });

    test('studying 친구는 공부 시간 내림차순으로 1B부터 채워진다', () {
      const f1 = FriendEntity(
        id: 'u1',
        name: '김',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 2, minutes: 35),
      );
      const f2 = FriendEntity(
        id: 'u2',
        name: '박',
        status: FriendStatus.studying,
        studyDuration: Duration(minutes: 47),
      );
      const f3 = FriendEntity(
        id: 'u3',
        name: '이',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 1, minutes: 12),
      );

      final slots = SeatAssignment.from(me: me, friends: const [f2, f1, f3]);

      expect(slots[1].seatNumber, '1B');
      expect(slots[1].friend?.id, 'u1'); // 2h 35m (가장 긴)
      expect(slots[2].friend?.id, 'u3'); // 1h 12m
      expect(slots[3].friend?.id, 'u2'); // 47m
      expect(slots[1].status, SeatStatus.studying);
    });

    test('idle/offline 친구는 studying 뒤에 이름 오름차순으로 채워진다', () {
      const studying = FriendEntity(
        id: 's1',
        name: '김',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 1),
      );
      const idle = FriendEntity(id: 'i1', name: '최', status: FriendStatus.idle);
      const offline = FriendEntity(
        id: 'o1',
        name: '한',
        status: FriendStatus.offline,
      );

      final slots = SeatAssignment.from(
        me: me,
        friends: const [offline, idle, studying],
      );

      expect(slots[1].friend?.id, 's1'); // studying first
      // 최 < 한 (가나다순) -> 1C=최, 1D=한
      expect(slots[2].friend?.name, '최');
      expect(slots[2].status, SeatStatus.docked);
      expect(slots[3].friend?.name, '한');
      expect(slots[3].status, SeatStatus.docked);
    });

    test('12명 초과 시 나 + 11명만 배치되고 나머지는 잘림', () {
      final many = List.generate(
        15,
        (i) => FriendEntity(
          id: 'u$i',
          name: '친구$i',
          status: FriendStatus.studying,
          studyDuration: Duration(minutes: 100 - i),
        ),
      );

      final slots = SeatAssignment.from(me: me, friends: many);

      expect(slots.length, 12);
      expect(slots.first.friend?.id, 'me');
      final assigned = slots.skip(1).where((s) => s.friend != null).length;
      expect(assigned, 11);
    });

    test('같은 입력은 항상 같은 결과를 반환한다 (결정론)', () {
      const f1 = FriendEntity(
        id: 'u1',
        name: '김',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 1),
      );
      const f2 = FriendEntity(id: 'u2', name: '박', status: FriendStatus.idle);

      final slots1 = SeatAssignment.from(me: me, friends: const [f1, f2]);
      final slots2 = SeatAssignment.from(me: me, friends: const [f1, f2]);

      expect(slots1, equals(slots2));
    });
  });
}
