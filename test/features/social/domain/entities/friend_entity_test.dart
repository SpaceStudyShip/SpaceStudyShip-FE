import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';

void main() {
  group('FriendStatus', () {
    test('세 가지 상태가 정의되어 있다', () {
      expect(FriendStatus.values, contains(FriendStatus.studying));
      expect(FriendStatus.values, contains(FriendStatus.idle));
      expect(FriendStatus.values, contains(FriendStatus.offline));
    });
  });

  group('FriendEntity', () {
    test('필수 필드로 생성된다', () {
      const entity = FriendEntity(
        id: 'u1',
        name: '김우주',
        status: FriendStatus.studying,
      );
      expect(entity.id, 'u1');
      expect(entity.name, '김우주');
      expect(entity.status, FriendStatus.studying);
      expect(entity.studyDuration, isNull);
      expect(entity.currentSubject, isNull);
    });

    test('선택 필드를 포함해서 생성된다', () {
      const entity = FriendEntity(
        id: 'u2',
        name: '박탐험',
        status: FriendStatus.idle,
        studyDuration: Duration(hours: 2),
        currentSubject: '수학',
      );
      expect(entity.studyDuration, const Duration(hours: 2));
      expect(entity.currentSubject, '수학');
    });

    test('copyWith으로 상태를 변경한다', () {
      const entity = FriendEntity(
        id: 'u3',
        name: '이별자리',
        status: FriendStatus.offline,
      );
      final updated = entity.copyWith(status: FriendStatus.studying);
      expect(updated.status, FriendStatus.studying);
      expect(updated.id, 'u3');
    });

    test('동일 값이면 equality가 성립한다', () {
      const a = FriendEntity(id: 'u4', name: '최성운', status: FriendStatus.idle);
      const b = FriendEntity(id: 'u4', name: '최성운', status: FriendStatus.idle);
      expect(a, equals(b));
    });
  });
}
