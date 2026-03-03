# CodeRabbit 배지 시스템 리뷰 이슈 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit PR #45 리뷰에서 지적된 배지 시스템의 3가지 코드 이슈를 수정한다.

**Architecture:** 기존 Clean 3-Layer 아키텍처 유지. Data 레이어(DataSource)에 동시성 보호 추가, Domain 레이어(Entity)에 해금 조건 텍스트 헬퍼 추가, Presentation 레이어(Widget)에 접근성 개선.

**Tech Stack:** Flutter · Freezed · SharedPreferences · Riverpod

---

## 수정 대상 요약

| # | 심각도 | 파일 | 이슈 |
|---|--------|------|------|
| 1 | 🟠 Major | `badge_local_datasource.dart` | `unlockBadge`/`clearAll` read-modify-write 경쟁 상태 |
| 2 | 🟠 Major | `badge_detail_dialog.dart` | 잠금 비히든 배지에 해금 조건 대신 description 표시 |
| 3 | 🟡 Minor | `badge_card.dart` | 이모지 렌더링에 Semantics 레이블 누락 |

---

### Task 1: BadgeLocalDataSource 동시성 보호 (Race Condition Fix)

**Files:**
- Modify: `lib/features/badge/data/datasources/badge_local_datasource.dart`

**배경:** `unlockBadge`가 read → modify → write 패턴인데, 동시 호출 시 마지막 write가 이전 변경을 덮어쓸 수 있음. `clearAll`도 같은 키를 사용하므로 동일 위험.

**Step 1: `_writeLock` 필드와 `_synchronized` 헬퍼 추가**

`badge_local_datasource.dart`에 write 직렬화 패턴을 추가한다:

```dart
import 'dart:async';
// ... 기존 import 유지

class BadgeLocalDataSource {
  static const _unlockedKey = 'badge_unlocked_data';

  final SharedPreferences _prefs;
  Future<void> _writeLock = Future.value();

  BadgeLocalDataSource(this._prefs);

  /// write 작업 직렬화 — 동시 호출 시 순차 실행 보장
  Future<void> _synchronized(Future<void> Function() fn) async {
    final previous = _writeLock;
    final completer = Completer<void>();
    _writeLock = completer.future;
    await previous;
    try {
      await fn();
    } finally {
      completer.complete();
    }
  }
```

**Step 2: `unlockBadge`와 `clearAll`을 `_synchronized`로 래핑**

```dart
  Future<void> unlockBadge(BadgeUnlockModel model) async {
    await _synchronized(() async {
      final current = getUnlockedBadges();
      current[model.badgeId] = model;
      await _saveAll(current.values.toList());
    });
  }

  Future<void> clearAll() async {
    await _synchronized(() async {
      await _prefs.remove(_unlockedKey);
      debugPrint('Badge 캐시 삭제 완료');
    });
  }
```

**Step 3: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues

**Step 4: 커밋**

```bash
git add lib/features/badge/data/datasources/badge_local_datasource.dart
git commit -m "fix: BadgeLocalDataSource write 경쟁 상태 방지 #44"
```

---

### Task 2: 잠금 배지 해금 조건 텍스트 표시 (Badge Detail Dialog Fix)

**Files:**
- Modify: `lib/features/badge/domain/entities/badge_entity.dart`
- Modify: `lib/features/badge/presentation/widgets/badge_detail_dialog.dart`

**배경:** 비히든 잠금 배지가 `badge.description`을 그대로 표시 중. `description`이 현재는 해금 조건을 포함하고 있지만, `category`+`requiredValue`에서 동적으로 생성하는 것이 더 견고함. CodeRabbit은 PR 목표("잠금 배지 해금 조건 표시")와 구현 불일치를 지적.

**Step 1: `BadgeEntity`에 `unlockConditionText` extension 추가**

`badge_entity.dart` 파일 하단에 extension 추가:

```dart
/// 배지 해금 조건 텍스트 (잠금 상태에서 표시용)
extension BadgeEntityX on BadgeEntity {
  String get unlockConditionText {
    switch (category) {
      case BadgeCategory.studyTime:
        final hours = requiredValue ~/ 60;
        if (hours >= 1) {
          return '누적 공부 시간 ${_formatNumber(hours)}시간 달성';
        }
        return '누적 공부 시간 $requiredValue분 달성';
      case BadgeCategory.streak:
        return '$requiredValue일 연속 공부 달성';
      case BadgeCategory.session:
        return '공부 세션 ${_formatNumber(requiredValue)}회 완료';
      case BadgeCategory.exploration:
        // 탐험은 ID 기반 분기가 필요해 description 사용
        return description;
      case BadgeCategory.fuel:
        return '연료 총 ${_formatNumber(requiredValue)} 충전';
      case BadgeCategory.hidden:
        return '???';
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return value.toString();
  }
}
```

**Step 2: `badge_detail_dialog.dart`에서 잠금 배지 텍스트를 `unlockConditionText` 사용으로 변경**

기존:
```dart
          badge.isUnlocked || isUnlockCelebration
              ? badge.description
              : badge.category == BadgeCategory.hidden
              ? '아직 해금되지 않은 배지예요'
              : badge.description,
```

변경:
```dart
          badge.isUnlocked || isUnlockCelebration
              ? badge.description
              : badge.category == BadgeCategory.hidden
              ? '아직 해금되지 않은 배지예요'
              : '해금 조건: ${badge.unlockConditionText}',
```

**Step 3: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues

**Step 4: 커밋**

```bash
git add lib/features/badge/domain/entities/badge_entity.dart
git add lib/features/badge/presentation/widgets/badge_detail_dialog.dart
git commit -m "fix: 잠금 배지 해금 조건을 category/requiredValue 기반으로 표시 #44"
```

---

### Task 3: BadgeCard 이모지 접근성 개선 (Semantics Label)

**Files:**
- Modify: `lib/features/badge/presentation/widgets/badge_card.dart`

**배경:** 이모지를 `Text` 위젯으로 직접 렌더링하면 스크린 리더가 유니코드 이름을 읽음. `Semantics` 래퍼로 의미 있는 레이블 제공 필요.

**Step 1: 이모지 Text에 `Semantics` 래퍼 추가**

`badge_card.dart`의 아이콘 렌더링 부분을 변경:

기존 (line 117-122):
```dart
              // 아이콘 (이모지 직접 렌더링)
              Text(
                widget.isUnlocked ? widget.icon : '🔒',
                style: TextStyle(fontSize: 28.sp),
              ),
```

변경:
```dart
              // 아이콘 (이모지 직접 렌더링)
              Semantics(
                label: widget.isUnlocked
                    ? '${widget.name} 배지 아이콘'
                    : '잠긴 배지',
                child: ExcludeSemantics(
                  child: Text(
                    widget.isUnlocked ? widget.icon : '🔒',
                    style: TextStyle(fontSize: 28.sp),
                  ),
                ),
              ),
```

**Step 2: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/badge/presentation/widgets/badge_card.dart
git commit -m "fix: BadgeCard 이모지에 Semantics 레이블 추가 #44"
```

---

## 제외한 이슈 (문서 전용 / 저위험)

| 이슈 | 사유 |
|------|------|
| 계획 문서 import 경로 충돌 | 런타임 코드 아님, 참고용 문서 |
| 리뷰 계획 문서 헤더 레벨 점프 | 런타임 코드 아님, 참고용 문서 |
| `badgeLocalDataSource` 조건부 초기화 | `SharedPreferences`는 모바일에서 실패 가능성 극히 낮음, 기존 설계 의도 유지 |
