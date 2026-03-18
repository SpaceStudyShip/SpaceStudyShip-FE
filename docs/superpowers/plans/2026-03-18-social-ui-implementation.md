# 소셜 화면 UI 구체화 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 소셜 화면의 3개 탭(친구/그룹/랭킹)을 우주 테마 UI로 구체화하고, Mock 데이터 레이어를 구축한다.

**Architecture:** Clean Architecture (Domain → Data → Presentation) 패턴을 따른다. Domain 엔티티(Freezed) + Repository 인터페이스를 정의하고, Mock Repository 구현체로 더미 데이터를 제공한다. Presentation 레이어에서 Riverpod Provider로 상태를 관리하며, 기존 디자인 시스템(AppColors, AppTextStyles, AppSpacing)을 사용한다.

**Tech Stack:** Flutter, Riverpod, Freezed, GoRouter, flutter_screenutil, flutter_svg

---

## 파일 구조

### Domain Layer (신규)
```
lib/features/social/domain/
├── entities/
│   ├── friend_entity.dart          # 친구 엔티티 (Freezed)
│   ├── group_entity.dart           # 그룹 엔티티 (Freezed)
│   ├── group_member_entity.dart    # 그룹 멤버 엔티티 (Freezed)
│   └── ranking_entry_entity.dart   # 랭킹 엔티티 (Freezed)
└── repositories/
    ├── friend_repository.dart      # 친구 Repository 인터페이스
    ├── group_repository.dart       # 그룹 Repository 인터페이스
    └── ranking_repository.dart     # 랭킹 Repository 인터페이스
```

### Data Layer (신규)
```
lib/features/social/data/
└── repositories/
    ├── mock_friend_repository.dart   # Mock 친구 데이터
    ├── mock_group_repository.dart    # Mock 그룹 데이터
    └── mock_ranking_repository.dart  # Mock 랭킹 데이터
```

### Presentation Layer (신규 + 수정)
```
lib/features/social/presentation/
├── providers/
│   ├── social_providers.dart         # Repository Provider 등록
│   ├── friend_provider.dart          # 친구 목록 Provider
│   ├── group_provider.dart           # 그룹 목록 Provider
│   └── ranking_provider.dart         # 랭킹 Provider
├── screens/
│   ├── social_screen.dart            # (수정) AppBar 제거, SafeArea 전환
│   └── group_detail_screen.dart      # (신규) 그룹 좌석 화면
└── widgets/
    ├── constellation_map.dart        # 별자리 맵 위젯
    ├── constellation_painter.dart    # 별자리 CustomPainter
    ├── constellation_patterns.dart   # 북두칠성 좌표 상수
    ├── group_ticket_card.dart        # 그룹 티켓 카드
    ├── seat_grid.dart                # 좌석 그리드 위젯
    └── ranking_tab_content.dart      # 랭킹 탭 콘텐츠
```

### 라우터 수정
```
lib/routes/app_router.dart            # (수정) GroupDetailScreen 연결
```

---

## Task 1: Domain 엔티티 정의

**Files:**
- Create: `lib/features/social/domain/entities/friend_entity.dart`
- Create: `lib/features/social/domain/entities/group_entity.dart`
- Create: `lib/features/social/domain/entities/group_member_entity.dart`
- Create: `lib/features/social/domain/entities/ranking_entry_entity.dart`

- [ ] **Step 1: Friend 엔티티 작성**

```dart
// lib/features/social/domain/entities/friend_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_entity.freezed.dart';

enum OnlineStatus { online, away, offline }

@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String id,
    required String name,
    String? avatarUrl,
    required OnlineStatus status,
    required int slotIndex, // 0~5 (북두칠성 자리)
  }) = _FriendEntity;
}
```

- [ ] **Step 2: Group 엔티티 작성**

```dart
// lib/features/social/domain/entities/group_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'group_member_entity.dart';

part 'group_entity.freezed.dart';

@freezed
class GroupEntity with _$GroupEntity {
  const factory GroupEntity({
    required String id,
    required String name,
    required int maxSeats,
    required List<GroupMemberEntity> members,
    required String inviteCode,
  }) = _GroupEntity;
}
```

- [ ] **Step 3: GroupMember 엔티티 작성**

```dart
// lib/features/social/domain/entities/group_member_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'friend_entity.dart';

part 'group_member_entity.freezed.dart';

@freezed
class GroupMemberEntity with _$GroupMemberEntity {
  const factory GroupMemberEntity({
    required String id,
    required String name,
    String? avatarUrl,
    required OnlineStatus status,
    required int seatIndex,
  }) = _GroupMemberEntity;
}
```

