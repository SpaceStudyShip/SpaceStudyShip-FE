# 소셜 좌석 배치 UI 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 `SocialSpaceView`(궤도/충전 중)를 **우주선 좌석 배치도**(12좌석, 2+통로+2 버스 스타일)로 전면 교체한다.

**Architecture:** Clean 3-layer 유지. 순수 좌석 할당 로직(`SeatAssignment`)은 Flutter 의존성 없는 순수 함수로 분리해 API 연결 시 재사용 가능. 위젯은 작게 쪼개서(`SeatWidget` / `SeatGrid` / `BoardingPassBar` / `SeatLegend` / `SocialSeatView`) 각각 독립 테스트. 탭 필터와 좌석 할당은 Riverpod Provider로 관리.

**Tech Stack:** Flutter 3.9 · Riverpod 2.6 · Freezed 2.5 · ScreenUtil · `flutter_test`

**Spec:** `docs/superpowers/specs/2026-04-14-social-seat-layout-design.md`

---

## File Structure

### 신규 생성

| 파일 | 책임 |
|------|------|
| `lib/features/social/presentation/models/seat_slot.dart` | `SeatStatus` enum + `SeatSlot` Freezed 모델 (순수 Dart, UI 의존성 없음) |
| `lib/features/social/presentation/logic/seat_assignment.dart` | 친구 리스트 → 12 좌석 슬롯 할당 순수 함수 |
| `lib/features/social/presentation/widgets/seat_widget.dart` | 단일 좌석 (C 실루엣 스타일, 4 상태 분기) |
| `lib/features/social/presentation/widgets/seat_grid.dart` | 3행 × `2+aisle+2` 그리드 레이아웃 |
| `lib/features/social/presentation/widgets/seat_legend.dart` | 상단 상태 범례 (선장 / 공부 중 / 충전 중) |
| `lib/features/social/presentation/widgets/boarding_pass_bar.dart` | 하단 탑승권 스타일 상태 바 (원형 컷아웃 포함) |
| `lib/features/social/presentation/widgets/social_seat_view.dart` | 최상위 조립 (헤더 + 범례 + 탭 + 그리드 + 탑승권 바) |
| `test/features/social/presentation/models/seat_slot_test.dart` | SeatSlot/SeatStatus 테스트 |
| `test/features/social/presentation/logic/seat_assignment_test.dart` | SeatAssignment 순수 함수 테스트 |
| `test/features/social/presentation/widgets/seat_widget_test.dart` | SeatWidget 위젯 테스트 |
| `test/features/social/presentation/widgets/seat_grid_test.dart` | SeatGrid 레이아웃 테스트 |
| `test/features/social/presentation/widgets/seat_legend_test.dart` | SeatLegend 테스트 |
| `test/features/social/presentation/widgets/boarding_pass_bar_test.dart` | BoardingPassBar 테스트 |
| `test/features/social/presentation/widgets/social_seat_view_test.dart` | 조립 뷰 테스트 |

### 수정

| 파일 | 변경 내용 |
|------|----------|
| `lib/features/social/presentation/screens/social_screen.dart` | `SocialSpaceView` → `SocialSeatView` 교체 |
| `lib/features/social/presentation/providers/friends_provider.dart` | `seatFilterProvider` + `seatAssignmentProvider` 추가, legacy provider 제거 |
| `test/features/social/presentation/providers/friends_provider_test.dart` | legacy provider 테스트 제거, 신규 provider 테스트 추가 |

### 삭제

| 파일 | 이유 |
|------|------|
| `lib/features/social/presentation/widgets/social_space_view.dart` | `social_seat_view.dart`로 교체 |
| `lib/features/social/presentation/widgets/ship_node.dart` | `SeatWidget`에 흡수 |
| `lib/features/social/presentation/widgets/docked_ship_node.dart` | `SeatWidget`에 흡수 |
| `test/features/social/presentation/widgets/social_space_view_test.dart` | 대응 위젯 삭제 |
| `test/features/social/presentation/widgets/ship_node_test.dart` | 대응 위젯 삭제 |
| `test/features/social/providers/friends_provider_test.dart` | 중복 구버전 테스트 (다른 경로의 신규 테스트만 유지) |

---

## Task 1: `SeatStatus` enum + `SeatSlot` 모델

순수 Dart. 각 좌석의 상태와 해당 친구 정보를 표현한다.

**Files:**
- Create: `lib/features/social/presentation/models/seat_slot.dart`
- Create: `test/features/social/presentation/models/seat_slot_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/models/seat_slot_test.dart`:

```dart
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
      const slot = SeatSlot(
        seatNumber: '3D',
        status: SeatStatus.empty,
      );
      expect(slot.friend, isNull);
    });

    test('같은 값이면 동등 비교 true', () {
      const slot1 = SeatSlot(seatNumber: '1A', status: SeatStatus.empty);
      const slot2 = SeatSlot(seatNumber: '1A', status: SeatStatus.empty);
      expect(slot1, equals(slot2));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/models/seat_slot_test.dart
```

