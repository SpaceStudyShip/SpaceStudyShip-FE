import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/friend_entity.dart';
import '../logic/seat_assignment.dart';
import '../models/seat_slot.dart';

/// 좌석 필터 탭 상태
enum SeatFilter { all, studying, docked }

/// 현재 사용자(나) — API 연동 시 auth provider로 교체
const _me = FriendEntity(
  id: 'me',
  name: '나',
  status: FriendStatus.studying,
  studyDuration: Duration(hours: 1, minutes: 30),
  currentSubject: '수학',
  weeklyStudyDuration: Duration(hours: 12),
);

final meProvider = Provider<FriendEntity>((ref) => _me);

/// 더미 친구 데이터 — API 연결 시 Repository로 교체만 하면 됨
final friendsProvider = Provider<List<FriendEntity>>((ref) {
  return const [
    FriendEntity(
      id: 'u1',
      name: '김우주',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 2, minutes: 35),
      currentSubject: '수학',
      weeklyStudyDuration: Duration(hours: 16, minutes: 20),
    ),
    FriendEntity(
      id: 'u2',
      name: '박탐험',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 1, minutes: 12),
      currentSubject: '영어',
      weeklyStudyDuration: Duration(hours: 11, minutes: 45),
    ),
    FriendEntity(
      id: 'u3',
      name: '이별자리',
      status: FriendStatus.studying,
      studyDuration: Duration(minutes: 47),
      currentSubject: '물리',
      weeklyStudyDuration: Duration(hours: 8, minutes: 10),
    ),
    FriendEntity(
      id: 'u4',
      name: '최성운',
      status: FriendStatus.idle,
      weeklyStudyDuration: Duration(hours: 5, minutes: 30),
    ),
    FriendEntity(
      id: 'u5',
      name: '정혜성',
      status: FriendStatus.idle,
      weeklyStudyDuration: Duration(hours: 3),
    ),
    FriendEntity(
      id: 'u6',
      name: '한은하',
      status: FriendStatus.offline,
      weeklyStudyDuration: Duration(hours: 2, minutes: 15),
    ),
    FriendEntity(
      id: 'u7',
      name: '오행성',
      status: FriendStatus.offline,
      weeklyStudyDuration: Duration(hours: 1),
    ),
  ];
});

/// 공부 중인 친구 수
final studyingCountProvider = Provider<int>((ref) {
  return ref
      .watch(friendsProvider)
      .where((f) => f.status == FriendStatus.studying)
      .length;
});

/// 충전 중 친구 수 (idle + offline)
final dockedCountProvider = Provider<int>((ref) {
  return ref
      .watch(friendsProvider)
      .where((f) => f.status != FriendStatus.studying)
      .length;
});

/// 좌석 필터 탭 상태 (기본: 전체)
final seatFilterProvider = StateProvider<SeatFilter>((ref) => SeatFilter.all);

/// 12 좌석 슬롯 할당
///
/// 입력: meProvider + friendsProvider
/// 계산: SeatAssignment.from (순수 함수)
///
/// API 연결 시 friendsProvider만 비동기로 바꾸면 자연스럽게 갱신된다.
final seatAssignmentProvider = Provider<List<SeatSlot>>((ref) {
  final me = ref.watch(meProvider);
  final friends = ref.watch(friendsProvider);
  return SeatAssignment.from(me: me, friends: friends);
});

/// 탑승 중인 총 인원 (empty가 아닌 좌석 수)
final boardedCountProvider = Provider<int>((ref) {
  return ref
      .watch(seatAssignmentProvider)
      .where((s) => s.status != SeatStatus.empty)
      .length;
});