- [ ] **Step 4: RankingEntry 엔티티 작성**

```dart
// lib/features/social/domain/entities/ranking_entry_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_entry_entity.freezed.dart';

@freezed
class RankingEntryEntity with _$RankingEntryEntity {
  const factory RankingEntryEntity({
    required int rank,
    required String userId,
    required String name,
    String? avatarUrl,
    required int studyTimeMinutes,
    required bool isMe,
  }) = _RankingEntryEntity;
}
```

- [ ] **Step 5: Freezed 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/domain/
git commit -m "feat(social): domain 엔티티 정의 (Friend, Group, GroupMember, RankingEntry) #64"
```

---

## Task 2: Repository 인터페이스 + Mock 구현

**Files:**
- Create: `lib/features/social/domain/repositories/friend_repository.dart`
- Create: `lib/features/social/domain/repositories/group_repository.dart`
- Create: `lib/features/social/domain/repositories/ranking_repository.dart`
- Create: `lib/features/social/data/repositories/mock_friend_repository.dart`
- Create: `lib/features/social/data/repositories/mock_group_repository.dart`
- Create: `lib/features/social/data/repositories/mock_ranking_repository.dart`

- [ ] **Step 1: FriendRepository 인터페이스**

```dart
// lib/features/social/domain/repositories/friend_repository.dart
import '../entities/friend_entity.dart';

abstract class FriendRepository {
  List<FriendEntity> getFriends();
  Future<void> addFriend(String friendId);
  Future<void> removeFriend(String friendId);
}
```

- [ ] **Step 2: GroupRepository 인터페이스**

```dart
// lib/features/social/domain/repositories/group_repository.dart
import '../entities/group_entity.dart';

abstract class GroupRepository {
  List<GroupEntity> getGroups();
  GroupEntity? getGroupById(String id);
  Future<GroupEntity> createGroup(String name);
  Future<void> joinGroup(String inviteCode);
}
```

- [ ] **Step 3: RankingRepository 인터페이스**

```dart
// lib/features/social/domain/repositories/ranking_repository.dart
import '../entities/ranking_entry_entity.dart';

enum RankingType { all, friends }
enum RankingPeriod { today, weekly, monthly }

abstract class RankingRepository {
  List<RankingEntryEntity> getRanking({
    required RankingType type,
    required RankingPeriod period,
  });
}
```

- [ ] **Step 4: MockFriendRepository 구현**

```dart
// lib/features/social/data/repositories/mock_friend_repository.dart
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';

class MockFriendRepository implements FriendRepository {
  @override
  List<FriendEntity> getFriends() {
    return const [
      FriendEntity(id: '1', name: '김우주', status: OnlineStatus.online, slotIndex: 0),
      FriendEntity(id: '2', name: '이별님', status: OnlineStatus.away, slotIndex: 1),
      FriendEntity(id: '3', name: '박성운', status: OnlineStatus.offline, slotIndex: 2),
    ];
  }

  @override
  Future<void> addFriend(String friendId) async {}

  @override
  Future<void> removeFriend(String friendId) async {}
}
```

- [ ] **Step 5: MockGroupRepository 구현**

```dart
// lib/features/social/data/repositories/mock_group_repository.dart
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/group_repository.dart';

class MockGroupRepository implements GroupRepository {
  @override
  List<GroupEntity> getGroups() {
    return const [
      GroupEntity(
        id: 'g1',
        name: '알고리즘 스터디',
        maxSeats: 4,
        inviteCode: 'ALG-7X2',
        members: [
          GroupMemberEntity(id: 'me', name: '나', status: OnlineStatus.online, seatIndex: 0),
          GroupMemberEntity(id: '1', name: '김우주', status: OnlineStatus.online, seatIndex: 1),
        ],
      ),
      GroupEntity(
        id: 'g2',
        name: '토익 900+',
        maxSeats: 4,
        inviteCode: 'TOE-3K9',
        members: [
          GroupMemberEntity(id: 'me', name: '나', status: OnlineStatus.online, seatIndex: 0),
          GroupMemberEntity(id: '2', name: '이별님', status: OnlineStatus.away, seatIndex: 1),
          GroupMemberEntity(id: '3', name: '박성운', status: OnlineStatus.offline, seatIndex: 2),
          GroupMemberEntity(id: '4', name: '최은하', status: OnlineStatus.online, seatIndex: 3),
        ],
      ),
    ];
  }

  @override
  GroupEntity? getGroupById(String id) {
    return getGroups().where((g) => g.id == id).firstOrNull;
  }

