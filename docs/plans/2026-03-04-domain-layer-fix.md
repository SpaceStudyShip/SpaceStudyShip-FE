# Domain 레이어 독립성 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `firebase_auth_error_handler.dart`를 domain에서 data 레이어로 이동하여 domain 레이어의 외부 의존성을 제거한다.

**Architecture:** Domain 레이어는 순수 Dart만 허용 (DIP). Firebase SDK 의존 파일은 data 레이어에 위치해야 한다.

**Tech Stack:** Flutter · Clean Architecture

---

### Task 1: 파일 이동 (domain → data)

**Files:**
- Move: `lib/features/auth/domain/utils/firebase_auth_error_handler.dart` → `lib/features/auth/data/utils/firebase_auth_error_handler.dart`

**Step 1: data/utils 디렉토리 생성 및 파일 이동**

Run:
```bash
mkdir -p lib/features/auth/data/utils
git mv lib/features/auth/domain/utils/firebase_auth_error_handler.dart lib/features/auth/data/utils/firebase_auth_error_handler.dart
```

**Step 2: 빈 domain/utils 디렉토리 삭제**

Run:
```bash
rmdir lib/features/auth/domain/utils
```

---

### Task 2: import 경로 수정

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:19`

기존:
```dart
import '../../domain/utils/firebase_auth_error_handler.dart';
```

변경:
```dart
import '../../data/utils/firebase_auth_error_handler.dart';
```

---

### Task 3: 이동된 파일 내부 import 경로 수정

**Files:**
- Modify: `lib/features/auth/data/utils/firebase_auth_error_handler.dart:4`

기존 (domain 기준 상대경로):
```dart
import '../../../../core/errors/app_exception.dart';
```

변경 (data 기준 상대경로 — 동일 깊이이므로 변경 없음):
```dart
import '../../../../core/errors/app_exception.dart';
```

→ 경로 깊이 동일 (`features/auth/data/utils/` = `features/auth/domain/utils/`). **수정 불필요.**

---

### Task 4: 정적 분석 검증

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: domain 레이어 재검증**

Run:
```bash
grep -r "^import " lib/features/**/domain/**/*.dart | grep -E "(package:firebase|package:flutter|package:dio|/data/|/presentation/)" || echo "✅ Domain 레이어 외부 의존성 없음"
```

Expected: `✅ Domain 레이어 외부 의존성 없음`

---

### Task 5: 커밋

```bash
git add lib/features/auth/data/utils/firebase_auth_error_handler.dart lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "refactor : FirebaseAuthErrorHandler domain→data 이동 (DIP 준수) #46"
```
