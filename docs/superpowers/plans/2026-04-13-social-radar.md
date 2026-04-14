# Social Radar View Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 소셜 화면 친구 탭에 우주 정거장 레이더 뷰를 구현한다. "나"를 중심으로 친구들이 링 위에 배치되는 풀스크린 레이더 UI.

**Architecture:** 더미 데이터 기반 FriendsProvider → SocialRadarView → RadarBackground + RadarScene + RadarStatusBar 레이어 분리. 각 위젯은 단일 책임을 가지며 AppColors 상수만 사용. SocialScreen의 `_buildFriendsTab()`에서 SocialRadarView를 호출.

**Tech Stack:** Flutter, Riverpod 2.6 + riverpod_annotation, Freezed 2.5, CustomPainter (링/연결선), AnimationController (pulse 효과)

---

## File Map

| 파일 | 역할 | 새 파일 여부 |
|-----|------|------------|
| `lib/features/social/domain/entities/friend_entity.dart` | FriendEntity + FriendStatus enum | 신규 |
| `lib/features/social/presentation/providers/friends_provider.dart` | 더미 데이터 provider | 신규 |
| `lib/features/social/presentation/widgets/radar_background.dart` | 배경 격자 + CustomPaint | 신규 |
| `lib/features/social/presentation/widgets/me_node.dart` | 중앙 "나" 노드 | 신규 |
| `lib/features/social/presentation/widgets/friend_node.dart` | 친구 노드 + pulse 애니메이션 | 신규 |
| `lib/features/social/presentation/widgets/radar_scene.dart` | 링 3개 + 노드 배치 | 신규 |
| `lib/features/social/presentation/widgets/radar_status_bar.dart` | 하단 상태바 | 신규 |
| `lib/features/social/presentation/widgets/social_radar_view.dart` | 최상위 레이더 위젯 | 신규 |
| `lib/features/social/presentation/screens/social_screen.dart` | `_buildFriendsTab()` 수정 | 수정 |
| `test/features/social/domain/entities/friend_entity_test.dart` | Entity 단위 테스트 | 신규 |
| `test/features/social/presentation/providers/friends_provider_test.dart` | Provider 단위 테스트 | 신규 |
| `test/features/social/presentation/widgets/radar_status_bar_test.dart` | StatusBar 위젯 테스트 | 신규 |
| `test/features/social/presentation/widgets/social_radar_view_test.dart` | SocialRadarView 스모크 테스트 | 신규 |

---

## Task 1: FriendEntity + FriendStatus

**Files:**
- Create: `lib/features/social/domain/entities/friend_entity.dart`
- Test: `test/features/social/domain/entities/friend_entity_test.dart`

> **주의:** Freezed 코드 생성이 필요하므로 `part` 선언을 추가하고 build_runner를 실행해야 한다.

- [ ] **Step 1: 테스트 먼저 작성**

`test/features/social/domain/entities/friend_entity_test.dart`:

```dart
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
      expect(updated.id, 'u3'); // 나머지 필드 유지
    });

    test('동일 값이면 equality가 성립한다', () {
      const a = FriendEntity(id: 'u4', name: '최성운', status: FriendStatus.idle);
      const b = FriendEntity(id: 'u4', name: '최성운', status: FriendStatus.idle);
      expect(a, equals(b));
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
cd /Users/luca/workspace/Flutter_Project/space_study_ship
flutter test test/features/social/domain/entities/friend_entity_test.dart
```

Expected: 컴파일 에러 (파일이 없으므로)

- [ ] **Step 3: FriendEntity 구현**

`lib/features/social/domain/entities/friend_entity.dart`:

```dart
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
  }) = _FriendEntity;
}
```

- [ ] **Step 4: build_runner 실행**

```bash
cd /Users/luca/workspace/Flutter_Project/space_study_ship
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `friend_entity.freezed.dart` 생성

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/social/domain/entities/friend_entity_test.dart
```

Expected: All tests pass

- [ ] **Step 6: 커밋**

```bash
git add lib/features/social/domain/entities/friend_entity.dart \
        lib/features/social/domain/entities/friend_entity.freezed.dart \
        test/features/social/domain/entities/friend_entity_test.dart
git commit -m "feat : FriendEntity + FriendStatus enum 정의 #67"
```

---

## Task 2: FriendsProvider (더미 데이터)