  @override
  Future<GroupEntity> createGroup(String name) async {
    return GroupEntity(id: 'new', name: name, maxSeats: 4, inviteCode: 'NEW-001', members: const []);
  }

  @override
  Future<void> joinGroup(String inviteCode) async {}
}
```

- [ ] **Step 6: MockRankingRepository 구현**

```dart
// lib/features/social/data/repositories/mock_ranking_repository.dart
import '../../domain/entities/ranking_entry_entity.dart';
import '../../domain/repositories/ranking_repository.dart';

class MockRankingRepository implements RankingRepository {
  @override
  List<RankingEntryEntity> getRanking({
    required RankingType type,
    required RankingPeriod period,
  }) {
    // 기간별로 다른 더미 시간 반환
    final baseMinutes = switch (period) {
      RankingPeriod.today => 60,
      RankingPeriod.weekly => 420,
      RankingPeriod.monthly => 1800,
    };

    final entries = [
      RankingEntryEntity(rank: 1, userId: 'u1', name: '김우주', studyTimeMinutes: baseMinutes, isMe: false),
      RankingEntryEntity(rank: 2, userId: 'u2', name: '이별님', studyTimeMinutes: (baseMinutes * 0.85).toInt(), isMe: false),
      RankingEntryEntity(rank: 3, userId: 'u3', name: '박성운', studyTimeMinutes: (baseMinutes * 0.7).toInt(), isMe: false),
      RankingEntryEntity(rank: 4, userId: 'u4', name: '최은하', studyTimeMinutes: (baseMinutes * 0.6).toInt(), isMe: false),
      RankingEntryEntity(rank: 5, userId: 'u5', name: '정항성', studyTimeMinutes: (baseMinutes * 0.5).toInt(), isMe: false),
      RankingEntryEntity(rank: 12, userId: 'me', name: '나', studyTimeMinutes: (baseMinutes * 0.2).toInt(), isMe: true),
    ];

    if (type == RankingType.friends) {
      return entries.where((e) => e.isMe || ['u1', 'u2', 'u3'].contains(e.userId)).toList();
    }
    return entries;
  }
}
```

- [ ] **Step 7: 커밋**

```bash
git add lib/features/social/domain/repositories/ lib/features/social/data/
git commit -m "feat(social): Repository 인터페이스 + Mock 구현 (Friend, Group, Ranking) #64"
```

---

## Task 3: Riverpod Provider 등록

**Files:**
- Create: `lib/features/social/presentation/providers/social_providers.dart`
- Create: `lib/features/social/presentation/providers/friend_provider.dart`
- Create: `lib/features/social/presentation/providers/group_provider.dart`
- Create: `lib/features/social/presentation/providers/ranking_provider.dart`

- [ ] **Step 1: Repository Provider 등록**

```dart
// lib/features/social/presentation/providers/social_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/mock_friend_repository.dart';
import '../../data/repositories/mock_group_repository.dart';
import '../../data/repositories/mock_ranking_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/ranking_repository.dart';

part 'social_providers.g.dart';

@riverpod
FriendRepository friendRepository(Ref ref) => MockFriendRepository();

@riverpod
GroupRepository groupRepository(Ref ref) => MockGroupRepository();

@riverpod
RankingRepository rankingRepository(Ref ref) => MockRankingRepository();
```

- [ ] **Step 2: Friend Provider**

```dart
// lib/features/social/presentation/providers/friend_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/friend_entity.dart';
import 'social_providers.dart';

part 'friend_provider.g.dart';

@riverpod
List<FriendEntity> friendList(Ref ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
}
```

- [ ] **Step 3: Group Provider**

```dart
// lib/features/social/presentation/providers/group_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/group_entity.dart';
import 'social_providers.dart';

part 'group_provider.g.dart';

@riverpod
List<GroupEntity> groupList(Ref ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroups();
}

@riverpod
GroupEntity? groupDetail(Ref ref, String groupId) {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroupById(groupId);
}
```

- [ ] **Step 4: Ranking Provider**

```dart
// lib/features/social/presentation/providers/ranking_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/ranking_entry_entity.dart';
import '../../domain/repositories/ranking_repository.dart';
import 'social_providers.dart';

part 'ranking_provider.g.dart';

@riverpod
List<RankingEntryEntity> rankingList(
  Ref ref,
  RankingType type,
  RankingPeriod period,
) {
  final repository = ref.watch(rankingRepositoryProvider);
  return repository.getRanking(type: type, period: period);
}
```

- [ ] **Step 5: 코드 생성 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/presentation/providers/
git commit -m "feat(social): Riverpod Provider 등록 (Friend, Group, Ranking) #64"
```