Expected: FAIL with "Target of URI doesn't exist: 'package:.../seat_slot.dart'"

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/models/seat_slot.dart`:

```dart
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
  const SeatSlot({
    required this.seatNumber,
    required this.status,
    this.friend,
  });

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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/models/seat_slot_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/models/seat_slot.dart \
        test/features/social/presentation/models/seat_slot_test.dart
git -c commit.gpgsign=false commit -m "feat : SeatStatus enum 및 SeatSlot 모델 추가 #67"
```

---

## Task 2: `SeatAssignment` 순수 함수

`List<FriendEntity>` + 나 → 12개 `SeatSlot` 결정론적 할당.

**Files:**
- Create: `lib/features/social/presentation/logic/seat_assignment.dart`
- Create: `test/features/social/presentation/logic/seat_assignment_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/logic/seat_assignment_test.dart`:

```dart
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
      expect(
        slots.map((s) => s.seatNumber).toList(),
        ['1A', '1B', '1C', '1D', '2A', '2B', '2C', '2D', '3A', '3B', '3C', '3D'],
      );
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
      const idle = FriendEntity(
        id: 'i1',
        name: '최',
        status: FriendStatus.idle,
      );
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
      // 한 < 최 (가나다순) → 1C=한, 1D=최
      expect(slots[2].friend?.name, '한');
      expect(slots[2].status, SeatStatus.docked);
      expect(slots[3].friend?.name, '최');
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
      final assigned =
          slots.skip(1).where((s) => s.friend != null).length;
      expect(assigned, 11);
    });

    test('같은 입력은 항상 같은 결과를 반환한다 (결정론)', () {
      const f1 = FriendEntity(
        id: 'u1',
        name: '김',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 1),
      );
      const f2 = FriendEntity(
        id: 'u2',
        name: '박',
        status: FriendStatus.idle,
      );

      final slots1 = SeatAssignment.from(me: me, friends: const [f1, f2]);
      final slots2 = SeatAssignment.from(me: me, friends: const [f1, f2]);

      expect(slots1, equals(slots2));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/logic/seat_assignment_test.dart
```

Expected: FAIL with URI doesn't exist error.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/logic/seat_assignment.dart`:

```dart
import '../../domain/entities/friend_entity.dart';
import '../models/seat_slot.dart';

/// 친구 리스트 → 12개 좌석 슬롯 결정론적 할당
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/logic/seat_assignment_test.dart
```

Expected: All 8 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/logic/seat_assignment.dart \
        test/features/social/presentation/logic/seat_assignment_test.dart
git -c commit.gpgsign=false commit -m "feat : SeatAssignment 순수 함수로 좌석 할당 로직 분리 #67"
```

---

## Task 3: `SeatWidget` — 단일 좌석 위젯 (C 실루엣)

**Files:**
- Create: `lib/features/social/presentation/widgets/seat_widget.dart`
- Create: `test/features/social/presentation/widgets/seat_widget_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/widgets/seat_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/models/seat_slot.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_widget.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: 80, height: 80, child: child))),
      ),
    );