**Files:**
- Create: `lib/features/social/presentation/providers/friends_provider.dart`
- Test: `test/features/social/presentation/providers/friends_provider_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

`test/features/social/presentation/providers/friends_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/providers/friends_provider.dart';

void main() {
  group('friendsProvider', () {
    test('더미 데이터 리스트를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);

      expect(friends, isNotEmpty);
      expect(friends.every((f) => f.id.isNotEmpty), isTrue);
      expect(friends.every((f) => f.name.isNotEmpty), isTrue);
    });

    test('studying 상태 친구가 포함된다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final studying = friends.where((f) => f.status == FriendStatus.studying);

      expect(studying, isNotEmpty);
    });

    test('studying 친구는 studyDuration을 가진다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final studying = friends.where((f) => f.status == FriendStatus.studying);

      for (final f in studying) {
        expect(f.studyDuration, isNotNull);
      }
    });

    test('studyingCount + idleCount + offlineCount = 전체 친구 수', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final studyingCount = container.read(studyingCountProvider);
      final idleCount = container.read(idleCountProvider);

      expect(
        studyingCount + idleCount + friends.where((f) => f.status == FriendStatus.offline).length,
        friends.length,
      );
    });
  });

  group('studyingCountProvider', () {
    test('studying 상태 친구 수를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final expected = friends.where((f) => f.status == FriendStatus.studying).length;

      expect(container.read(studyingCountProvider), expected);
    });
  });

  group('idleCountProvider', () {
    test('idle 상태 친구 수를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final friends = container.read(friendsProvider);
      final expected = friends.where((f) => f.status == FriendStatus.idle).length;

      expect(container.read(idleCountProvider), expected);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/social/presentation/providers/friends_provider_test.dart
```

Expected: 컴파일 에러

- [ ] **Step 3: FriendsProvider 구현**

`lib/features/social/presentation/providers/friends_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/friend_entity.dart';

/// 더미 친구 데이터
///
/// 실제 API 완성 시 이 Provider를 교체한다.
/// FriendEntity 구조는 유지하면서 데이터 소스만 변경.
final friendsProvider = Provider<List<FriendEntity>>((ref) {
  return const [
    FriendEntity(
      id: 'u1',
      name: '김우주',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 2, minutes: 35),
      currentSubject: '수학',
    ),
    FriendEntity(
      id: 'u2',
      name: '박탐험',
      status: FriendStatus.studying,
      studyDuration: Duration(hours: 1, minutes: 12),
      currentSubject: '영어',
    ),
    FriendEntity(
      id: 'u3',
      name: '이별자리',
      status: FriendStatus.studying,
      studyDuration: Duration(minutes: 47),
      currentSubject: '물리',
    ),
    FriendEntity(
      id: 'u4',
      name: '최성운',
      status: FriendStatus.idle,
    ),
    FriendEntity(
      id: 'u5',
      name: '정혜성',
      status: FriendStatus.idle,
    ),
    FriendEntity(
      id: 'u6',
      name: '한은하',
      status: FriendStatus.offline,
    ),
    FriendEntity(
      id: 'u7',
      name: '오행성',
      status: FriendStatus.offline,
    ),
  ];
});

/// 공부 중인 친구 수
final studyingCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).where((f) => f.status == FriendStatus.studying).length;
});

/// 대기 중인 친구 수
final idleCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).where((f) => f.status == FriendStatus.idle).length;
});

/// 내부링에 배치할 친구 (studying → 내부링 우선, 최대 6명)
final innerRingFriendsProvider = Provider<List<FriendEntity>>((ref) {
  final friends = ref.watch(friendsProvider);
  return friends.where((f) => f.status == FriendStatus.studying).take(6).toList();
});

/// 외부링에 배치할 친구 (나머지, 최대 10명)
final outerRingFriendsProvider = Provider<List<FriendEntity>>((ref) {
  final friends = ref.watch(friendsProvider);
  final inner = ref.watch(innerRingFriendsProvider);
  final innerIds = inner.map((f) => f.id).toSet();
  return friends.where((f) => !innerIds.contains(f.id)).take(10).toList();
});
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/features/social/presentation/providers/friends_provider_test.dart
```

Expected: All tests pass

- [ ] **Step 5: 커밋**

```bash
git add lib/features/social/presentation/providers/friends_provider.dart \
        test/features/social/presentation/providers/friends_provider_test.dart
git commit -m "feat : FriendsProvider 더미 데이터 + 파생 provider 구현 #67"
```

---

## Task 3: RadarBackground 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/radar_background.dart`