---

## Task 4: 소셜 메인 화면 리팩토링 (AppBar 제거 + SafeArea)

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart`

- [ ] **Step 1: SocialScreen 수정 — AppBar 제거, SafeArea + 커스텀 TabBar**

`social_screen.dart`를 수정한다:
- `_buildGuestView`: AppBar 제거 → SafeArea + 중앙 SpaceEmptyState
- `_buildAuthenticatedView`: AppBar 제거 → SafeArea 내부에 커스텀 TabBar 배치
- ConsumerWidget 유지 (DefaultTabController 사용, 별도 TabController 불필요)
- 모든 탭 빌더 메서드에 `WidgetRef ref` 파라미터를 추가하여 Provider 접근
- 탭 콘텐츠를 별도 위젯 파일로 분리할 준비

핵심 변경:
```dart
// _buildAuthenticatedView 변경 — ref를 파라미터로 전달
Widget _buildAuthenticatedView(WidgetRef ref) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // 커스텀 탭 바 (AppBar 없이)
            TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: AppTextStyles.paragraph14Semibold,
              unselectedLabelStyle: AppTextStyles.paragraph_14_100,
              tabs: const [
                Tab(text: '친구'),
                Tab(text: '그룹'),
                Tab(text: '랭킹'),
              ],
            ),
            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                children: [
                  _buildFriendsTab(),
                  _buildGroupsTab(ref),
                  _buildRankingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// build() 메서드에서 호출도 업데이트:
// return _buildAuthenticatedView(ref);
}
```

- [ ] **Step 2: flutter analyze 확인**

Run: `flutter analyze`

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/screens/social_screen.dart
git commit -m "refactor(social): AppBar 제거, SafeArea + 커스텀 TabBar 전환 #64"
```

---

## Task 5: 별자리 맵 위젯 (친구 탭)

**Files:**
- Create: `lib/features/social/presentation/widgets/constellation_patterns.dart`
- Create: `lib/features/social/presentation/widgets/constellation_painter.dart`
- Create: `lib/features/social/presentation/widgets/constellation_map.dart`

- [ ] **Step 1: 북두칠성 좌표 패턴 상수 정의**

```dart
// lib/features/social/presentation/widgets/constellation_patterns.dart
import 'dart:ui';

/// 북두칠성 별자리 좌표 패턴
///
/// 좌표는 0.0~1.0 비율 (화면 크기에 맞춰 스케일링)
/// index 0~5: 친구 자리, polaris: 나(북극성)
class ConstellationPatterns {
  ConstellationPatterns._();

  /// 북극성 (나) 위치
  static const Offset polaris = Offset(0.5, 0.55);

  /// 친구 6자리 (북두칠성 국자 모양)
  static const List<Offset> bigDipperSlots = [
    Offset(0.20, 0.25), // slot 0: 국자 끝
    Offset(0.35, 0.22), // slot 1
    Offset(0.50, 0.28), // slot 2
    Offset(0.62, 0.35), // slot 3: 국자 꺾이는 점
    Offset(0.72, 0.45), // slot 4: 손잡이
    Offset(0.80, 0.55), // slot 5: 손잡이 끝
  ];

  /// 별 연결선 (index 쌍)
  /// -1 = polaris(나)
  static const List<(int, int)> connections = [
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 5),
    (5, -1), // 손잡이 끝 → 북극성 연결
  ];
}
```

- [ ] **Step 2: CustomPainter 구현 (연결선 + 별)**

```dart
// lib/features/social/presentation/widgets/constellation_painter.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/friend_entity.dart';
import 'constellation_patterns.dart';

class ConstellationPainter extends CustomPainter {
  const ConstellationPainter({required this.friends});

  final List<FriendEntity> friends;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.spaceDivider
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 좌표를 실제 픽셀로 변환
    Offset toPixel(Offset ratio) => Offset(ratio.dx * size.width, ratio.dy * size.height);

    final polarisPos = toPixel(ConstellationPatterns.polaris);
    final slotPositions = ConstellationPatterns.bigDipperSlots.map(toPixel).toList();

    // 연결선 그리기
    for (final (from, to) in ConstellationPatterns.connections) {
      final fromPos = from == -1 ? polarisPos : slotPositions[from];
      final toPos = to == -1 ? polarisPos : slotPositions[to];
      canvas.drawLine(fromPos, toPos, linePaint);
    }
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) =>
      oldDelegate.friends != friends;
}
```

- [ ] **Step 3: ConstellationMap 위젯 구현**

