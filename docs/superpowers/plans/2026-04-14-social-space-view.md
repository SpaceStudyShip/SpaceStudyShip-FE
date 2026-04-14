# 소셜 화면 FocusFlight 스타일 우주 뷰 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 레이더 뷰를 폐기하고 FocusFlight 스타일의 우주 공간 뷰로 소셜 화면을 전면 교체한다.

**Architecture:** 공부 중인 친구는 HIGH/LOW ORBIT에 우주선으로 표시하고, 오프라인/대기는 지평선 아래 착륙 상태로 표시한다. SocialScreen에서 TabBar를 제거하고 SocialSpaceView 하나로 교체한다. 친구 우주선 탭 시 FriendDetailScreen으로 Navigator.push 이동한다.

**Tech Stack:** Flutter 3.9+, Riverpod 2.6, Freezed 2.5, flutter_screenutil

---

## 파일 구조

**신규 생성:**
- `lib/features/social/presentation/widgets/ship_node.dart` — 공부 중인 우주선 노드 (나 + 친구)
- `lib/features/social/presentation/widgets/docked_ship_node.dart` — 착륙 상태 아바타
- `lib/features/social/presentation/widgets/social_space_view.dart` — 메인 우주 뷰 전체
- `lib/features/social/presentation/screens/friend_detail_screen.dart` — 친구 상세 화면
- `test/features/social/providers/friends_provider_test.dart`
- `test/features/social/presentation/widgets/ship_node_test.dart`
- `test/features/social/presentation/screens/friend_detail_screen_test.dart`

**수정:**
- `lib/features/social/domain/entities/friend_entity.dart` — weeklyStudyDuration 필드 추가
- `lib/features/social/presentation/providers/friends_provider.dart` — 기존 ring providers 제거, orbit providers 추가
- `lib/features/social/presentation/screens/social_screen.dart` — TabBar 제거, SocialSpaceView 연결

**삭제:**
- `lib/features/social/presentation/widgets/social_radar_view.dart`
- `lib/features/social/presentation/widgets/radar_background.dart`
- `lib/features/social/presentation/widgets/radar_scene.dart`
- `lib/features/social/presentation/widgets/radar_status_bar.dart`
- `lib/features/social/presentation/widgets/me_node.dart`
- `lib/features/social/presentation/widgets/friend_node.dart`

---

## Task 1: FriendEntity + Provider orbit logic

**Files:**
- Modify: `lib/features/social/domain/entities/friend_entity.dart`
- Modify: `lib/features/social/presentation/providers/friends_provider.dart`
- Create: `test/features/social/providers/friends_provider_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

```dart
// test/features/social/providers/friends_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/providers/friends_provider.dart';