> RadarBackground는 단순 CustomPaint 래퍼로 테스트보다 분석 용이성에 집중.
> Widget test는 Task 8(SocialRadarView smoke test)에서 통합 검증한다.

- [ ] **Step 1: RadarBackground 구현**

`lib/features/social/presentation/widgets/radar_background.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// 레이더 배경: spaceBackground + 28px 격자선
class RadarBackground extends StatelessWidget {
  const RadarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const gridSize = 28.0;

    // 수직선
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // 수평선
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/radar_background.dart
```

Expected: No issues

- [ ] **Step 3: 커밋 (Task 4와 함께)**

Task 4(MeNode) 완료 후 같이 커밋한다.

---

## Task 4: MeNode 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/me_node.dart`

- [ ] **Step 1: MeNode 구현**

`lib/features/social/presentation/widgets/me_node.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/text_styles.dart';

/// 레이더 중앙 "나(YOU)" 노드
///
/// 크기: 56×56, 원형
/// 배경: spaceElevated
/// 테두리: primary 2.5px + glow primary.withOpacity(0.3)
class MeNode extends StatelessWidget {
  const MeNode({super.key, this.initial = 'ME'});

  /// 프로필 이니셜 (최대 2자)
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.spaceElevated,
        border: Border.all(
          color: AppColors.primary,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial.length > 2 ? initial.substring(0, 2) : initial,
          style: AppTextStyles.tag_12.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/me_node.dart
```

Expected: No issues

- [ ] **Step 3: RadarBackground + MeNode 함께 커밋**

```bash
git add lib/features/social/presentation/widgets/radar_background.dart \
        lib/features/social/presentation/widgets/me_node.dart
git commit -m "feat : RadarBackground 격자 배경 + MeNode 중앙 노드 위젯 구현 #67"
```

---

## Task 5: FriendNode 위젯 (pulse 애니메이션 포함)

**Files:**
- Create: `lib/features/social/presentation/widgets/friend_node.dart`

- [ ] **Step 1: FriendNode 구현**

`lib/features/social/presentation/widgets/friend_node.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../domain/entities/friend_entity.dart';

/// 레이더 친구 노드
///
/// - studying: 테두리 success + pulse 애니메이션 (scale 1.0→1.8, opacity 0.7→0, 2.5초 반복)
/// - idle/offline: 테두리 spaceDivider, opacity 0.6
/// 크기: 내부링 36×36 / 외부링 30×30 (isInnerRing으로 구분)
class FriendNode extends StatefulWidget {
  const FriendNode({
    super.key,
    required this.friend,
    this.isInnerRing = true,
  });

  final FriendEntity friend;
  final bool isInnerRing;

  @override
  State<FriendNode> createState() => _FriendNodeState();
}

class _FriendNodeState extends State<FriendNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (widget.friend.status == FriendStatus.studying) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(FriendNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.friend.status == FriendStatus.studying) {
      if (!_pulseController.isAnimating) _pulseController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isInnerRing ? 36.0 : 30.0;
    final isStudying = widget.friend.status == FriendStatus.studying;
    final borderColor =
        isStudying ? AppColors.success : AppColors.spaceDivider;
    final nodeOpacity = isStudying ? 1.0 : 0.6;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse 링 (studying일 때만)
        if (isStudying)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // 노드 본체
        Opacity(
          opacity: nodeOpacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.spaceElevated,
              border: Border.all(color: borderColor, width: 2.0),
              boxShadow: isStudying
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                _initial(widget.friend.name),
                style: AppTextStyles.tag_10.copyWith(
                  color: isStudying
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 이름에서 이니셜 추출 (첫 글자)
  String _initial(String name) {
    if (name.isEmpty) return '?';
    return name.characters.first;
  }
}
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/friend_node.dart
```

Expected: No issues

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/widgets/friend_node.dart
git commit -m "feat : FriendNode 위젯 + pulse 애니메이션 구현 #67"
```

---

## Task 6: RadarScene 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/radar_scene.dart`

- [ ] **Step 1: RadarScene 구현**

`lib/features/social/presentation/widgets/radar_scene.dart`:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/friend_entity.dart';
import 'friend_node.dart';
import 'me_node.dart';

/// 레이더 씬: 링 3개 + 연결선 + 노드 배치
///
/// 링 반지름: ring1=50, ring2=95(dashed), ring3=140
/// 내부링(ring2) 최대 6명, 외부링(ring3) 최대 10명
class RadarScene extends StatelessWidget {
  const RadarScene({
    super.key,
    required this.innerFriends,
    required this.outerFriends,
  });