```dart
// lib/features/social/presentation/widgets/constellation_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../routes/route_paths.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/friend_provider.dart';
import 'constellation_painter.dart';
import 'constellation_patterns.dart';

class ConstellationMap extends ConsumerWidget {
  const ConstellationMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendListProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // 연결선
            CustomPaint(
              size: size,
              painter: ConstellationPainter(friends: friends),
            ),

            // 북극성 (나)
            _buildStar(
              context: context,
              position: ConstellationPatterns.polaris,
              size: size,
              label: '나',
              isPolaris: true,
              statusColor: AppColors.online,
            ),

            // 친구 별 / 빈 별
            for (int i = 0; i < ConstellationPatterns.bigDipperSlots.length; i++)
              _buildSlot(
                context: context,
                index: i,
                size: size,
                friend: friends.where((f) => f.slotIndex == i).firstOrNull,
              ),

            // 빈 상태 안내 텍스트 (친구가 없을 때)
            if (friends.isEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.s64 + AppSpacing.s20,
                child: Text(
                  '친구를 추가해서 별자리를 완성해요',
                  style: AppTextStyles.paragraph_14.copyWith(color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),

            // 친구 추가 버튼 (하단)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.s20,
              child: Center(
                child: AppButton(
                  text: '친구 추가',
                  onPressed: () {}, // TODO: 백엔드 연결
                  width: 140,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlot({
    required BuildContext context,
    required int index,
    required Size size,
    FriendEntity? friend,
  }) {
    final position = ConstellationPatterns.bigDipperSlots[index];
    final isFilled = friend != null;

    return _buildStar(
      context: context,
      position: position,
      size: size,
      label: isFilled ? friend.name : '',
      isPolaris: false,
      isFilled: isFilled,
      statusColor: isFilled ? _statusColor(friend.status) : null,
      onTap: isFilled
          ? () => context.push(RoutePaths.friendDetailPath(friend.id))
          : () {}, // TODO: 친구 추가 동작
    );
  }

  Widget _buildStar({
    required BuildContext context,
    required Offset position,
    required Size size,
    required String label,
    required bool isPolaris,
    bool isFilled = true,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    final starSize = isPolaris ? 48.w : 36.w;
    final px = position.dx * size.width - starSize / 2;
    final py = position.dy * size.height - starSize / 2;

    return Positioned(
      left: px,
      top: py,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: starSize,
              height: starSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? AppColors.spaceElevated
                    : AppColors.spaceSurface.withValues(alpha: 0.3),
                border: Border.all(
                  color: isFilled
                      ? (statusColor ?? AppColors.offline)
                      : AppColors.spaceDivider.withValues(alpha: 0.3),
                  width: isPolaris ? 2.5 : 1.5,
                ),
                boxShadow: isFilled && statusColor != null
                    ? [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isFilled ? Icons.person_rounded : Icons.add_rounded,
                  size: isPolaris ? 24.w : 18.w,
                  color: isFilled ? Colors.white : AppColors.textDisabled,
                ),
              ),
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s4),
              Text(
                label,
                style: AppTextStyles.tag_12.copyWith(
                  color: isPolaris ? AppColors.primaryLight : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(OnlineStatus status) => switch (status) {
    OnlineStatus.online => AppColors.online,
    OnlineStatus.away => AppColors.away,
    OnlineStatus.offline => AppColors.offline,
  };
}
```

- [ ] **Step 4: SocialScreen 친구 탭에 ConstellationMap 연결**

`social_screen.dart`의 `_buildFriendsTab()`을 교체:
```dart
Widget _buildFriendsTab() {
  return const ConstellationMap();
}
```

- [ ] **Step 5: flutter analyze 확인**

Run: `flutter analyze`

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/presentation/widgets/constellation_patterns.dart \
  lib/features/social/presentation/widgets/constellation_painter.dart \
  lib/features/social/presentation/widgets/constellation_map.dart \
  lib/features/social/presentation/screens/social_screen.dart
git commit -m "feat(social): 별자리 맵 위젯 구현 (북두칠성 패턴, 친구 배치) #64"
```

---

## Task 6: 그룹 티켓 카드 위젯 (그룹 탭)

**Files:**
- Create: `lib/features/social/presentation/widgets/group_ticket_card.dart`

- [ ] **Step 1: 그룹 티켓 카드 구현**

`exploration_detail_screen.dart`의 티켓 스타일을 참고하여 구현.
카드 구성: CREW PASS 라벨, 티켓 코드, 그룹명, 좌석 현황, 활동 인원, 바코드.

```dart
// lib/features/social/presentation/widgets/group_ticket_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_entity.dart';

