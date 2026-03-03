# CodeRabbit 배지 리뷰 이슈 2차 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 1차 수정 커밋에 대한 CodeRabbit 추가 리뷰 2건을 수정한다.

**Architecture:** 기존 구조 유지. DataSource의 catch 블록 비동기 처리 보완, Domain extension의 숫자 포맷 로직 수정.

**Tech Stack:** Flutter · Dart · SharedPreferences

---

## 수정 대상 요약

| # | 심각도 | 파일 | 이슈 |
|---|--------|------|------|
| 1 | 🟠 Major | `badge_local_datasource.dart:44` | catch 블록의 `_prefs.remove()` 미 await → 이후 write와 경합 |
| 2 | 🟡 Minor | `badge_entity.dart:61-64` | `_formatNumber` 100만 이상에서 `1000,000` 형식 오류 |

---

### Task 1: catch 블록의 unawaited remove 경합 조건 수정

**Files:**
- Modify: `lib/features/badge/data/datasources/badge_local_datasource.dart`

**배경:** `getUnlockedBadges()`는 동기 메서드인데, catch 블록에서 `_prefs.remove()`를 await 없이 fire-and-forget으로 호출. 이 remove가 이후 `unlockBadge()`의 `_saveAll()`보다 늦게 완료되면 새로 저장된 데이터를 삭제할 수 있음.

**해결 전략:** `getUnlockedBadges()`를 async로 바꾸면 호출자 전체(Repository, Provider) 시그니처 변경이 필요해 범위가 너무 커짐. 대신 `unawaited(_synchronized(...))`로 remove를 write lock 큐에 넣어, 이후 `unlockBadge()` 호출이 remove 완료를 기다리도록 보장.

**Step 1: catch 블록의 `_prefs.remove()` 수정**

기존 (line 42-46):
```dart
    } catch (e) {
      debugPrint('Badge 데이터 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_unlockedKey);
      return {};
    }
```

변경:
```dart
    } catch (e) {
      debugPrint('Badge 데이터 파싱 실패, 초기화합니다: $e');
      unawaited(_synchronized(() => _prefs.remove(_unlockedKey)));
      return {};
    }
```

이렇게 하면 remove가 `_synchronized` write lock 큐에 들어가므로, 이후 `unlockBadge()`의 `_synchronized` 호출이 remove 완료를 자동으로 기다림.

**Step 2: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/badge/data/datasources/badge_local_datasource.dart
git commit -m "fix: getUnlockedBadges catch 블록의 unawaited remove 경합 조건 수정 #44"
```

---

### Task 2: `_formatNumber` 100만 이상 포맷 수정

**Files:**
- Modify: `lib/features/badge/domain/entities/badge_entity.dart`

**배경:** 현재 `_formatNumber`는 `value ~/ 1000` + `,` + `value % 1000`으로 1회만 분리. `1000000` → `1000,000` (올바른: `1,000,000`).

**Step 1: `_formatNumber` 로직을 범용 천 단위 구분으로 교체**

기존 (line 61-66):
```dart
  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return value.toString();
  }
```

변경:
```dart
  String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
```

검증: `1000` → `1,000`, `60000` → `60,000`, `1000000` → `1,000,000`

**Step 2: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/badge/domain/entities/badge_entity.dart
git commit -m "fix: _formatNumber 100만 이상 천 단위 구분 정상 처리 #44"
```