  final List<FriendEntity> innerFriends;
  final List<FriendEntity> outerFriends;

  static const double _ring1Radius = 50.0;
  static const double _ring2Radius = 95.0;
  static const double _ring3Radius = 140.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cx = constraints.maxWidth / 2;
        final cy = constraints.maxHeight / 2;

        return Stack(
          children: [
            // 링 + 연결선 CustomPaint
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _RadarRingPainter(
                center: Offset(cx, cy),
                innerFriends: innerFriends,
                outerFriends: outerFriends,
              ),
            ),
            // 외부링 친구 노드
            ..._buildFriendNodes(
              friends: outerFriends,
              center: Offset(cx, cy),
              radius: _ring3Radius,
              isInnerRing: false,
            ),
            // 내부링 친구 노드
            ..._buildFriendNodes(
              friends: innerFriends,
              center: Offset(cx, cy),
              radius: _ring2Radius,
              isInnerRing: true,
            ),
            // 중앙 나 노드
            Positioned(
              left: cx - 28,
              top: cy - 28,
              child: const MeNode(),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFriendNodes({
    required List<FriendEntity> friends,
    required Offset center,
    required double radius,
    required bool isInnerRing,
  }) {
    if (friends.isEmpty) return [];

    final nodeSize = isInnerRing ? 36.0 : 30.0;
    final half = nodeSize / 2;

    return List.generate(friends.length, (i) {
      final angle = (2 * math.pi / friends.length) * i - math.pi / 2;
      final dx = center.dx + radius * math.cos(angle) - half;
      final dy = center.dy + radius * math.sin(angle) - half;
      return Positioned(
        left: dx,
        top: dy,
        child: FriendNode(
          friend: friends[i],
          isInnerRing: isInnerRing,
        ),
      );
    });
  }
}

class _RadarRingPainter extends CustomPainter {
  const _RadarRingPainter({
    required this.center,
    required this.innerFriends,
    required this.outerFriends,
  });

  final Offset center;
  final List<FriendEntity> innerFriends;
  final List<FriendEntity> outerFriends;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRings(canvas);
    _drawConnections(canvas, innerFriends, RadarScene._ring2Radius, true);
    _drawConnections(canvas, outerFriends, RadarScene._ring3Radius, false);
  }

  void _drawRings(Canvas canvas) {
    // Ring 1 (내부 장식용)
    canvas.drawCircle(
      center,
      RadarScene._ring1Radius,
      Paint()
        ..color = AppColors.spaceDivider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Ring 2 (내부링 - dashed)
    _drawDashedCircle(
      canvas,
      center,
      RadarScene._ring2Radius,
      AppColors.spaceElevated,
    );

    // Ring 3 (외부링)
    canvas.drawCircle(
      center,
      RadarScene._ring3Radius,
      Paint()
        ..color = AppColors.spaceSurface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    const dashAngle = 0.08;
    const gapAngle = 0.04;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double angle = 0;
    while (angle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashAngle,
        false,
        paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  void _drawConnections(
    Canvas canvas,
    List<FriendEntity> friends,
    double radius,
    bool isInnerRing,
  ) {
    if (friends.isEmpty) return;

    for (int i = 0; i < friends.length; i++) {
      final angle = (2 * math.pi / friends.length) * i - math.pi / 2;
      final friendPos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final isStudying = friends[i].status == FriendStatus.studying;
      final lineColor = isStudying
          ? AppColors.success.withValues(alpha: 0.35)
          : AppColors.spaceDivider;

      canvas.drawLine(
        center,
        friendPos,
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarRingPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.innerFriends != innerFriends ||
      oldDelegate.outerFriends != outerFriends;
}
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/radar_scene.dart
```

Expected: No issues

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/widgets/radar_scene.dart
git commit -m "feat : RadarScene 링 3개 + 연결선 + 노드 배치 구현 #67"
```

---

## Task 7: RadarStatusBar 위젯

**Files:**
- Create: `lib/features/social/presentation/widgets/radar_status_bar.dart`
- Test: `test/features/social/presentation/widgets/radar_status_bar_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

`test/features/social/presentation/widgets/radar_status_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/social/presentation/widgets/radar_status_bar.dart';

void main() {
  Widget buildSubject({
    int studyingCount = 3,
    int idleCount = 2,
    VoidCallback? onAddFriend,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RadarStatusBar(
          studyingCount: studyingCount,
          idleCount: idleCount,
          onAddFriend: onAddFriend ?? () {},
        ),
      ),
    );
  }

  group('RadarStatusBar', () {
    testWidgets('공부중 N명 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(buildSubject(studyingCount: 4));
      expect(find.textContaining('4'), findsAtLeastNWidgets(1));
      expect(find.textContaining('공부중'), findsOneWidget);
    });

    testWidgets('대기 N명 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(buildSubject(idleCount: 2));
      expect(find.textContaining('2'), findsAtLeastNWidgets(1));
      expect(find.textContaining('대기'), findsOneWidget);
    });

    testWidgets('친구 추가 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.textContaining('친구'), findsAtLeastNWidgets(1));
    });

    testWidgets('친구 추가 버튼 탭 시 콜백이 호출된다', (tester) async {
      var called = false;
      await tester.pumpWidget(buildSubject(onAddFriend: () => called = true));

      await tester.tap(find.text('+ 친구 추가'));
      expect(called, isTrue);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/social/presentation/widgets/radar_status_bar_test.dart
```

Expected: 컴파일 에러

- [ ] **Step 3: RadarStatusBar 구현**

`lib/features/social/presentation/widgets/radar_status_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/constants/text_styles.dart';

/// 레이더 하단 상태바
///
/// 배경: spaceSurface, 상단 경계: spaceDivider 1px
/// 좌측: 공부중 N명 (success 도트)
/// 중앙: 대기 N명 (spaceDivider 도트)
/// 우측: + 친구 추가 버튼 (primary 배경, pill shape)
class RadarStatusBar extends StatelessWidget {
  const RadarStatusBar({
    super.key,
    required this.studyingCount,
    required this.idleCount,
    required this.onAddFriend,
  });

  final int studyingCount;
  final int idleCount;
  final VoidCallback onAddFriend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        border: Border(
          top: BorderSide(color: AppColors.spaceDivider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _StatusDot(
            color: AppColors.success,
            label: '공부중 $studyingCount명',
          ),
          SizedBox(width: AppSpacing.s16),
          _StatusDot(
            color: AppColors.spaceDivider,
            label: '대기 $idleCount명',
          ),
          const Spacer(),
          _AddFriendButton(onPressed: onAddFriend),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _AddFriendButton extends StatelessWidget {
  const _AddFriendButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '+ 친구 추가',
          style: AppTextStyles.tag_12.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/features/social/presentation/widgets/radar_status_bar_test.dart
```

Expected: All tests pass

- [ ] **Step 5: 커밋**

```bash
git add lib/features/social/presentation/widgets/radar_status_bar.dart \
        test/features/social/presentation/widgets/radar_status_bar_test.dart
git commit -m "feat : RadarStatusBar 하단 상태바 위젯 구현 #67"
```

---

## Task 8: SocialRadarView + SocialScreen 연결

**Files:**
- Create: `lib/features/social/presentation/widgets/social_radar_view.dart`
- Modify: `lib/features/social/presentation/screens/social_screen.dart`
- Test: `test/features/social/presentation/widgets/social_radar_view_test.dart`

- [ ] **Step 1: 스모크 테스트 먼저 작성**

`test/features/social/presentation/widgets/social_radar_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_study_ship/features/social/presentation/widgets/social_radar_view.dart';

void main() {
  group('SocialRadarView', () {
    testWidgets('렌더링 시 크래시가 없다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SocialRadarView(),
            ),
          ),
        ),
      );
      await tester.pump(); // 애니메이션 첫 프레임

      // 크래시 없이 렌더링됨을 확인
      expect(find.byType(SocialRadarView), findsOneWidget);
    });

    testWidgets('RadarStatusBar가 화면에 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SocialRadarView(),
            ),
          ),
        ),
      );
      await tester.pump();

      // 상태바 텍스트 확인
      expect(find.textContaining('공부중'), findsOneWidget);
      expect(find.textContaining('대기'), findsOneWidget);
    });

    testWidgets('+ 친구 추가 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SocialRadarView(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('+ 친구 추가'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/social/presentation/widgets/social_radar_view_test.dart
```

Expected: 컴파일 에러

- [ ] **Step 3: SocialRadarView 구현**

`lib/features/social/presentation/widgets/social_radar_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/friends_provider.dart';
import 'radar_background.dart';
import 'radar_scene.dart';
import 'radar_status_bar.dart';

/// 친구 탭 레이더 뷰 (최상위)
///
/// RadarBackground + RadarScene + RadarStatusBar 조합
/// Riverpod으로 friends 데이터를 주입받아 하위 위젯에 전달
class SocialRadarView extends ConsumerWidget {
  const SocialRadarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final innerFriends = ref.watch(innerRingFriendsProvider);
    final outerFriends = ref.watch(outerRingFriendsProvider);
    final studyingCount = ref.watch(studyingCountProvider);
    final idleCount = ref.watch(idleCountProvider);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const RadarBackground(),
              RadarScene(
                innerFriends: innerFriends,
                outerFriends: outerFriends,
              ),
            ],
          ),
        ),
        RadarStatusBar(
          studyingCount: studyingCount,
          idleCount: idleCount,
          onAddFriend: () {
            // TODO(#67): 친구 추가 기능 연결 (API 완성 후)
          },
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: SocialScreen 수정**

`lib/features/social/presentation/screens/social_screen.dart`의 `_buildFriendsTab()` 메서드를 수정:

기존:
```dart
Widget _buildFriendsTab() {
  return SpaceEmptyState(
    icon: Icons.people_rounded,
    color: AppColors.primary,
    title: '아직 친구가 없어요',
    subtitle: '친구를 추가해서 함께 공부해요',
  );
}
```

변경 후:
```dart
Widget _buildFriendsTab() {
  return const SocialRadarView();
}
```

import 추가 (파일 상단):
```dart
import '../widgets/social_radar_view.dart';
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/social/presentation/widgets/social_radar_view_test.dart
```

Expected: All tests pass

- [ ] **Step 6: 전체 analyze 확인**

```bash
flutter analyze lib/features/social/
```

Expected: No issues

- [ ] **Step 7: 커밋**

```bash
git add lib/features/social/presentation/widgets/social_radar_view.dart \
        lib/features/social/presentation/screens/social_screen.dart \
        test/features/social/presentation/widgets/social_radar_view_test.dart
git commit -m "feat : SocialRadarView 최상위 위젯 + SocialScreen 친구탭 연결 #67"
```

---

## Task 9: 최종 검증

- [ ] **Step 1: 전체 테스트 실행**

```bash
flutter test test/features/social/
```

Expected: All tests pass

- [ ] **Step 2: flutter analyze 전체 확인**

```bash
flutter analyze
```

Expected: No issues

- [ ] **Step 3: design-guardian 셀프체크**

아래 패턴이 social 위젯에 없는지 확인:
```bash
grep -r "Color(0xFF" lib/features/social/
grep -r "TextStyle(" lib/features/social/
grep -r "BoxShadow(" lib/features/social/
```

Expected: BoxShadow는 me_node.dart와 friend_node.dart에 AppColors 사용으로 허용. Color(0xFF 리터럴과 TextStyle( 인라인은 없어야 함.

- [ ] **Step 4: 확인 항목**

- [ ] 친구 탭에 레이더 뷰가 표시됨
- [ ] "나" 노드가 중앙에 고정
- [ ] 더미 친구 데이터로 노드가 링 위에 배치됨
- [ ] studying 친구에 pulse 애니메이션 동작
- [ ] AppColors 외 하드코딩 색상 없음
- [ ] flutter analyze 경고 0개
- [ ] 게스트 모드에서 기존 로그인 유도 화면 유지

---

## 커밋 요약

| 커밋 | 포함 파일 |
|-----|---------|
| `feat : FriendEntity + FriendStatus enum 정의 #67` | friend_entity.dart, friend_entity.freezed.dart, 테스트 |
| `feat : FriendsProvider 더미 데이터 + 파생 provider 구현 #67` | friends_provider.dart, 테스트 |
| `feat : RadarBackground 격자 배경 + MeNode 중앙 노드 위젯 구현 #67` | radar_background.dart, me_node.dart |
| `feat : FriendNode 위젯 + pulse 애니메이션 구현 #67` | friend_node.dart |
| `feat : RadarScene 링 3개 + 연결선 + 노드 배치 구현 #67` | radar_scene.dart |
| `feat : RadarStatusBar 하단 상태바 위젯 구현 #67` | radar_status_bar.dart, 테스트 |
| `feat : SocialRadarView 최상위 위젯 + SocialScreen 친구탭 연결 #67` | social_radar_view.dart, social_screen.dart, 테스트 |