class GroupTicketCard extends StatefulWidget {
  const GroupTicketCard({
    super.key,
    required this.group,
    this.onTap,
  });

  final GroupEntity group;
  final VoidCallback? onTap;

  @override
  State<GroupTicketCard> createState() => _GroupTicketCardState();
}

class _GroupTicketCardState extends State<GroupTicketCard> {
  bool _isPressed = false;

  int get _onlineCount =>
      widget.group.members.where((m) => m.status == OnlineStatus.online).length;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Hero(
          tag: 'group-ticket-${widget.group.id}',
          child: Container(
            width: 280.w,
            padding: AppPadding.all20,
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: AppRadius.xxlarge,
              border: Border.all(
                color: AppColors.spaceDivider.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: CREW PASS + 티켓 코드
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CREW PASS',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'GR-${widget.group.inviteCode}',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // 중앙: 그룹 이름
                Center(
                  child: Text(
                    widget.group.name,
                    style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSpacing.s16),

                // 좌석 현황
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 미니 좌석 아이콘
                      for (int i = 0; i < widget.group.maxSeats; i++) ...[
                        if (i > 0) SizedBox(width: AppSpacing.s4),
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.small,
                            color: i < widget.group.members.length
                                ? AppColors.secondary.withValues(alpha: 0.6)
                                : AppColors.spaceDivider.withValues(alpha: 0.3),
                          ),
                          child: Icon(
                            i < widget.group.members.length
                                ? Icons.person_rounded
                                : Icons.event_seat_rounded,
                            size: 12.w,
                            color: i < widget.group.members.length
                                ? Colors.white
                                : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.s8),

                // 좌석 수 + 활동 중
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.group.members.length}/${widget.group.maxSeats}',
                        style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.online,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Text(
                        '$_onlineCount명 활동 중',
                        style: AppTextStyles.tag_12.copyWith(color: AppColors.online),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // 바코드
                SizedBox(
                  height: 36.h,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/icons/barcode_lavender.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: SocialScreen 그룹 탭에 티켓 카드 가로 스크롤 연결**

`social_screen.dart`의 `_buildGroupsTab()`을 교체:
```dart
Widget _buildGroupsTab(WidgetRef ref) {
  final groups = ref.watch(groupListProvider);

  if (groups.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpaceEmptyState(
          icon: Icons.groups_rounded,
          color: AppColors.secondary,
          title: '참여 중인 그룹이 없어요',
          subtitle: '그룹에 참여해서 함께 목표를 달성해요',
        ),
        SizedBox(height: AppSpacing.s24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              text: '그룹 만들기',
              onPressed: () {}, // TODO: 백엔드 연결
              width: 140,
            ),
            SizedBox(width: AppSpacing.s12),
            AppButton(
              text: '초대코드 입력',
              onPressed: () {}, // TODO: 백엔드 연결
              width: 140,
              backgroundColor: AppColors.spaceElevated,
            ),
          ],
        ),
      ],
    );
  }

  return Column(
    children: [
      Expanded(
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Padding(
              padding: AppPadding.horizontal8,
              child: GroupTicketCard(
                group: group,
                onTap: () => context.push(RoutePaths.groupDetailPath(group.id)),
              ),
            );
          },
        ),
      ),
      // 하단 버튼
      Padding(
        padding: AppPadding.all20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              text: '그룹 만들기',
              onPressed: () {}, // TODO: 백엔드 연결
              width: 140,
            ),
            SizedBox(width: AppSpacing.s12),
            AppButton(
              text: '초대코드 입력',
              onPressed: () {}, // TODO: 백엔드 연결
              width: 140,
              backgroundColor: AppColors.spaceElevated,
            ),
          ],
        ),
      ),
    ],
  );
}
```

- [ ] **Step 3: flutter analyze 확인**

Run: `flutter analyze`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/social/presentation/widgets/group_ticket_card.dart \
  lib/features/social/presentation/screens/social_screen.dart
git commit -m "feat(social): 그룹 티켓 카드 위젯 + 가로 스크롤 그룹 탭 구현 #64"
```

---

## Task 7: 그룹 상세 좌석 화면

**Files:**
- Create: `lib/features/social/presentation/widgets/seat_grid.dart`
- Create: `lib/features/social/presentation/screens/group_detail_screen.dart`
- Modify: `lib/routes/app_router.dart`

- [ ] **Step 1: SeatGrid 위젯 구현**

```dart
// lib/features/social/presentation/widgets/seat_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/group_member_entity.dart';

class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.maxSeats,
    required this.members,
    this.onMemberTap,
    this.onEmptySeatTap,
  });

  final int maxSeats;
  final List<GroupMemberEntity> members;
  final void Function(GroupMemberEntity member)? onMemberTap;
  final VoidCallback? onEmptySeatTap;

  int get _crossAxisCount => maxSeats <= 4 ? 2 : 3;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppPadding.all20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.s16,
        mainAxisSpacing: AppSpacing.s16,
      ),
      itemCount: maxSeats,
      itemBuilder: (context, index) {
        final member = members.where((m) => m.seatIndex == index).firstOrNull;
        return _buildSeat(member, index);
      },
    );
  }

