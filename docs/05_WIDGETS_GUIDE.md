# 🎨 공용 위젯 가이드 - 우주공부선

> **중복 위젯 방지 가이드** | 새 위젯 작성 전 필수 확인 | 일관된 UI/UX 유지
>
> **⚠️ 중요**: 새 위젯을 만들기 전에 이 문서를 먼저 확인하세요!

---

## 목차
1. [개요](#개요)
2. [Atomic Design 구조](#atomic-design-구조)
3. [공용 위젯 목록](#공용-위젯-목록)
4. [사용 예시](#사용-예시)
5. [새 위젯 작성 가이드](#새-위젯-작성-가이드)
6. [자주 하는 실수](#자주-하는-실수)

---

## 개요

### 왜 공용 위젯을 사용해야 하나요?

✅ **일관된 디자인 시스템**: 모든 화면에서 동일한 UI/UX 제공
✅ **개발 속도 향상**: 이미 만들어진 위젯 재사용으로 빠른 개발
✅ **유지보수 용이**: 한 곳에서 수정하면 전체 앱에 반영
✅ **버그 감소**: 검증된 위젯 사용으로 안정성 확보

### 기본 원칙

1. **새 위젯 작성 전 확인**: 아래 [공용 위젯 목록](#공용-위젯-목록)에 이미 있는지 체크
2. **없으면 요청**: 필요한 위젯이 없다면 `lib/core/widgets/`에 추가 요청
3. **Feature-specific 위젯만 생성**: 정말 해당 Feature에서만 쓰이는 위젯만 `features/<feature>/presentation/widgets/`에 작성

---

## Atomic Design 구조

```
lib/core/widgets/
├── atoms/           # 더 이상 분리 불가능한 기본 요소
│   ├── buttons/     # 버튼
│   ├── inputs/      # 입력 필드
│   └── indicators/  # 로딩, 뱃지 등
│
├── molecules/       # Atoms 조합
│   ├── cards/       # 카드 컴포넌트
│   └── dialogs/     # 다이얼로그
│
└── organisms/       # Molecules 조합
    └── empty_states/ # 빈 상태 화면
```

### Atoms vs Molecules vs Organisms

| 레벨 | 설명 | 예시 |
|------|-----|------|
| **Atoms** | 더 이상 쪼갤 수 없는 최소 단위 | 버튼, 입력 필드, 아이콘 |
| **Molecules** | Atoms 2-3개 조합 | 검색창 (입력 필드 + 버튼), 카드 |
| **Organisms** | Molecules 조합, 독립적 기능 | 헤더, 푸터, 빈 상태 화면 |

---

## 공용 위젯 목록

### 📍 Atoms (기본 요소)

#### 1. SpacePrimaryButton
**위치**: `lib/core/widgets/atoms/buttons/space_primary_button.dart`

**용도**: 주요 액션 버튼 (우주 테마 스타일)

**Props**:
```dart
SpacePrimaryButton({
  required String text,           // 버튼 텍스트
  required VoidCallback? onPressed, // 클릭 콜백 (null이면 비활성)
  bool isLoading = false,          // 로딩 상태 표시
  double? width,                   // 너비 (기본: double.infinity)
  double? height,                  // 높이 (기본: 48.h)
})
```

**상태**:
- ✅ 기본 상태 (활성)
- ⏳ 로딩 상태 (`isLoading: true`)
- 🚫 비활성 상태 (`onPressed: null`)

**사용 예시**:
```dart
// 기본 버튼
SpacePrimaryButton(
  text: '시작하기',
  onPressed: () {
    // 액션 처리
  },
)

// 로딩 버튼
SpacePrimaryButton(
  text: '저장 중...',
  onPressed: () {},
  isLoading: true,
)

// 비활성 버튼
const SpacePrimaryButton(
  text: '비활성',
  onPressed: null,
)
```

**디자인 스펙**:
- 배경색: `AppColors.primary`
- 텍스트: `AppTextStyles.body1.semiBold()`
- Radius: `AppRadius.button` (12px)
- 높이: 48.h (기본)

---

#### 2. SpaceTextField
**위치**: `lib/core/widgets/atoms/inputs/space_text_field.dart`

**용도**: 텍스트 입력 필드

**Props**:
```dart
SpaceTextField({
  String? hintText,                // 힌트 텍스트
  IconData? prefixIcon,            // 앞쪽 아이콘
  IconData? suffixIcon,            // 뒤쪽 아이콘
  bool obscureText = false,        // 비밀번호 모드
  String? errorText,               // 에러 메시지
  TextEditingController? controller, // 컨트롤러
  ValueChanged<String>? onChanged,  // 값 변경 콜백
})
```

**상태**:
- ✅ 기본 상태
- 🔒 비밀번호 모드 (`obscureText: true`)
- ❌ 에러 상태 (`errorText: '...'`)

**사용 예시**:
```dart
// 기본 입력
const SpaceTextField(
  hintText: '이름을 입력하세요',
  prefixIcon: Icons.person,
)

// 비밀번호 입력
const SpaceTextField(
  hintText: '비밀번호',
  prefixIcon: Icons.lock,
  obscureText: true,
)

// 에러 상태
const SpaceTextField(
  hintText: '이메일',
  errorText: '유효한 이메일을 입력하세요',
)
```

---

#### 3. SpaceLoadingIndicator
**위치**: `lib/core/widgets/atoms/indicators/space_loading_indicator.dart`

**용도**: 로딩 인디케이터 (CircularProgressIndicator + 메시지)

**Props**:
```dart
SpaceLoadingIndicator({
  String? message,   // 로딩 메시지 (선택적)
})
```

**사용 예시**:
```dart
// 메시지 있는 로딩
const SpaceLoadingIndicator(
  message: '데이터를 불러오는 중...',
)

// 메시지 없는 로딩
const SpaceLoadingIndicator()
```

---

### 📦 Molecules (조합 요소)

#### 4. SpaceCard
**위치**: `lib/core/widgets/molecules/cards/space_card.dart`

**용도**: 우주 테마 카드 (배경색 + 그림자)

**Props**:
```dart
SpaceCard({
  required Widget child,     // 카드 내용
  EdgeInsets? padding,       // 내부 패딩
  VoidCallback? onTap,       // 탭 콜백 (null이면 클릭 불가)
  BorderRadius? borderRadius, // 모서리 둥글기
})
```

**사용 예시**:
```dart
// 정적 카드
SpaceCard(
  padding: AppPadding.all16,
  child: Text('카드 내용'),
)

// 클릭 가능한 카드
SpaceCard(
  padding: AppPadding.all16,
  onTap: () {
    // 클릭 처리
  },
  child: Text('클릭하세요'),
)
```

**디자인 스펙**:
- 배경색: `AppColors.spaceSurface`
- Radius: `AppRadius.card` (12px)
- 그림자: elevation 2

---

#### 5. SpaceDialog
**위치**: `lib/core/widgets/molecules/dialogs/space_dialog.dart`

**용도**: 우주 테마 다이얼로그 (알림, 확인)

**Props**:
```dart
SpaceDialog.show({
  required BuildContext context,
  required String title,        // 다이얼로그 제목
  required String content,      // 내용
  String? confirmText,          // 확인 버튼 텍스트 (기본: '확인')
  String? cancelText,           // 취소 버튼 텍스트 (기본: '취소')
  VoidCallback? onConfirm,      // 확인 콜백
  VoidCallback? onCancel,       // 취소 콜백
})
```

**사용 예시**:
```dart
// 확인 다이얼로그
SpaceDialog.show(
  context: context,
  title: '알림',
  content: '정말 삭제하시겠습니까?',
  confirmText: '삭제',
  cancelText: '취소',
  onConfirm: () {
    // 삭제 처리
  },
)
```

---

### 🏗️ Organisms (복합 요소)

#### 6. SpaceEmptyState
**위치**: `lib/core/widgets/organisms/empty_states/space_empty_state.dart`

**용도**: 빈 상태 화면 (아이콘 + 텍스트 + 액션 버튼)

**Props**:
```dart
SpaceEmptyState({
  required IconData icon,        // 표시할 아이콘
  required String title,         // 제목
  String? description,           // 설명 (선택적)
  String? actionText,            // 액션 버튼 텍스트 (선택적)
  VoidCallback? onAction,        // 액션 버튼 콜백
})
```

**사용 예시**:
```dart
// 액션 버튼이 있는 빈 상태
SpaceEmptyState(
  icon: Icons.inbox,
  title: '데이터가 없습니다',
  description: '새로운 항목을 추가해보세요',
  actionText: '추가하기',
  onAction: () {
    // 추가 화면으로 이동
  },
)

// 액션 버튼 없는 빈 상태
SpaceEmptyState(
  icon: Icons.search_off,
  title: '검색 결과가 없습니다',
  description: '다른 검색어를 시도해보세요',
)
```

---

### 🔔 Utilities (유틸리티)

#### 7. SpaceSnackBar
**위치**: `lib/core/utils/snackbar_utils.dart`

**용도**: 우주 테마 스낵바 (Success, Error, Info, Warning)

**메서드**:
```dart
// 성공 메시지
SpaceSnackBar.success(BuildContext context, String message, {Duration? duration})

// 에러 메시지
SpaceSnackBar.error(BuildContext context, String message, {Duration? duration})

// 정보 메시지
SpaceSnackBar.info(BuildContext context, String message, {Duration? duration})

// 경고 메시지
SpaceSnackBar.warning(BuildContext context, String message, {Duration? duration})
```

**사용 예시**:
```dart
// 성공 메시지
SpaceSnackBar.success(context, '저장되었습니다!');

// 에러 메시지
SpaceSnackBar.error(context, '저장에 실패했습니다.');

// 커스텀 duration
SpaceSnackBar.info(
  context,
  '새로운 알림이 있습니다',
  duration: Duration(seconds: 3),
);
```

**디자인 스펙**:
- Success: 초록색 (`AppColors.success`)
- Error: 빨간색 (`AppColors.error`)
- Info: 파란색 (`AppColors.primary`)
- Warning: 주황색 (`AppColors.warning`)
- Radius: `AppRadius.snackbar` (12px)
- Duration: 5초 (기본)
- Padding: 16.w x 16.h

---

## 사용 예시

### 예시 1: 로그인 화면

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/atoms/buttons/space_primary_button.dart';
import '../../../core/widgets/atoms/inputs/space_text_field.dart';
import '../../../core/utils/snackbar_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 이메일 입력
            const SpaceTextField(
              hintText: '이메일',
              prefixIcon: Icons.email,
            ),
            SizedBox(height: 16.h),

            // 비밀번호 입력
            const SpaceTextField(
              hintText: '비밀번호',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 24.h),

            // 로그인 버튼
            SpacePrimaryButton(
              text: '로그인',
              onPressed: () {
                SpaceSnackBar.success(context, '로그인 성공!');
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 예시 2: Todo 리스트 (빈 상태)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/organisms/empty_states/space_empty_state.dart';
import '../providers/todo_provider.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('할 일')),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return SpaceEmptyState(
              icon: Icons.check_circle_outline,
              title: '할 일이 없습니다',
              description: '새로운 할 일을 추가해보세요',
              actionText: '추가하기',
              onAction: () {
                // 추가 다이얼로그 표시
              },
            );
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              return TodoItem(key: Key(todos[index].id), todo: todos[index]);
            },
          );
        },
        loading: () => const Center(child: SpaceLoadingIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## 새 위젯 작성 가이드

### ✅ 공용 위젯으로 만들어야 하는 경우

다음 조건을 **2개 이상** 만족하면 `lib/core/widgets/`에 추가:

1. **재사용성**: 2개 이상의 Feature에서 사용될 가능성
2. **일관성**: 앱 전체에서 동일한 디자인이 필요
3. **독립성**: 특정 Feature의 비즈니스 로직과 무관
4. **범용성**: 다른 프로젝트에서도 사용 가능한 일반적인 UI

**예시**:
- ✅ 검색 바 (여러 화면에서 사용)
- ✅ 프로필 이미지 (사용자, 친구, 그룹 등에서 사용)
- ✅ 타이머 표시 (타이머, 통계, 히스토리에서 사용)

### ❌ Feature-specific 위젯으로 만들어야 하는 경우

다음 조건을 **1개 이상** 만족하면 `features/<feature>/presentation/widgets/`에 추가:

1. **비즈니스 로직 포함**: 해당 Feature의 도메인 로직 사용
2. **단일 사용**: 해당 Feature에서만 사용
3. **Feature 의존성**: Provider나 UseCase를 직접 참조
4. **특수 목적**: 매우 구체적인 용도

**예시**:
- ✅ TodoItem (Todo Feature에서만 사용, TodoEntity 의존)
- ✅ FuelGauge (Fuel Feature에서만 사용, 연료 계산 로직 포함)
- ✅ MissionCard (Mission Feature에서만 사용, Mission 상태 표시)

### 새 공용 위젯 작성 체크리스트

위젯을 `lib/core/widgets/`에 추가할 때:

1. **위치 결정**
   - [ ] Atom인가? Molecule인가? Organism인가?
   - [ ] 적절한 하위 폴더 선택 (buttons, cards, inputs 등)

2. **파일명 규칙**
   - [ ] `snake_case.dart` 형식
   - [ ] `space_` prefix 사용 (예: `space_custom_button.dart`)

3. **클래스명 규칙**
   - [ ] `PascalCase` 형식
   - [ ] `Space` prefix 사용 (예: `SpaceCustomButton`)

4. **코드 작성**
   - [ ] DartDoc 주석 작성 (용도, Props, 예시)
   - [ ] `const` 생성자 사용
   - [ ] `key` 파라미터 포함
   - [ ] `AppColors`, `AppTextStyles`, `AppRadius` 사용

5. **테스트**
   - [ ] `main.dart`의 `WidgetTestPage`에 예시 추가
   - [ ] 다양한 상태 확인 (기본, 로딩, 에러 등)

6. **문서화**
   - [ ] 이 문서(`05_WIDGETS_GUIDE.md`)에 추가
   - [ ] `00_QUICK_REFERENCE.md` 업데이트
   - [ ] `CLAUDE.md` 업데이트 (필요시)

### 템플릿

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';
import '../../../constants/text_styles.dart';

/// [위젯 용도 한 문장 설명]
///
/// [상세 설명]
///
/// **사용 예시**:
/// ```dart
/// SpaceCustomWidget(
///   property: value,
/// )
/// ```
class SpaceCustomWidget extends StatelessWidget {
  /// [생성자 설명]
  const SpaceCustomWidget({
    super.key,
    required this.property,
  });

  /// [속성 설명]
  final String property;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 위젯 구현
      // AppColors, AppTextStyles, AppRadius 사용
    );
  }
}
```

---

## 자주 하는 실수

### ❌ 실수 1: 공용 위젯 있는데 새로 만들기

```dart
// ❌ 잘못된 예: 이미 SpacePrimaryButton이 있는데 새로 만듦
class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('로그인'),
    );
  }
}

// ✅ 올바른 예: 기존 SpacePrimaryButton 사용
SpacePrimaryButton(
  text: '로그인',
  onPressed: handleLogin,
)
```

### ❌ 실수 2: 하드코딩된 색상/스타일

```dart
// ❌ 잘못된 예: 하드코딩
Container(
  decoration: BoxDecoration(
    color: Color(0xFF1A1F3A),
    borderRadius: BorderRadius.circular(12),
  ),
)

// ✅ 올바른 예: 디자인 시스템 사용
Container(
  decoration: BoxDecoration(
    color: AppColors.spaceSurface,
    borderRadius: AppRadius.card,
  ),
)
```

### ❌ 실수 3: const 생성자 안 쓰기

```dart
// ❌ 잘못된 예: const 없음 (불필요한 rebuild)
SpacePrimaryButton(
  text: '클릭',
  onPressed: handleClick,
)

// ✅ 올바른 예: const 사용 (최적화)
const SpacePrimaryButton(
  text: '클릭',
  onPressed: handleClick, // 하지만 함수는 const 불가
)

// ✅ 올바른 예: 완전히 static인 경우만 const
const SpaceTextField(
  hintText: '입력하세요',
  prefixIcon: Icons.person,
)
```

### ❌ 실수 4: Feature-specific 위젯을 core에 넣기

```dart
// ❌ 잘못된 위치: lib/core/widgets/atoms/todo_item.dart
// TodoEntity에 의존하므로 core에 있으면 안 됨

// ✅ 올바른 위치: lib/features/todo/presentation/widgets/todo_item.dart
class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final TodoEntity todo; // Feature의 Entity 의존

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### ❌ 실수 5: 위젯에 비즈니스 로직 넣기

```dart
// ❌ 잘못된 예: 위젯에서 API 호출
class UserProfileCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 위젯에서 직접 API 호출
    final user = ref.watch(userRepositoryProvider).getUser();

    return SpaceCard(child: Text(user.name));
  }
}

// ✅ 올바른 예: Provider를 통해 데이터 전달
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return SpaceCard(child: Text(user.name));
  }
}
```

---

## 빠른 참조

### 위젯 선택 플로우차트

```
새 UI 컴포넌트가 필요한가?
│
├─ YES → 공용 위젯 목록 확인 (위 섹션)
│         │
│         ├─ 있음 → 기존 위젯 사용 ✅
│         │
│         └─ 없음 → 2개 이상 Feature에서 사용?
│                   │
│                   ├─ YES → lib/core/widgets/에 추가
│                   │         (이 문서 업데이트)
│                   │
│                   └─ NO → features/<feature>/presentation/widgets/에 추가
│
└─ NO → 작업 완료
```

### 디자인 시스템 상수

| 항목 | 위치 | 사용 |
|------|------|------|
| 색상 | `lib/core/constants/app_colors.dart` | `AppColors.primary` |
| 텍스트 스타일 | `lib/core/constants/text_styles.dart` | `AppTextStyles.body1.bold()` |
| 간격 | `lib/core/constants/spacing_and_radius.dart` | `AppSpacing.s16` |
| Padding | `lib/core/constants/spacing_and_radius.dart` | `AppPadding.all16` |
| Radius | `lib/core/constants/spacing_and_radius.dart` | `AppRadius.button` (12px) |

---

## 다음 단계

1. **위젯 사용하기**: 위 목록에서 필요한 위젯을 찾아 사용
2. **예시 코드 확인**: `lib/main.dart`의 `WidgetTestPage` 참고
3. **새 위젯 요청**: 필요한 공용 위젯이 없다면 팀에 요청
4. **문서 기여**: 새 위젯 추가 시 이 문서 업데이트

---

**마지막 업데이트**: 2026-01-02
**버전**: v1.0
**작성자**: Claude Code

**관련 문서**:
- [00_QUICK_REFERENCE.md](./00_QUICK_REFERENCE.md) - 빠른 참조 가이드
- [03_CODE_CONVENTIONS.md](./03_CODE_CONVENTIONS.md) - 코드 컨벤션
- [CLAUDE.md](../CLAUDE.md) - 프로젝트 개요
