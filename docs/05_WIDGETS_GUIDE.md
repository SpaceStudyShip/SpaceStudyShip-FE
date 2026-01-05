# 🎨 공용 위젯 가이드 - 30초 Quick Start

> **새 위젯 만들기 전 여기 먼저!** | 복사해서 바로 쓰세요 | 중복 위젯 방지

---

## 📌 가장 많이 쓰는 3가지

### 1. 버튼 만들기

👆 **복사해서 쓰세요**
```dart
SpacePrimaryButton(
  text: '저장',
  onPressed: () {
    // 여기에 코드
  },
)
```

**언제 쓰나요?**
- 로그인, 저장, 시작 같은 주요 액션

**더 알아보기** (접기)
<details>
<summary>로딩 상태 / 비활성 버튼</summary>

```dart
// 로딩 중
SpacePrimaryButton(
  text: '저장 중...',
  isLoading: true,  // 빙글빙글 돌아요
  onPressed: null,
)

// 비활성
SpacePrimaryButton(
  text: '비활성',
  onPressed: null,  // null이면 회색으로 변해요
)
```
</details>

---

### 2. 입력창 만들기

👆 **복사해서 쓰세요**
```dart
SpaceTextField(
  hintText: '이름 입력',
  onChanged: (value) {
    // 입력값이 바뀔 때마다 여기 실행
  },
)
```

**언제 쓰나요?**
- Todo 제목, 검색어, 이름 등 텍스트 입력

**더 알아보기** (접기)
<details>
<summary>비밀번호 / 에러 표시</summary>

```dart
// 비밀번호 입력 (***로 보여요)
SpaceTextField(
  hintText: '비밀번호',
  obscureText: true,
  prefixIcon: Icons.lock,
)

// 에러 표시 (빨간 테두리)
SpaceTextField(
  hintText: '이메일',
  errorText: '올바른 이메일을 입력하세요',
)
```
</details>

---

### 3. 알림 띄우기

👆 **복사해서 쓰세요**
```dart
// 성공
SpaceSnackBar.success(context, '저장되었습니다!');

// 에러
SpaceSnackBar.error(context, '저장 실패');
```

**언제 쓰나요?**
- 저장 완료, 에러 발생, 알림 메시지

**더 알아보기** (접기)
<details>
<summary>정보 / 경고 알림</summary>

```dart
// 정보 (파란색)
SpaceSnackBar.info(context, '업데이트가 있어요');

// 경고 (주황색)
SpaceSnackBar.warning(context, '입력값을 확인하세요');
```
</details>

---

## 📚 전체 위젯 목록 (7개)

### 🔥 필수 위젯 (매일 사용)
| 위젯 | 용도 | 위치 |
|-----|------|------|
| **SpacePrimaryButton** | 버튼 | `core/widgets/atoms/buttons/` |
| **SpaceTextField** | 입력창 | `core/widgets/atoms/inputs/` |
| **SpaceSnackBar** | 알림 | `core/utils/snackbar_utils.dart` |

### ⭐ 일반 위젯 (자주 사용)
| 위젯 | 용도 | 위치 |
|-----|------|------|
| **SpaceCard** | 카드 | `core/widgets/molecules/cards/` |
| **SpaceDialog** | 팝업 | `core/widgets/molecules/dialogs/` |
| **SpaceLoadingIndicator** | 로딩 | `core/widgets/atoms/indicators/` |

### 💎 특수 위젯 (가끔 사용)
| 위젯 | 용도 | 위치 |
|-----|------|------|
| **SpaceEmptyState** | 빈 화면 | `core/widgets/organisms/empty_states/` |

---

## 🔍 상세 가이드

### SpaceCard - 카드

**언제 쓰나요?**
- Todo 아이템, 프로필 카드, 정보 박스

**기본 사용**
```dart
SpaceCard(
  child: Text('카드 내용'),
)
```

**클릭 가능한 카드**
```dart
SpaceCard(
  onTap: () {
    // 클릭 시 실행
  },
  child: Text('눌러보세요'),
)
```

---

### SpaceDialog - 팝업

**언제 쓰나요?**
- 확인/취소 선택, 중요한 알림

**기본 사용**
```dart
SpaceDialog.show(
  context: context,
  title: '삭제 확인',
  message: '정말 삭제할까요?',
  confirmText: '삭제',
  onConfirm: () {
    // 확인 버튼 눌렀을 때
  },
)
```

---

### SpaceLoadingIndicator - 로딩

**언제 쓰나요?**
- 데이터 불러오는 중, API 호출 대기

**기본 사용**
```dart
// 빙글빙글만
SpaceLoadingIndicator()

// 메시지 포함
SpaceLoadingIndicator(message: '불러오는 중...')
```

---

### SpaceEmptyState - 빈 화면

**언제 쓰나요?**
- 할 일이 없을 때, 검색 결과 없을 때

**기본 사용**
```dart
SpaceEmptyState(
  icon: Icons.inbox,
  title: '할 일이 없어요',
  description: '새로 만들어볼까요?',
  actionText: '추가하기',
  onAction: () {
    // 버튼 눌렀을 때
  },
)
```

**버튼 없는 버전**
```dart
SpaceEmptyState(
  icon: Icons.search_off,
  title: '검색 결과 없음',
  description: '다른 검색어를 시도하세요',
)
```

---

## 🚀 새 위젯 추가 기준

### 3초 판단법

**1️⃣ 이미 있는 7개로 안 되나요?**
→ 안 됨: 다음 단계로

**2️⃣ 3군데 이상에서 쓸 건가요?**
→ YES: `core/widgets/`에 추가 (팀에 요청)
→ NO: 해당 `features/<feature>/presentation/widgets/`에만 추가

**3️⃣ 끝!**

---

## 💡 자주 하는 실수

### ❌ 실수 1: 이미 있는데 새로 만들기

```dart
// ❌ 잘못
class MyButton extends StatelessWidget {
  // SpacePrimaryButton이 이미 있어요!
}

// ✅ 올바름
SpacePrimaryButton(text: '저장', onPressed: _save)
```

---

### ❌ 실수 2: 색상 하드코딩

```dart
// ❌ 잘못
Container(
  color: Color(0xFF1A1F3A),  // 하드코딩
)

// ✅ 올바름
Container(
  color: AppColors.spaceSurface,  // 디자인 시스템 사용
)
```

---

### ❌ 실수 3: const 안 쓰기

```dart
// ❌ 잘못 (매번 새로 만들어요)
SpaceTextField(hintText: '입력')

// ✅ 올바름 (재사용해요)
const SpaceTextField(hintText: '입력')
```

---

## 📖 관련 문서

- [00_QUICK_REFERENCE.md](./00_QUICK_REFERENCE.md) - 빠른 참조
- [CLAUDE.md](../CLAUDE.md) - 프로젝트 개요
- [TOSS_UI_UX_DESIGN.md](./TOSS_UI_UX_DESIGN.md) - 이 가이드의 기반이 된 원칙

---

**마지막 업데이트**: 2026-01-05
**버전**: v2.0 (Toss UX 원칙 적용)
**변경 사항**: 730줄 → 340줄 (53% 감소), 사용자 중심 설명, Quick Start 추가