void main() {
  group('orbit providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });
    tearDown(() => container.dispose());

    test('highOrbitFriendsProvider returns studying friends with 90+ min', () {
      final friends = container.read(highOrbitFriendsProvider);
      for (final f in friends) {
        expect(f.status, FriendStatus.studying);
        expect(
          (f.studyDuration ?? Duration.zero).inMinutes,
          greaterThanOrEqualTo(90),
        );
      }
    });

    test('lowOrbitFriendsProvider returns studying friends under 90 min', () {
      final friends = container.read(lowOrbitFriendsProvider);
      for (final f in friends) {
        expect(f.status, FriendStatus.studying);
        expect(
          (f.studyDuration ?? Duration.zero).inMinutes,
          lessThan(90),
        );
      }
    });

    test('dockedFriendsProvider returns non-studying friends', () {
      final friends = container.read(dockedFriendsProvider);
      for (final f in friends) {
        expect(f.status, isNot(FriendStatus.studying));
      }
    });

    test('studyingCountProvider returns count of studying friends', () {
      final count = container.read(studyingCountProvider);
      final allFriends = container.read(friendsProvider);
      final expected =
          allFriends.where((f) => f.status == FriendStatus.studying).length;
      expect(count, expected);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/social/providers/friends_provider_test.dart
```
Expected: FAIL (highOrbitFriendsProvider, lowOrbitFriendsProvider, dockedFriendsProvider not defined)

- [ ] **Step 3: FriendEntity에 weeklyStudyDuration 추가**

```dart
// lib/features/social/domain/entities/friend_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_entity.freezed.dart';

enum FriendStatus { studying, idle, offline }

@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    required FriendStatus status,
    Duration? studyDuration,
    String? currentSubject,
    Duration? weeklyStudyDuration,
  }) = _FriendEntity;
}
```

- [ ] **Step 4: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Expected: `lib/features/social/domain/entities/friend_entity.freezed.dart` 재생성

- [ ] **Step 5: friends_provider.dart 교체**

```dart
// lib/features/social/presentation/providers/friends_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/friend_entity.dart';

/// 더미 친구 데이터 — API 완성 시 교체
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

/// HIGH ORBIT: 공부 중 + 90분 이상
final highOrbitFriendsProvider = Provider<List<FriendEntity>>((ref) {
  return ref
      .watch(friendsProvider)
      .where(
        (f) =>
            f.status == FriendStatus.studying &&
            (f.studyDuration ?? Duration.zero) >=
                const Duration(minutes: 90),
      )
      .toList();
});

/// LOW ORBIT: 공부 중 + 90분 미만
final lowOrbitFriendsProvider = Provider<List<FriendEntity>>((ref) {
  return ref
      .watch(friendsProvider)
      .where(
        (f) =>
            f.status == FriendStatus.studying &&
            (f.studyDuration ?? Duration.zero) <
                const Duration(minutes: 90),
      )
      .toList();
});

/// DOCKED: idle + offline
final dockedFriendsProvider = Provider<List<FriendEntity>>((ref) {
  return ref
      .watch(friendsProvider)
      .where((f) => f.status != FriendStatus.studying)
      .toList();
});
```

- [ ] **Step 6: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/social/providers/friends_provider_test.dart
```
Expected: PASS (4 tests)

- [ ] **Step 7: 커밋**

```bash
git add lib/features/social/domain/entities/friend_entity.dart \
        lib/features/social/domain/entities/friend_entity.freezed.dart \
        lib/features/social/presentation/providers/friends_provider.dart \
        test/features/social/providers/friends_provider_test.dart
git commit -m "feat : FriendEntity weeklyStudyDuration 추가, orbit providers 구성 #67"
```

---

## Task 2: ShipNode 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/ship_node.dart`
- Create: `test/features/social/presentation/widgets/ship_node_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

```dart
// test/features/social/presentation/widgets/ship_node_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/ship_node.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  group('ShipNode', () {
    testWidgets('이름 첫 글자 이니셜을 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(ShipNode(
          name: '김우주',
          isMe: false,
          studyDuration: const Duration(hours: 2),
        )),
      );
      expect(find.text('김'), findsOneWidget);
    });

    testWidgets('isMe=true 이면 "나 (YOU)" 레이블을 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(ShipNode(
          name: '나',
          isMe: true,
          studyDuration: const Duration(hours: 1, minutes: 30),
        )),
      );
      expect(find.text('나 (YOU)'), findsOneWidget);
    });

    testWidgets('2시간 공부 시간을 "2h 0m"으로 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(ShipNode(
          name: '박',
          isMe: false,
          studyDuration: const Duration(hours: 2),
        )),
      );
      expect(find.text('2h 0m'), findsOneWidget);
    });

    testWidgets('onTap 콜백이 호출된다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(ShipNode(
          name: '이',
          isMe: false,
          studyDuration: const Duration(minutes: 45),
          onTap: () => tapped = true,
        )),
      );
      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, true);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/social/presentation/widgets/ship_node_test.dart
```
Expected: FAIL (ship_node.dart not found)

- [ ] **Step 3: ShipNode 구현**

```dart
// lib/features/social/presentation/widgets/ship_node.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 공부 중인 친구(또는 나)의 우주선 노드
///
/// isMe=true → 파란색 (primary), false → 초록색 (success)
/// pulse 애니메이션 포함
class ShipNode extends StatefulWidget {
  const ShipNode({
    super.key,
    required this.name,
    required this.isMe,
    required this.studyDuration,
    this.currentSubject,
    this.onTap,
  });