  Widget _buildSeat(GroupMemberEntity? member, int index) {
    final isFilled = member != null;
    final statusColor = isFilled
        ? switch (member.status) {
            OnlineStatus.online => AppColors.online,
            OnlineStatus.away => AppColors.away,
            OnlineStatus.offline => AppColors.offline,
          }
        : null;

    return GestureDetector(
      onTap: isFilled
          ? () => onMemberTap?.call(member)
          : onEmptySeatTap,
      child: Container(
        decoration: BoxDecoration(
          color: isFilled
              ? AppColors.spaceElevated
              : AppColors.spaceSurface.withValues(alpha: 0.3),
          borderRadius: AppRadius.large,
          border: Border.all(
            color: isFilled
                ? (statusColor ?? AppColors.offline).withValues(alpha: 0.4)
                : AppColors.spaceDivider.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isFilled && member.status == OnlineStatus.online
              ? [BoxShadow(color: AppColors.online.withValues(alpha: 0.2), blurRadius: 12)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아바타 or 빈 좌석
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.spaceSurface : Colors.transparent,
                border: isFilled
                    ? Border.all(color: statusColor!, width: 2)
                    : null,
              ),
              child: Icon(
                isFilled ? Icons.person_rounded : Icons.event_seat_rounded,
                size: 28.w,
                color: isFilled ? Colors.white : AppColors.textDisabled,
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            // 이름 or 빈 좌석 텍스트
            Text(
              isFilled ? member.name : '빈 좌석',
              style: AppTextStyles.tag_12.copyWith(
                color: isFilled ? Colors.white : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: GroupDetailScreen 구현**

```dart
// lib/features/social/presentation/screens/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../providers/group_provider.dart';
import '../widgets/seat_grid.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupDetailProvider(groupId));

    if (group == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                // AppBar: 뒤로 + 초대코드 복사
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.s4, AppSpacing.s8, AppSpacing.s16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.w),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: group.inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('초대코드가 복사되었습니다: ${group.inviteCode}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              group.inviteCode,
                              style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(width: AppSpacing.s4),
                            SvgPicture.asset(
                              'assets/icons/icon_copy.svg',
                              width: 18.w,
                              height: 18.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.s16),

                // 그룹 제목 (Hero 없음 — 티켓 카드 전체가 Hero source이므로 destination은 생략)
                Text(
                  group.name,
                  style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                ),

                SizedBox(height: AppSpacing.s32),

                // 좌석 그리드
                Expanded(
                  child: SeatGrid(
                    maxSeats: group.maxSeats,
                    members: group.members,
                    onMemberTap: (member) {
                      // TODO: 멤버 프로필로 이동
                    },
                    onEmptySeatTap: () {
                      Clipboard.setData(ClipboardData(text: group.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('초대코드가 복사되었습니다: ${group.inviteCode}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 라우터에 GroupDetailScreen 연결**

`app_router.dart`에서 그룹 상세 route의 `PlaceholderScreen`을 `GroupDetailScreen`으로 교체:
```dart
// 기존
builder: (context, state) {
  final id = state.pathParameters['id']!;
  return PlaceholderScreen(title: '그룹: $id');
},
// 변경
builder: (context, state) {
  final id = state.pathParameters['id']!;
  return GroupDetailScreen(groupId: id);
},
```

- [ ] **Step 4: flutter analyze 확인**

Run: `flutter analyze`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/social/presentation/widgets/seat_grid.dart \
  lib/features/social/presentation/screens/group_detail_screen.dart \
  lib/routes/app_router.dart
git commit -m "feat(social): 그룹 상세 좌석 화면 구현 (SeatGrid + Hero 전환) #64"
```

---

## Task 8: 랭킹 탭 콘텐츠

**Files:**
- Create: `lib/features/social/presentation/widgets/ranking_tab_content.dart`

- [ ] **Step 1: RankingTabContent 위젯 구현**

서브 탭(전체/친구), 기간 필터(오늘/주간/월간), 랭킹 리스트, 내 순위 하단 고정.

```dart
// lib/features/social/presentation/widgets/ranking_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/space/ranking_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../providers/ranking_provider.dart';

class RankingTabContent extends ConsumerStatefulWidget {
  const RankingTabContent({super.key});

  @override
  ConsumerState<RankingTabContent> createState() => _RankingTabContentState();
}

class _RankingTabContentState extends ConsumerState<RankingTabContent>
    with SingleTickerProviderStateMixin {
  late final TabController _subTabController;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _subTabController.addListener(() {
      if (!_subTabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  RankingType get _currentType =>
      _subTabController.index == 0 ? RankingType.all : RankingType.friends;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(
      rankingListProvider(_currentType, _selectedPeriod),
    );
    final myEntry = entries.where((e) => e.isMe).firstOrNull;
    final listEntries = entries.where((e) => !e.isMe).toList();

    return Column(
      children: [
        // 서브 탭: 전체 / 친구
        // 명시적 controller 전달로 상위 DefaultTabController와 격리
        Padding(
          padding: AppPadding.horizontal20,
          child: TabBar(
            controller: _subTabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: AppTextStyles.paragraph14Semibold,
            unselectedLabelStyle: AppTextStyles.paragraph_14_100,
            tabs: const [
              Tab(text: '전체'),
              Tab(text: '친구'),
            ],
          ),
        ),

        SizedBox(height: AppSpacing.s12),

        // 기간 필터
        Padding(
          padding: AppPadding.horizontal20,
          child: Row(
            children: RankingPeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              final label = switch (period) {
                RankingPeriod.today => '오늘',
                RankingPeriod.weekly => '주간',
                RankingPeriod.monthly => '월간',
              };
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.s8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPeriod = period),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.spaceSurface,
                  labelStyle: AppTextStyles.tag_12.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 0),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: AppSpacing.s12),

        // 랭킹 리스트
        Expanded(
          child: listEntries.isEmpty
              ? SpaceEmptyState(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentGold,
                  title: '랭킹 준비 중',
                  subtitle: '공부 시간을 기록하면 랭킹에 참여할 수 있어요',
                )
              : ListView.separated(
                  padding: AppPadding.horizontal20,
                  itemCount: listEntries.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final entry = listEntries[index];
                    return RankingItem(
                      rank: entry.rank,
                      userName: entry.name,
                      studyTime: Duration(minutes: entry.studyTimeMinutes),
                      isCurrentUser: false,
                    );
                  },
                ),
        ),

        // 내 순위 하단 고정
        if (myEntry != null) ...[
          Divider(color: AppColors.spaceDivider, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s8),
            child: RankingItem(
              rank: myEntry.rank,
              userName: myEntry.name,
              studyTime: Duration(minutes: myEntry.studyTimeMinutes),
              isCurrentUser: true,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: SocialScreen 랭킹 탭에 연결**

`social_screen.dart`의 `_buildRankingTab()`을 교체:
```dart
Widget _buildRankingTab() {
  return const RankingTabContent();
}
```

- [ ] **Step 3: flutter analyze 확인**

Run: `flutter analyze`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/social/presentation/widgets/ranking_tab_content.dart \
  lib/features/social/presentation/screens/social_screen.dart
git commit -m "feat(social): 랭킹 탭 구현 (전체/친구 서브탭 + 기간 필터 + RankingItem) #64"
```

---

## Task 9: 통합 검증 + 정리

**Files:**
- All files created/modified above

- [ ] **Step 1: flutter analyze 전체 프로젝트**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: 빌드 확인**

Run: `flutter build apk --debug` (또는 `flutter run` 으로 실행 확인)

- [ ] **Step 3: 화면 전환 흐름 수동 검증**

확인 항목:
1. 소셜 탭 → 친구 탭 → 별자리 맵 표시 (북두칠성 패턴 + 3명 Mock 친구)
2. 소셜 탭 → 그룹 탭 → 티켓 가로 스크롤 (2개 Mock 그룹)
3. 그룹 티켓 탭 → Hero → 그룹 상세 좌석 화면
4. 좌석 화면 초대코드 복사 동작
5. 소셜 탭 → 랭킹 탭 → 전체/친구 전환 + 기간 필터 동작
6. 게스트 모드 → 로그인 유도 화면 (AppBar 없이 SafeArea)

- [ ] **Step 4: 최종 커밋 (필요 시)**

```bash
git add -A
git commit -m "fix(social): 통합 검증 수정사항 반영 #64"
```