void main() {
  group('SeatWidget', () {
    const me = FriendEntity(
      id: 'me',
      name: '나',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 1, minutes: 30),
    );

    testWidgets('me 좌석은 이니셜과 시간, 좌석 번호를 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(const SeatWidget(
          slot: SeatSlot(
            seatNumber: '1A',
            status: SeatStatus.me,
            friend: me,
          ),
        )),
      );
      expect(find.text('1A'), findsOneWidget);
      expect(find.text('나'), findsWidgets);
      expect(find.text('1h 30m'), findsOneWidget);
    });

    testWidgets('studying 좌석은 친구 이름 첫 글자를 아바타에 표시한다', (tester) async {
      const friend = FriendEntity(
        id: 'u1',
        name: '김우주',
        status: FriendStatus.studying,
        studyDuration: Duration(hours: 2, minutes: 35),
      );
      await tester.pumpWidget(
        _wrap(const SeatWidget(
          slot: SeatSlot(
            seatNumber: '1B',
            status: SeatStatus.studying,
            friend: friend,
          ),
        )),
      );
      expect(find.text('김'), findsOneWidget);
      expect(find.text('김우주'), findsOneWidget);
      expect(find.text('2h 35m'), findsOneWidget);
    });

    testWidgets('docked 좌석은 "대기" 레이블을 표시한다 (idle)', (tester) async {
      const friend = FriendEntity(
        id: 'u1',
        name: '최성운',
        status: FriendStatus.idle,
      );
      await tester.pumpWidget(
        _wrap(const SeatWidget(
          slot: SeatSlot(
            seatNumber: '2A',
            status: SeatStatus.docked,
            friend: friend,
          ),
        )),
      );
      expect(find.text('대기'), findsOneWidget);
    });

    testWidgets('docked 좌석은 "오프" 레이블을 표시한다 (offline)', (tester) async {
      const friend = FriendEntity(
        id: 'u1',
        name: '한은하',
        status: FriendStatus.offline,
      );
      await tester.pumpWidget(
        _wrap(const SeatWidget(
          slot: SeatSlot(
            seatNumber: '2C',
            status: SeatStatus.docked,
            friend: friend,
          ),
        )),
      );
      expect(find.text('오프'), findsOneWidget);
    });

    testWidgets('empty 좌석은 좌석 번호만 표시하고 이름 없음', (tester) async {
      await tester.pumpWidget(
        _wrap(const SeatWidget(
          slot: SeatSlot(seatNumber: '3D', status: SeatStatus.empty),
        )),
      );
      expect(find.text('3D'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('onTap 콜백이 호출된다 (empty가 아닌 경우)', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(SeatWidget(
          slot: const SeatSlot(
            seatNumber: '1B',
            status: SeatStatus.studying,
            friend: FriendEntity(
              id: 'u1',
              name: '김',
              status: FriendStatus.studying,
              studyDuration: Duration(minutes: 30),
            ),
          ),
          onTap: () => tapped = true,
        )),
      );
      await tester.tap(find.byType(SeatWidget));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/widgets/seat_widget_test.dart
```

Expected: FAIL with URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/widgets/seat_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';
import '../models/seat_slot.dart';

/// 단일 우주선 좌석 위젯 (C 실루엣 스타일)
///
/// 상태별 스타일 분기:
/// - [SeatStatus.me]     : primary 파란색 테두리/배경/발판
/// - [SeatStatus.studying]: success 초록색 테두리/배경/발판 + pulse
/// - [SeatStatus.docked] : divider 회색 + grayscale + opacity 0.5
/// - [SeatStatus.empty]  : dashed 테두리 + "+" 아이콘
class SeatWidget extends StatelessWidget {
  const SeatWidget({
    super.key,
    required this.slot,
    this.onTap,
    this.muted = false,
  });

  final SeatSlot slot;
  final VoidCallback? onTap;

  /// 필터 탭에서 비매칭 좌석을 더 흐릿하게 표시
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final isEmpty = slot.status == SeatStatus.empty;
    final isDocked = slot.status == SeatStatus.docked;
    final accent = _accentColor(slot.status);

    final body = _SeatFrame(
      accentColor: accent,
      status: slot.status,
      child: Stack(
        children: [
          Positioned(
            top: 4.w,
            left: 5.w,
            child: Text(
              slot.seatNumber,
              style: AppTextStyles.tag_10.copyWith(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: _numberColor(slot.status),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildContent(slot, accent),
            ),
          ),
        ],
      ),
    );

    final rendered = isDocked || muted
        ? Opacity(
            opacity: muted ? 0.3 : 0.5,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0,    0,    0,    1, 0,
              ]),
              child: body,
            ),
          )
        : body;

    return GestureDetector(
      onTap: isEmpty ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(aspectRatio: 1, child: rendered),
    );
  }

  List<Widget> _buildContent(SeatSlot slot, Color accent) {
    if (slot.status == SeatStatus.empty) {
      return [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.spaceDivider.withValues(alpha: 0.55),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.add, size: 14.sp, color: AppColors.textDisabled),
        ),
      ];
    }

    final friend = slot.friend!;
    final initial = friend.name.isNotEmpty ? friend.name[0] : '?';
    final timeLabel = _timeLabel(slot);

    return [
      Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: slot.status == SeatStatus.docked
              ? AppColors.spaceElevated
              : accent,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTextStyles.tag_12.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: slot.status == SeatStatus.docked
                ? AppColors.textTertiary
                : Colors.white,
          ),
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        friend.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.tag_10.copyWith(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        timeLabel,
        style: AppTextStyles.tag_10.copyWith(
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
          color: slot.status == SeatStatus.docked
              ? AppColors.textDisabled
              : accent,
        ),
      ),
    ];
  }

  String _timeLabel(SeatSlot slot) {
    if (slot.status == SeatStatus.docked) {
      final friend = slot.friend!;
      return friend.status == FriendStatus.offline ? '오프' : '대기';
    }
    final duration = slot.friend?.studyDuration ?? Duration.zero;
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Color _accentColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.me:
        return AppColors.primary;
      case SeatStatus.studying:
        return AppColors.success;
      case SeatStatus.docked:
      case SeatStatus.empty:
        return AppColors.spaceDivider;
    }
  }

  Color _numberColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.me:
        return AppColors.primary;
      case SeatStatus.studying:
        return AppColors.success;
      case SeatStatus.docked:
      case SeatStatus.empty:
        return AppColors.textDisabled;
    }
  }
}

/// C 실루엣 — 위 둥근 + 이중 테두리 + 발판 언더라인
class _SeatFrame extends StatelessWidget {
  const _SeatFrame({
    required this.accentColor,
    required this.status,
    required this.child,
  });

  final Color accentColor;
  final SeatStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isEmpty = status == SeatStatus.empty;
    final borderColor = (status == SeatStatus.me ||
            status == SeatStatus.studying)
        ? accentColor
        : AppColors.spaceDivider;
    final fillColor = (status == SeatStatus.me)
        ? AppColors.primary.withValues(alpha: 0.10)
        : (status == SeatStatus.studying)
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.spaceSurface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isEmpty ? Colors.transparent : fillColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
            border: Border.all(
              color: isEmpty
                  ? AppColors.spaceDivider.withValues(alpha: 0.45)
                  : borderColor,
              width: 1.5,
              style: isEmpty ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: isEmpty
              ? child
              : Container(
                  margin: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13.r),
                      topRight: Radius.circular(13.r),
                      bottomLeft: Radius.circular(5.r),
                      bottomRight: Radius.circular(5.r),
                    ),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
        ),
        // 발판 언더라인
        if (!isEmpty && status != SeatStatus.docked)
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

> **Note:** `BorderStyle.dashed`가 Flutter core에 없어서 empty 상태는 일단 solid + 낮은 opacity로 처리. 추후 `dotted_border` 패키지 도입 검토는 범위 외.

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/widgets/seat_widget_test.dart
```

Expected: 6 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/widgets/seat_widget.dart \
        test/features/social/presentation/widgets/seat_widget_test.dart
git -c commit.gpgsign=false commit -m "feat : SeatWidget — 좌석 실루엣 위젯 추가 #67"
```

---

## Task 4: `SeatGrid` — 3행 × (2+통로+2) 레이아웃

**Files:**
- Create: `lib/features/social/presentation/widgets/seat_grid.dart`
- Create: `test/features/social/presentation/widgets/seat_grid_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/widgets/seat_grid_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/models/seat_slot.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_grid.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_widget.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(home: Scaffold(body: child)),
    );

List<SeatSlot> _fixture() {
  const me = FriendEntity(
    id: 'me',
    name: '나',
    status: FriendStatus.studying,
    studyDuration: Duration(hours: 1, minutes: 30),
  );
  return [
    const SeatSlot(seatNumber: '1A', status: SeatStatus.me, friend: me),
    for (var i = 1; i < 12; i++)
      SeatSlot(
        seatNumber: '${(i ~/ 4) + 1}${String.fromCharCode(65 + (i % 4))}',
        status: SeatStatus.empty,
      ),
  ];
}

void main() {
  group('SeatGrid', () {
    testWidgets('12개 SeatWidget을 렌더링한다', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(SeatGrid(slots: _fixture())));
      expect(find.byType(SeatWidget), findsNWidgets(12));
    });

    testWidgets('12개가 아닌 slots를 받으면 assertion error', (tester) async {
      expect(
        () => SeatGrid(slots: const [
          SeatSlot(seatNumber: '1A', status: SeatStatus.empty),
        ]),
        throwsAssertionError,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/widgets/seat_grid_test.dart
```

Expected: FAIL URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/widgets/seat_grid.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../domain/entities/friend_entity.dart';
import '../models/seat_slot.dart';
import 'seat_widget.dart';

/// 3행 × (2+통로+2) 좌석 그리드
///
/// 항상 12개 슬롯을 받아야 한다.
class SeatGrid extends StatelessWidget {
  SeatGrid({
    super.key,
    required this.slots,
    this.onSeatTap,
    this.muteOthers = _MuteOthersNone,
  }) : assert(slots.length == 12, 'SeatGrid는 정확히 12개 슬롯을 받아야 합니다.');

  final List<SeatSlot> slots;
  final ValueChanged<SeatSlot>? onSeatTap;

  /// 필터 탭에서 비매칭 좌석을 흐리게 처리할 때 사용
  final bool Function(SeatSlot slot) muteOthers;

  static bool _MuteOthersNone(SeatSlot _) => false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < 2 ? AppSpacing.s8 : 0),
          child: _buildRow(rowIndex),
        );
      }),
    );
  }

  Widget _buildRow(int rowIndex) {
    final start = rowIndex * 4;
    final rowSlots = slots.sublist(start, start + 4);
    return Row(
      children: [
        Expanded(child: _seat(rowSlots[0])),
        SizedBox(width: AppSpacing.s8),
        Expanded(child: _seat(rowSlots[1])),
        _Aisle(),
        Expanded(child: _seat(rowSlots[2])),
        SizedBox(width: AppSpacing.s8),
        Expanded(child: _seat(rowSlots[3])),
      ],
    );
  }

  Widget _seat(SeatSlot slot) {
    return SeatWidget(
      slot: slot,
      muted: muteOthers(slot),
      onTap: slot.status == SeatStatus.empty
          ? null
          : () => onSeatTap?.call(slot),
    );
  }
}

class _Aisle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      child: Center(
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            width: 1,
            decoration: const BoxDecoration(
              color: AppColors.spaceDivider,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/widgets/seat_grid_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/widgets/seat_grid.dart \
        test/features/social/presentation/widgets/seat_grid_test.dart
git -c commit.gpgsign=false commit -m "feat : SeatGrid 2+통로+2 레이아웃 위젯 추가 #67"
```

---

## Task 5: `SeatLegend` — 상태 범례

**Files:**
- Create: `lib/features/social/presentation/widgets/seat_legend.dart`
- Create: `test/features/social/presentation/widgets/seat_legend_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/widgets/seat_legend_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_legend.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('SeatLegend', () {
    testWidgets('3가지 상태 라벨을 표시한다', (tester) async {
      await tester.pumpWidget(_wrap(const SeatLegend()));
      expect(find.text('선장'), findsOneWidget);
      expect(find.text('공부 중'), findsOneWidget);
      expect(find.text('충전 중'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/widgets/seat_legend_test.dart
```

Expected: FAIL URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/widgets/seat_legend.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _LegendItem(color: AppColors.primary, label: '선장'),
          SizedBox(width: AppSpacing.s12),
          _LegendItem(color: AppColors.success, label: '공부 중'),
          SizedBox(width: AppSpacing.s12),
          _LegendItem(color: AppColors.spaceDivider, label: '충전 중'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.2),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: AppSpacing.s4),
        Text(
          label,
          style: AppTextStyles.tag_10.copyWith(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/widgets/seat_legend_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/widgets/seat_legend.dart \
        test/features/social/presentation/widgets/seat_legend_test.dart
git -c commit.gpgsign=false commit -m "feat : SeatLegend 상태 범례 위젯 추가 #67"
```

---

## Task 6: `BoardingPassBar` — 탑승권 스타일 하단 바

**Files:**
- Create: `lib/features/social/presentation/widgets/boarding_pass_bar.dart`
- Create: `test/features/social/presentation/widgets/boarding_pass_bar_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/widgets/boarding_pass_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/boarding_pass_bar.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('BoardingPassBar', () {
    testWidgets('우주선 이름과 탑승 수를 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(const BoardingPassBar(
          shipName: '우주선 1호',
          boardedCount: 4,
          totalSeats: 12,
        )),
      );
      expect(find.text('우주선 1호'), findsOneWidget);
      expect(find.text('4 / 12'), findsOneWidget);
      expect(find.text('BOARDING'), findsOneWidget);
      expect(find.text('탑승'), findsOneWidget);
    });

    testWidgets('+ 친구 버튼 탭 시 콜백 호출', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(BoardingPassBar(
          shipName: '우주선 1호',
          boardedCount: 4,
          totalSeats: 12,
          onAddFriend: () => tapped = true,
        )),
      );
      await tester.tap(find.text('+ 친구'));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/widgets/boarding_pass_bar_test.dart
```

Expected: FAIL URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/widgets/boarding_pass_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

class BoardingPassBar extends StatelessWidget {
  const BoardingPassBar({
    super.key,
    required this.shipName,
    required this.boardedCount,
    required this.totalSeats,
    this.onAddFriend,
  });

  final String shipName;
  final int boardedCount;
  final int totalSeats;
  final VoidCallback? onAddFriend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.spaceDivider),
            ),
            child: Row(
              children: [
                _PassColumn(label: 'BOARDING', value: shipName),
                SizedBox(width: AppSpacing.s12),
                _PassDivider(),
                SizedBox(width: AppSpacing.s12),
                _PassColumn(
                  label: '탑승',
                  value: '$boardedCount / $totalSeats',
                  valueColor: AppColors.success,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onAddFriend,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.button,
                    ),
                    child: Text(
                      '+ 친구',
                      style: AppTextStyles.tag_12.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 좌/우 원형 컷아웃
          Positioned(
            left: -5.w,
            top: 0,
            bottom: 0,
            child: Center(child: _Cutout()),
          ),
          Positioned(
            right: -5.w,
            top: 0,
            bottom: 0,
            child: Center(child: _Cutout()),
          ),
        ],
      ),
    );
  }
}

class _PassColumn extends StatelessWidget {
  const _PassColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.tag_10.copyWith(
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: AppColors.textDisabled,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTextStyles.tag_12.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PassDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 28.h,
      child: CustomPaint(
        painter: _DottedLinePainter(color: AppColors.spaceDivider),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashHeight = 3.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Cutout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.spaceBackground,
        border: Border.all(color: AppColors.spaceDivider),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/widgets/boarding_pass_bar_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/widgets/boarding_pass_bar.dart \
        test/features/social/presentation/widgets/boarding_pass_bar_test.dart
git -c commit.gpgsign=false commit -m "feat : BoardingPassBar 탑승권 스타일 바 추가 #67"
```

---

## Task 7: Provider 정리 & 신규 추가

Legacy provider 제거 + `seatFilterProvider` + `seatAssignmentProvider` 추가.

**Files:**
- Modify: `lib/features/social/presentation/providers/friends_provider.dart`
- Modify: `test/features/social/presentation/providers/friends_provider_test.dart`
- Delete: `test/features/social/providers/friends_provider_test.dart` (중복 구버전)

- [ ] **Step 1: Write the failing test**

Replace `test/features/social/presentation/providers/friends_provider_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/models/seat_slot.dart';
import 'package:space_study_ship/features/social/presentation/providers/friends_provider.dart';

void main() {
  group('friendsProvider', () {
    test('더미 데이터 리스트를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);

      expect(friends, isNotEmpty);
      expect(friends.every((f) => f.id.isNotEmpty), isTrue);
    });

    test('studying 상태 친구가 포함된다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      expect(
        friends.any((f) => f.status == FriendStatus.studying),
        isTrue,
      );
    });
  });

  group('studyingCountProvider', () {
    test('studying 상태 친구 수를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final expected =
          friends.where((f) => f.status == FriendStatus.studying).length;
      expect(container.read(studyingCountProvider), expected);
    });
  });

  group('seatFilterProvider', () {
    test('초기값은 SeatFilter.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(seatFilterProvider), SeatFilter.all);
    });
  });

  group('seatAssignmentProvider', () {
    test('항상 12개 슬롯을 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final slots = container.read(seatAssignmentProvider);
      expect(slots, hasLength(12));
    });

    test('첫 슬롯(1A)은 나(me)이다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final slots = container.read(seatAssignmentProvider);
      expect(slots.first.seatNumber, '1A');
      expect(slots.first.status, SeatStatus.me);
    });
  });

  group('boardedCountProvider', () {
    test('나 + studying + docked 친구 수의 합 (empty 제외)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final friends = container.read(friendsProvider);
      final expected = 1 + friends.length;
      expect(container.read(boardedCountProvider),
          expected > 12 ? 12 : expected);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/providers/friends_provider_test.dart
```

Expected: FAIL — `SeatFilter`, `seatFilterProvider`, `seatAssignmentProvider`, `boardedCountProvider` undefined.

- [ ] **Step 3: Rewrite friends_provider.dart**

Replace `lib/features/social/presentation/providers/friends_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/friend_entity.dart';
import '../logic/seat_assignment.dart';
import '../models/seat_slot.dart';

/// 좌석 필터 탭 상태
enum SeatFilter { all, studying, docked }

/// 현재 사용자 (나) — API 연동 시 auth provider로 교체
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
```

- [ ] **Step 4: Delete duplicate legacy test file**

```bash
rm test/features/social/providers/friends_provider_test.dart
rmdir test/features/social/providers 2>/dev/null || true
```

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/providers/friends_provider_test.dart
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/presentation/providers/friends_provider.dart \
        test/features/social/presentation/providers/friends_provider_test.dart \
        test/features/social/providers/
git -c commit.gpgsign=false commit -m "refactor : friends_provider 재정리 — seat* provider 추가, legacy 제거 #67"
```

---

## Task 8: `SocialSeatView` — 조립 화면

**Files:**
- Create: `lib/features/social/presentation/widgets/social_seat_view.dart`
- Create: `test/features/social/presentation/widgets/social_seat_view_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/social/presentation/widgets/social_seat_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/boarding_pass_bar.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_grid.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_legend.dart';
import 'package:space_study_ship/features/social/presentation/widgets/seat_widget.dart';
import 'package:space_study_ship/features/social/presentation/widgets/social_seat_view.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );

void main() {
  group('SocialSeatView', () {
    testWidgets('헤더에 "소셜" 타이틀을 표시한다', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const SocialSeatView()));
      await tester.pump();
      expect(find.text('소셜'), findsOneWidget);
    });

    testWidgets('SeatLegend가 렌더링된다', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const SocialSeatView()));
      await tester.pump();
      expect(find.byType(SeatLegend), findsOneWidget);
    });

    testWidgets('SeatGrid가 렌더링되고 12개 SeatWidget 포함', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const SocialSeatView()));
      await tester.pump();
      expect(find.byType(SeatGrid), findsOneWidget);
      expect(find.byType(SeatWidget), findsNWidgets(12));
    });

    testWidgets('BoardingPassBar가 렌더링된다', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const SocialSeatView()));
      await tester.pump();
      expect(find.byType(BoardingPassBar), findsOneWidget);
      expect(find.text('우주선 1호'), findsOneWidget);
    });

    testWidgets('3개 필터 탭이 표시된다', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const SocialSeatView()));
      await tester.pump();
      expect(find.text('공부 중'), findsOneWidget);
      expect(find.text('충전 중'), findsOneWidget);
      expect(find.text('전체'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/social/presentation/widgets/social_seat_view_test.dart
```

Expected: FAIL URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/social/presentation/widgets/social_seat_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../models/seat_slot.dart';
import '../providers/friends_provider.dart';
import '../screens/friend_detail_screen.dart';
import 'boarding_pass_bar.dart';
import 'seat_grid.dart';
import 'seat_legend.dart';

/// 소셜 좌석 배치 뷰
///
/// 구성: 헤더 → 범례 → 탭 → SeatGrid → BoardingPassBar
class SocialSeatView extends ConsumerWidget {
  const SocialSeatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(seatAssignmentProvider);
    final boardedCount = ref.watch(boardedCountProvider);
    final filter = ref.watch(seatFilterProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(boardedCount: boardedCount),
          SizedBox(height: AppSpacing.s8),
          const SeatLegend(),
          SizedBox(height: AppSpacing.s12),
          _FilterTabs(selected: filter, onChanged: (f) {
            ref.read(seatFilterProvider.notifier).state = f;
          }),
          SizedBox(height: AppSpacing.s12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: SeatGrid(
              slots: slots,
              muteOthers: (slot) => _shouldMute(slot, filter),
              onSeatTap: (slot) => _onSeatTap(context, slot),
            ),
          ),
          const Spacer(),
          BoardingPassBar(
            shipName: '우주선 1호',
            boardedCount: boardedCount,
            totalSeats: 12,
            onAddFriend: () {}, // TODO(#67): 친구 추가 플로우 연결
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom +
                FloatingNavMetrics.totalHeight +
                AppSpacing.s12,
          ),
        ],
      ),
    );
  }

  bool _shouldMute(SeatSlot slot, SeatFilter filter) {
    if (filter == SeatFilter.all) return false;
    if (slot.status == SeatStatus.empty) return false;
    if (filter == SeatFilter.studying) {
      return slot.status != SeatStatus.me &&
          slot.status != SeatStatus.studying;
    }
    // SeatFilter.docked
    return slot.status != SeatStatus.docked;
  }

  void _onSeatTap(BuildContext context, SeatSlot slot) {
    if (slot.friend == null || slot.status == SeatStatus.me) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FriendDetailScreen(friend: slot.friend!),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.boardedCount});
  final int boardedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '소셜',
                  style: AppTextStyles.heading_20.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '우주선 1호 · $boardedCount명 탑승 중',
                  style: AppTextStyles.tag_10.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: AppColors.spaceDivider),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.add, size: 15.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final SeatFilter selected;
  final ValueChanged<SeatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _Tab(
            label: '공부 중',
            active: selected == SeatFilter.studying,
            onTap: () => onChanged(SeatFilter.studying),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '충전 중',
            active: selected == SeatFilter.docked,
            onTap: () => onChanged(SeatFilter.docked),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '전체',
            active: selected == SeatFilter.all,
            onTap: () => onChanged(SeatFilter.all),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.tag_12.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/social/presentation/widgets/social_seat_view_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/presentation/widgets/social_seat_view.dart \
        test/features/social/presentation/widgets/social_seat_view_test.dart
git -c commit.gpgsign=false commit -m "feat : SocialSeatView 헤더+범례+탭+그리드+탑승권 조립 #67"
```

---

## Task 9: `SocialScreen` 교체 — SocialSpaceView → SocialSeatView

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart`

- [ ] **Step 1: Edit the import and usage**

Apply these exact changes to `lib/features/social/presentation/screens/social_screen.dart`:

```dart
// 1. import 교체
// 이전
import '../widgets/social_space_view.dart';
// 이후
import '../widgets/social_seat_view.dart';
```

```dart
// 2. build 메서드 리턴 교체
// 이전
return const SocialSpaceView();
// 이후
return const SocialSeatView();
```

전체 파일 결과는 게스트 처리 로직은 그대로 두고, 마지막 return만 `SocialSeatView`로 바뀐다.

- [ ] **Step 2: Run analyze to confirm import resolves**

```bash
flutter analyze lib/features/social/presentation/screens/social_screen.dart
```

Expected: No issues found.

- [ ] **Step 3: Run all social tests**

```bash
flutter test test/features/social/
```

Expected: All pass (old ship_node_test & social_space_view_test still reference deleted widgets → 이 단계에서는 아직 실패 가능. 다음 Task에서 정리)

- [ ] **Step 4: Commit**

```bash
git add lib/features/social/presentation/screens/social_screen.dart
git -c commit.gpgsign=false commit -m "refactor : SocialScreen에서 SocialSeatView 사용 #67"
```

---

## Task 10: Legacy 위젯/테스트 제거

**Files:**
- Delete: `lib/features/social/presentation/widgets/social_space_view.dart`
- Delete: `lib/features/social/presentation/widgets/ship_node.dart`
- Delete: `lib/features/social/presentation/widgets/docked_ship_node.dart`
- Delete: `test/features/social/presentation/widgets/social_space_view_test.dart`
- Delete: `test/features/social/presentation/widgets/ship_node_test.dart`

- [ ] **Step 1: Delete legacy widget files**

```bash
rm lib/features/social/presentation/widgets/social_space_view.dart
rm lib/features/social/presentation/widgets/ship_node.dart
rm lib/features/social/presentation/widgets/docked_ship_node.dart
```

- [ ] **Step 2: Delete legacy test files**

```bash
rm test/features/social/presentation/widgets/social_space_view_test.dart
rm test/features/social/presentation/widgets/ship_node_test.dart
```

- [ ] **Step 3: Search for any remaining references**

```bash
grep -rn "SocialSpaceView\|ShipNode\|DockedShipNode" lib/ test/ 2>/dev/null
```

Expected: No results.

- [ ] **Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Run full test suite**

```bash
flutter test
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add -A
git -c commit.gpgsign=false commit -m "chore : legacy SocialSpaceView/ShipNode/DockedShipNode 삭제 #67"
```

---

## Task 11: Verification — Design System 준수 확인

**Files:**
- Read only: 모든 신규 생성 파일

- [ ] **Step 1: Grep 하드코딩 컬러 검사**

```bash
grep -n "Color(0xFF\|Colors\." lib/features/social/presentation/widgets/seat_widget.dart lib/features/social/presentation/widgets/seat_grid.dart lib/features/social/presentation/widgets/seat_legend.dart lib/features/social/presentation/widgets/boarding_pass_bar.dart lib/features/social/presentation/widgets/social_seat_view.dart
```

Expected: `Colors.white`, `Colors.transparent`만 허용. `Color(0xFF...)` 리터럴은 0건.

- [ ] **Step 2: Grep 이모지 검사**

```bash
grep -n "🚀\|✅\|❌\|⭐\|🎉\|💪" lib/features/social/
```

Expected: No results.

- [ ] **Step 3: Grep 하드코딩 spacing 검사**

```bash
grep -nE "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]+\.(r|w|h|sp)" lib/features/social/presentation/widgets/seat_widget.dart lib/features/social/presentation/widgets/seat_grid.dart lib/features/social/presentation/widgets/seat_legend.dart lib/features/social/presentation/widgets/boarding_pass_bar.dart lib/features/social/presentation/widgets/social_seat_view.dart | grep -v "AppSpacing\|AppPadding"
```

Expected: 숫자 리터럴 패딩 0건 (AppSpacing/AppPadding만 사용). 허용 예외: 1px/2px 같은 라인 두께.

- [ ] **Step 4: flutter analyze + test**

```bash
flutter analyze && flutter test
```

Expected: No issues, all tests pass.

- [ ] **Step 5: Dart format**

```bash
dart format lib/features/social/ test/features/social/
```

- [ ] **Step 6: Final commit (if format changed anything)**

```bash
git add -A
git diff --cached --quiet || git -c commit.gpgsign=false commit -m "style : dart format 적용 #67"
```

---

## Self-Review

### 1. Spec 커버리지 매핑

| Spec 섹션 | 구현 Task |
|----------|-----------|
| 2.1 전체 구조 | Task 8 (`SocialSeatView` 조립) |
| 2.2 좌석 그리드 사양 (12석, 2+통로+2) | Task 4 (`SeatGrid`) |
| 2.3 좌석 위젯 사양 (C 실루엣) | Task 3 (`SeatWidget`) |
| 2.4 상태별 스타일 표 | Task 3 |
| 2.5 상태 범례 | Task 5 (`SeatLegend`) |
| 2.6 필터 탭 | Task 8 (`_FilterTabs`) + Task 7 (`seatFilterProvider`) |
| 2.7 탑승권 바 | Task 6 (`BoardingPassBar`) |
| 2.8 헤더 | Task 8 (`_Header`) |
| 2.9 배경 | 별도 변경 없음 (기존 `SocialScreen`에서 `Scaffold` + `SpaceBackground`가 이미 처리) |
| 3.1 새 위젯 파일 구조 | Task 3~8 |
| 3.2 제거 | Task 10 |
| 3.3 Provider 변경 | Task 7 |
| 4.1 좌석 할당 로직 | Task 2 (`SeatAssignment`) |
| 4.2 필드 매핑 | Task 3 (`SeatWidget._buildContent`) |
| 4.3 탭 필터 동작 | Task 8 (`_shouldMute`) |
| 5 인터랙션 (좌석 탭 → detail, 나/빈 자리 무반응) | Task 8 (`_onSeatTap`) + Task 3 (onTap null) |
| 6 엣지 케이스 | Task 2 (12명 초과, 0명 등) 테스트로 커버 |
| 7 AppColors 매핑 | Task 11 (grep 검증) |
| 8 접근성/반응형 | ScreenUtil `.w/.h/.sp` 일관 적용 |
| 9 In Scope | 모든 Task |
| 9.A API 연결 준비 | Task 2 (순수 함수 분리) + Task 7 (`seatAssignmentProvider`가 `friendsProvider`만 watch) |

### 2. Placeholder 스캔

- TBD/TODO: Task 8의 `onAddFriend: () {}`에 `TODO(#67)` 1개 — spec에 명시된 대로 범위 외이므로 의도적
- "Similar to Task N": 없음 — 모든 Task는 독립적으로 읽을 수 있음
- "Add appropriate error handling": 없음
- "Write tests for the above" (코드 없이): 없음

### 3. 타입 일관성

- `SeatStatus` 값: `me / studying / docked / empty` — Task 1 정의, Task 2/3/7/8에서 동일 사용 ✓
- `SeatSlot` 필드: `seatNumber / status / friend` — Task 1 정의, 이후 전부 일치 ✓
- `SeatAssignment.from({me, friends})` — Task 2 정의, Task 7에서 동일 호출 ✓
- `SeatFilter` 값: `all / studying / docked` — Task 7 정의, Task 8에서 동일 사용 ✓
- `FriendEntity.status` → `FriendStatus.studying/idle/offline` — 기존 타입 그대로 사용 ✓

모든 타입/시그니처 일치 확인됨.