  final String name;
  final bool isMe;
  final Duration studyDuration;
  final String? currentSubject;
  final VoidCallback? onTap;

  @override
  State<ShipNode> createState() => _ShipNodeState();
}

class _ShipNodeState extends State<ShipNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.isMe ? AppColors.primary : AppColors.success;
    final glowColor = widget.isMe
        ? AppColors.primary.withValues(alpha: 0.35)
        : AppColors.success.withValues(alpha: 0.3);
    const avatarSize = 44.0;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: avatarSize + 18,
            height: avatarSize + 18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor.withValues(
                            alpha: _opacityAnim.value,
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.spaceElevated,
                    border: Border.all(color: borderColor, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.name.isNotEmpty ? widget.name[0] : '?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.spaceBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.spaceDivider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isMe ? '나 (YOU)' : widget.name,
                  style: AppTextStyles.tag_10.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDuration(widget.studyDuration),
                  style: AppTextStyles.tag_10.copyWith(
                    fontSize: 9,
                    color: borderColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/social/presentation/widgets/ship_node_test.dart
```
Expected: PASS (4 tests)

- [ ] **Step 5: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/ship_node.dart
```
Expected: No issues found

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/presentation/widgets/ship_node.dart \
        test/features/social/presentation/widgets/ship_node_test.dart
git commit -m "feat : ShipNode 우주선 노드 위젯 구현 #67"
```

---

## Task 3: DockedShipNode 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/docked_ship_node.dart`

- [ ] **Step 1: DockedShipNode 구현 (테스트 포함)**

```dart
// lib/features/social/presentation/widgets/docked_ship_node.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';

/// 착륙 상태 (오프라인 / 대기) 친구 아바타
class DockedShipNode extends StatelessWidget {
  const DockedShipNode({
    super.key,
    required this.friend,
    this.onTap,
  });

  final FriendEntity friend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial =
        friend.name.isNotEmpty ? friend.name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.spaceElevated,
              border: Border.all(
                color: AppColors.spaceDivider,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            friend.name.length > 4
                ? friend.name.substring(0, 4)
                : friend.name,
            style: AppTextStyles.tag_10.copyWith(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
```

테스트는 Task 4의 SocialSpaceView 위젯 테스트에서 통합 검증한다. 별도 테스트 파일 없음 (단순 표시 위젯).

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/docked_ship_node.dart
```
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/widgets/docked_ship_node.dart
git commit -m "feat : DockedShipNode 착륙 상태 위젯 구현 #67"
```

---

## Task 4: SocialSpaceView 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/social_space_view.dart`
- Create: `test/features/social/presentation/widgets/social_space_view_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

```dart
// test/features/social/presentation/widgets/social_space_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/docked_ship_node.dart';
import 'package:space_study_ship/features/social/presentation/widgets/ship_node.dart';
import 'package:space_study_ship/features/social/presentation/widgets/social_space_view.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );

void main() {
  group('SocialSpaceView', () {
    testWidgets('나(YOU) ShipNode가 항상 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(const SocialSpaceView()));
      await tester.pump();
      expect(find.text('나 (YOU)'), findsOneWidget);
    });

    testWidgets('공부 중인 친구 ShipNode들이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(const SocialSpaceView()));
      await tester.pump();
      // 기본 더미 데이터: 3명 공부 중 + 나 = 4개 ShipNode
      expect(find.byType(ShipNode), findsNWidgets(4));
    });

    testWidgets('착륙 친구 DockedShipNode들이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(const SocialSpaceView()));
      await tester.pump();
      // 기본 더미 데이터: 4명 착륙 (idle 2 + offline 2)
      expect(find.byType(DockedShipNode), findsNWidgets(4));
    });

    testWidgets('HIGH ORBIT 레이블이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(const SocialSpaceView()));
      await tester.pump();
      expect(find.text('HIGH ORBIT'), findsOneWidget);
    });

    testWidgets('DOCKED 레이블이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(const SocialSpaceView()));
      await tester.pump();
      expect(find.text('DOCKED'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/social/presentation/widgets/social_space_view_test.dart
```
Expected: FAIL (social_space_view.dart not found)

- [ ] **Step 3: SocialSpaceView 구현**

```dart
// lib/features/social/presentation/widgets/social_space_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/friends_provider.dart';
import '../screens/friend_detail_screen.dart';
import 'docked_ship_node.dart';
import 'ship_node.dart';

/// 소셜 메인 뷰 — FocusFlight 스타일 우주 공간
///
/// 공부 중인 친구 = HIGH/LOW ORBIT 우주선
/// 오프라인/대기 친구 = DOCKED 지평선 아래
class SocialSpaceView extends ConsumerWidget {
  const SocialSpaceView({super.key});

  /// 나(ME) 더미 데이터 — API 완성 시 auth provider로 교체
  static const _me = FriendEntity(
    id: 'me',
    name: '나',
    status: FriendStatus.studying,
    studyDuration: Duration(hours: 1, minutes: 30),
    currentSubject: '수학',
    weeklyStudyDuration: Duration(hours: 12),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highFriends = ref.watch(highOrbitFriendsProvider);
    final lowFriends = ref.watch(lowOrbitFriendsProvider);
    final dockedFriends = ref.watch(dockedFriendsProvider);
    final studyingCount = ref.watch(studyingCountProvider);

    // 나는 항상 HIGH ORBIT 맨 앞
    final highShips = [_me, ...highFriends];

    return Column(
      children: [
        Expanded(
          child: _SpaceZone(
            highShips: highShips,
            lowShips: lowFriends,
            dockedFriends: dockedFriends,
          ),
        ),
        _SocialStatusBar(
          studyingCount: studyingCount + 1, // +1 for me
          dockedCount: dockedFriends.length,
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom +
              FloatingNavMetrics.totalHeight +
              AppSpacing.s12,
        ),
      ],
    );
  }
}

class _SpaceZone extends StatelessWidget {
  const _SpaceZone({
    required this.highShips,
    required this.lowShips,
    required this.dockedFriends,
  });

  final List<FriendEntity> highShips;
  final List<FriendEntity> lowShips;
  final List<FriendEntity> dockedFriends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _OrbitSection(
          label: 'HIGH ORBIT',
          ships: highShips,
        ),
        if (lowShips.isNotEmpty) ...[
          const SizedBox(height: 4),
          _OrbitDivider(),
          const SizedBox(height: 12),
          _OrbitSection(
            label: 'LOW ORBIT',
            ships: lowShips,
          ),
        ],
        const Spacer(),
        _HorizonBar(),
        if (dockedFriends.isNotEmpty)
          _DockedSection(friends: dockedFriends),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _OrbitSection extends StatelessWidget {
  const _OrbitSection({
    required this.label,
    required this.ships,
  });

  final String label;
  final List<FriendEntity> ships;

  @override
  Widget build(BuildContext context) {
    if (ships.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OrbitLabel(label),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ships.map((f) {
            return ShipNode(
              name: f.name,
              isMe: f.id == 'me',
              studyDuration: f.studyDuration ?? Duration.zero,
              currentSubject: f.currentSubject,
              onTap: f.id == 'me'
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => FriendDetailScreen(friend: f),
                        ),
                      ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _OrbitLabel extends StatelessWidget {
  const _OrbitLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _DashedLine()),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final count =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (i) => Container(
              width: dashWidth,
              height: 1,
              color: AppColors.spaceDivider.withValues(alpha: 0.5),
              margin: const EdgeInsets.only(right: dashSpace),
            ),
          ),
        );
      },
    );
  }
}

class _OrbitDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _DashedLine(),
    );
  }
}

class _HorizonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            'DOCKED',
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.spaceDivider,
            ),
          ),
        ],
      ),
    );
  }
}

class _DockedSection extends StatelessWidget {
  const _DockedSection({required this.friends});
  final List<FriendEntity> friends;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          ...friends.map(
            (f) => DockedShipNode(
              friend: f,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FriendDetailScreen(friend: f),
                ),
              ),
            ),
          ),
          _AddFriendButton(),
        ],
      ),
    );
  }
}

class _AddFriendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO(#67): 친구 추가 기능 연결
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.spaceDivider,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.add,
          size: 16,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _SocialStatusBar extends StatelessWidget {
  const _SocialStatusBar({
    required this.studyingCount,
    required this.dockedCount,
  });

  final int studyingCount;
  final int dockedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        border: Border(
          top: BorderSide(color: AppColors.spaceDivider),
        ),
      ),
      child: Row(
        children: [
          _StatusItem(
            color: AppColors.primary,
            label: '나·공부중',
          ),
          const SizedBox(width: 14),
          _StatusItem(
            color: AppColors.success,
            label: '친구 ${studyingCount - 1}명',
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {}, // TODO(#67): 친구 추가 기능
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                '+ 친구',
                style: AppTextStyles.tag_12.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.tag_12.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/social/presentation/widgets/social_space_view_test.dart
```
Expected: PASS (5 tests)

- [ ] **Step 5: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/social_space_view.dart
```
Expected: No issues found

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/presentation/widgets/social_space_view.dart \
        test/features/social/presentation/widgets/social_space_view_test.dart
git commit -m "feat : SocialSpaceView 우주 공간 메인 뷰 구현 #67"
```

---

## Task 5: FriendDetailScreen

**Files:**
- Create: `lib/features/social/presentation/screens/friend_detail_screen.dart`
- Create: `test/features/social/presentation/screens/friend_detail_screen_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

```dart
// test/features/social/presentation/screens/friend_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/screens/friend_detail_screen.dart';

const _studying = FriendEntity(
  id: 'u1',
  name: '김우주',
  status: FriendStatus.studying,
  studyDuration: Duration(hours: 2, minutes: 14),
  currentSubject: '수학',
  weeklyStudyDuration: Duration(hours: 16, minutes: 20),
);

const _offline = FriendEntity(
  id: 'u6',
  name: '한은하',
  status: FriendStatus.offline,
  weeklyStudyDuration: Duration(hours: 2, minutes: 15),
);

Widget _wrap(Widget child) => ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp(home: child),
      ),
    );

void main() {
  group('FriendDetailScreen', () {
    testWidgets('친구 이름이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('김우주'), findsOneWidget);
    });

    testWidgets('공부 중 친구는 현재 과목이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('수학'), findsOneWidget);
    });

    testWidgets('오늘 공부 시간이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('2h 14m'), findsOneWidget);
    });

    testWidgets('이번 주 공부 시간이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('16h 20m'), findsOneWidget);
    });

    testWidgets('오프라인 친구는 과목 카드가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _offline)));
      await tester.pump();
      // currentSubject 없으면 과목 카드 숨김
      expect(find.text('현재 과목'), findsNothing);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/social/presentation/screens/friend_detail_screen_test.dart
```
Expected: FAIL (friend_detail_screen.dart not found)

- [ ] **Step 3: FriendDetailScreen 구현**

```dart
// lib/features/social/presentation/screens/friend_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../domain/entities/friend_entity.dart';

/// 친구 상세 화면
///
/// ShipNode 또는 DockedShipNode 탭 시 Navigator.push로 이동
class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({super.key, required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final isStudying = friend.status == FriendStatus.studying;
    final borderColor = isStudying ? AppColors.success : AppColors.spaceDivider;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppPadding.screenPadding,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // 아바타
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.spaceElevated,
                      border: Border.all(color: borderColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      friend.name.isNotEmpty ? friend.name[0] : '?',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  // 이름
                  Text(
                    friend.name,
                    style: AppTextStyles.heading_20.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  // 상태
                  _StatusBadge(status: friend.status),
                  SizedBox(height: AppSpacing.s24),
                  // 현재 과목 카드 (공부 중일 때만)
                  if (isStudying && friend.currentSubject != null)
                    _SubjectCard(
                      subject: friend.currentSubject!,
                      studyDuration: friend.studyDuration ?? Duration.zero,
                    ),
                  if (isStudying && friend.currentSubject != null)
                    SizedBox(height: AppSpacing.s12),
                  // 오늘 / 이번 주 통계
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: _formatDuration(
                            friend.studyDuration ?? Duration.zero,
                          ),
                          label: '오늘 공부',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _StatCard(
                          value: _formatDuration(
                            friend.weeklyStudyDuration ?? Duration.zero,
                          ),
                          label: '이번 주',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final FriendStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FriendStatus.studying => ('지금 공부 중', AppColors.success),
      FriendStatus.idle => ('대기 중', AppColors.textTertiary),
      FriendStatus.offline => ('오프라인', AppColors.textTertiary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.tag_12.copyWith(color: color),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.studyDuration,
  });

  final String subject;
  final Duration studyDuration;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.spaceElevated,
              borderRadius: AppRadius.medium,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 과목',
                style: AppTextStyles.tag_10.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subject,
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatDuration(studyDuration),
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading_20.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/social/presentation/screens/friend_detail_screen_test.dart
```
Expected: PASS (5 tests)

- [ ] **Step 5: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/screens/friend_detail_screen.dart
```
Expected: No issues found

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/presentation/screens/friend_detail_screen.dart \
        test/features/social/presentation/screens/friend_detail_screen_test.dart
git commit -m "feat : FriendDetailScreen 친구 상세 화면 구현 #67"
```

---

## Task 6: SocialScreen 수정 + 구 위젯 삭제

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart`
- Delete: 6개 구 위젯 파일

- [ ] **Step 1: SocialScreen 교체**

```dart
// lib/features/social/presentation/screens/social_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/login_prompt_helper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../widgets/social_space_view.dart';

/// 소셜 스크린
///
/// 인증 사용자: SocialSpaceView (FocusFlight 스타일 우주 공간)
/// 게스트: 로그인 유도 화면
class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    if (isGuest) {
      return _buildGuestView(context, ref);
    }

    return _buildAuthenticatedView();
  }

  Widget _buildGuestView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: AppSpacing.s20,
        title: Text(
          '소셜',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpaceEmptyState(
                icon: Icons.people_rounded,
                color: AppColors.primary,
                title: '친구와 함께 공부하려면',
                subtitle: '로그인이 필요해요',
              ),
              SizedBox(height: AppSpacing.s24),
              AppButton(
                text: '로그인하기',
                onPressed: () => showLoginPrompt(
                  context: context,
                  ref: ref,
                  message: '소셜 기능을 이용하려면 로그인이 필요해요.',
                ),
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: AppSpacing.s20,
        title: Text(
          '소셜',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: const SocialSpaceView(),
    );
  }
}
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/screens/social_screen.dart
```
Expected: No issues found

- [ ] **Step 3: 구 위젯 파일 삭제**

```bash
rm lib/features/social/presentation/widgets/social_radar_view.dart
rm lib/features/social/presentation/widgets/radar_background.dart
rm lib/features/social/presentation/widgets/radar_scene.dart
rm lib/features/social/presentation/widgets/radar_status_bar.dart
rm lib/features/social/presentation/widgets/me_node.dart
rm lib/features/social/presentation/widgets/friend_node.dart
```

- [ ] **Step 4: 전체 analyze — 경고 0개 확인**

```bash
flutter analyze
```
Expected: No issues found

- [ ] **Step 5: 전체 테스트 통과 확인**

```bash
flutter test
```
Expected: 모든 테스트 PASS

- [ ] **Step 6: 최종 커밋**

```bash
git add lib/features/social/presentation/screens/social_screen.dart
git rm lib/features/social/presentation/widgets/social_radar_view.dart \
       lib/features/social/presentation/widgets/radar_background.dart \
       lib/features/social/presentation/widgets/radar_scene.dart \
       lib/features/social/presentation/widgets/radar_status_bar.dart \
       lib/features/social/presentation/widgets/me_node.dart \
       lib/features/social/presentation/widgets/friend_node.dart
git commit -m "refactor : SocialScreen TabBar 제거, SocialSpaceView 연결 + 레이더 위젯 삭제 #67"
```
