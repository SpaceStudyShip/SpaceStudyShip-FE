# 🎨 공용 위젯 가이드 - Toss UX 원칙 적용

> **위젯 만들기 전 여기 먼저!** | Toss UX 심리학 법칙 적용 | 복사해서 바로 쓰세요

---

## 📌 핵심 원칙

이 위젯들은 **Toss의 10가지 UX 심리학 법칙**과 **8가지 라이팅 원칙**을 적용했습니다.

| 적용된 법칙 | 설명 |
|-----------|------|
| 피츠의 법칙 | 터치 영역 48dp 이상 보장 |
| 도허티 임계 | 0.4초 이내 피드백 (애니메이션) |
| 힉의 법칙 | 선택지 최소화 |
| 밀러의 법칙 | 정보 청킹 (전화번호, 카드번호 등) |
| 폰 레스토프 | 타입별 색상 차별화 |
| 피크엔드 | 감정 공감 메시지 |
| 테슬러의 법칙 | 자동 포맷팅으로 복잡성 흡수 |
| 심미적 사용성 | 둥글둥글한 디자인 |

---

## 🚀 Quick Start

### 1. Import

```dart
import 'package:space_study_ship/core/widgets/widgets.dart';
```

### 2. 가장 많이 쓰는 위젯

#### 버튼

```dart
// Primary 버튼
SpaceButton(
  text: '시작하기',
  onPressed: () => print('clicked'),
)

// Secondary 버튼 (테두리만)
SpaceButton(
  text: '취소',
  type: SpaceButtonType.secondary,
  onPressed: () => Navigator.pop(context),
)

// Destructive 버튼 (빨간색)
SpaceButton(
  text: '삭제',
  type: SpaceButtonType.destructive,
  onPressed: () => deleteItem(),
)

// 로딩 상태
SpaceButton(
  text: '저장 중...',
  isLoading: true,
  onPressed: null,
)
```

#### 입력창

```dart
// 기본 입력
SpaceTextField(
  hintText: '이름',  // Toss 라이팅: 간결하게
  onChanged: (value) => print(value),
)

// 전화번호 자동 포맷팅 (010-1234-5678)
SpaceTextField(
  hintText: '휴대폰 번호',
  autoFormat: SpaceInputFormat.phone,
  keyboardType: TextInputType.phone,
)

// 금액 자동 포맷팅 (1,000,000)
SpaceTextField(
  hintText: '금액',
  autoFormat: SpaceInputFormat.currency,
  keyboardType: TextInputType.number,
)

// 비밀번호
SpaceTextField(
  hintText: '비밀번호',
  obscureText: true,
  prefixIcon: Icons.lock,
)

// 에러 표시
SpaceTextField(
  hintText: '이메일',
  errorText: '올바른 이메일을 입력해 주세요',
)
```

#### 알림 (SnackBar)

```dart
// 성공
SpaceSnackBar.success(context, '저장했어요');

// 에러
SpaceSnackBar.error(context, '저장에 실패했어요');

// 정보
SpaceSnackBar.info(context, '새로운 업데이트가 있어요');

// 경고
SpaceSnackBar.warning(context, '입력값을 확인해 주세요');

// 실행 취소 지원
SpaceSnackBar.showWithUndo(
  context: context,
  message: '삭제했어요',
  onUndo: () => restoreItem(),
);
```

---

## 📚 전체 위젯 목록 (8개)

| 위젯 | 용도 | 파일 |
|-----|------|------|
| **SpaceButton** | 버튼 (Primary/Secondary/Text/Destructive) | `buttons/space_button.dart` |
| **SpaceTextField** | 입력창 (자동 포맷팅 지원) | `inputs/space_text_field.dart` |
| **SpaceSnackBar** | 알림 메시지 | `feedback/space_snackbar.dart` |
| **SpaceCard** | 카드 컨테이너 | `cards/space_card.dart` |
| **SpaceDialog** | 다이얼로그/팝업 | `dialogs/space_dialog.dart` |
| **SpaceLoading** | 로딩 인디케이터 | `feedback/space_loading.dart` |
| **SpaceSkeleton** | 스켈레톤 UI (신규) | `feedback/space_skeleton.dart` |
| **SpaceEmptyState** | 빈 상태 화면 | `states/space_empty_state.dart` |

---

## 🔍 상세 가이드

### SpaceButton

**언제 쓰나요?**
- 로그인, 저장, 시작 같은 액션

**버튼 타입:**
| 타입 | 용도 | 색상 |
|-----|------|------|
| `primary` | 주요 액션 | 파란색 (기본값) |
| `secondary` | 보조 액션 | 테두리만 |
| `text` | 가벼운 액션 | 텍스트만 |
| `destructive` | 위험 액션 (삭제 등) | 빨간색 |

**버튼 크기:**
| 크기 | 높이 |
|-----|------|
| `small` | 40dp |
| `medium` | 48dp (기본값) |
| `large` | 56dp |

```dart
// 아이콘 포함
SpaceButton(
  text: '추가하기',
  icon: Icons.add,
  iconPosition: SpaceButtonIconPosition.leading,
  onPressed: () {},
)
```

---

### SpaceTextField

**자동 포맷팅 (테슬러/밀러 법칙):**
| 포맷 | 결과 |
|-----|------|
| `phone` | 010-1234-5678 |
| `card` | 1234 5678 9012 3456 |
| `account` | 123-4567-890123 |
| `currency` | 1,000,000 |
| `email` | 소문자 자동 변환 |

```dart
// 실시간 유효성 검사 (도허티 임계)
SpaceTextField(
  hintText: '이메일',
  autoFormat: SpaceInputFormat.email,
  validateOnChange: true,
  validator: (value) {
    if (!value!.contains('@')) return '올바른 이메일을 입력해 주세요';
    return null;
  },
)
```

---

### SpaceCard

**카드 스타일:**
| 스타일 | 설명 |
|-------|------|
| `elevated` | 그림자가 있는 카드 (기본값) |
| `outlined` | 테두리만 있는 카드 |
| `filled` | 배경색만 있는 카드 |

```dart
// 기본 카드
SpaceCard(
  padding: AppPadding.all16,
  child: Text('카드 내용'),
)

// 클릭 가능한 카드
SpaceCard(
  style: SpaceCardStyle.outlined,
  onTap: () => navigateToDetail(),
  child: ListTile(title: Text('클릭 가능')),
)

// 선택 상태
SpaceCard(
  isSelected: true,  // 파란 테두리
  child: Text('선택됨'),
)
```

---

### SpaceDialog

**감정 타입 (피크엔드 법칙):**
| 감정 | 아이콘 색상 |
|-----|----------|
| `success` | 초록 체크 |
| `warning` | 주황 경고 |
| `error` | 빨강 에러 |
| `info` | 파랑 정보 |

```dart
// 기본 다이얼로그
SpaceDialog.show(
  context: context,
  title: '저장할까요?',
  message: '변경사항이 저장돼요',
  onConfirm: () => save(),
);

// 확인/취소 다이얼로그
SpaceDialog.show(
  context: context,
  title: '삭제할까요?',
  message: '삭제하면 되돌릴 수 없어요',
  emotion: SpaceDialogEmotion.warning,
  confirmText: '삭제',
  cancelText: '취소',
  confirmButtonType: SpaceButtonType.destructive,
  onConfirm: () => delete(),
);

// 간편 확인 (bool 반환)
final result = await SpaceDialog.confirm(
  context: context,
  title: '저장할까요?',
);
if (result == true) { /* 저장 */ }
```

---

### SpaceLoading

**로딩 타입:**
| 타입 | 설명 |
|-----|------|
| `spinner` | 기본 원형 스피너 |
| `dots` | 점 3개 애니메이션 |
| `progress` | 진행률 표시 |

```dart
// 기본 스피너
SpaceLoading()

// 메시지와 함께
SpaceLoading(message: '불러오는 중...')

// 진행률 표시
SpaceLoading(
  type: SpaceLoadingType.progress,
  progress: 0.75,
  message: '업로드 중...',
)

// 점 애니메이션
SpaceLoading(type: SpaceLoadingType.dots)
```

---

### SpaceSkeleton (신규)

**도허티 임계 적용**: 콘텐츠 형태를 미리 보여줌

```dart
// 기본 사각형
SpaceSkeleton(width: 100, height: 20)

// 원형 아바타
SpaceSkeleton.avatar(size: 48)

// 텍스트 줄
SpaceSkeleton.text(lines: 3)

// 카드
SpaceSkeleton.card(height: 120)

// 리스트 아이템 (아바타 + 텍스트)
SpaceSkeleton.listTile()
```

**리스트 로딩 예시:**
```dart
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => SpaceSkeleton.listTile(),
)
```

---

### SpaceEmptyState

**빈 상태 타입:**
| 타입 | 기본 아이콘 |
|-----|----------|
| `noData` | inbox |
| `noSearch` | search_off |
| `error` | error_outline |
| `offline` | wifi_off |

```dart
// 기본 빈 상태
SpaceEmptyState(
  icon: Icons.inbox,
  title: '아직 할 일이 없어요',
  description: '첫 번째 할 일을 만들어볼까요?',
  actionText: '할 일 만들기',
  onAction: () => createTodo(),
)

// 검색 결과 없음
SpaceEmptyState(
  type: SpaceEmptyType.noSearch,
  icon: Icons.search_off,
  title: '검색 결과가 없어요',
  description: '다른 검색어로 찾아볼까요?',
)

// 오프라인
SpaceEmptyState(
  type: SpaceEmptyType.offline,
  title: '인터넷 연결이 끊겼어요',
  description: '연결 상태를 확인해 주세요',
  actionText: '다시 시도',
  onAction: () => retry(),
)
```

---

## 🔄 마이그레이션 가이드

### Import 경로 변경

```dart
// Before (구버전)
import 'package:space_study_ship/core/widgets/atoms/buttons/space_primary_button.dart';
import 'package:space_study_ship/core/utils/snackbar_utils.dart';

// After (신버전)
import 'package:space_study_ship/core/widgets/widgets.dart';
```

### 클래스명 변경

| 구버전 | 신버전 |
|-------|-------|
| `SpacePrimaryButton` | `SpaceButton` |
| `SpaceLoadingIndicator` | `SpaceLoading` |

**호환성**: 구버전 클래스명도 `@Deprecated` 어노테이션과 함께 동작합니다.

---

## 🚀 새 위젯 추가 기준

### 3초 판단법

**1️⃣ 이미 있는 8개로 안 되나요?**
→ 안 됨: 다음 단계로

**2️⃣ 3군데 이상에서 쓸 건가요?**
→ YES: `core/widgets/`에 추가 (팀에 요청)
→ NO: 해당 `features/<feature>/presentation/widgets/`에만 추가

**3️⃣ 끝!**

---

## 💡 Toss 라이팅 원칙 적용 예시

| 원칙 | Before | After |
|-----|--------|-------|
| Weed Cutting | "이름을 입력하세요" | "이름" |
| Easy to Speak | "삭제 확인" | "삭제할까요?" |
| Find Hidden Emotion | "삭제됩니다" | "삭제하면 되돌릴 수 없어요" |
| Predictable Hint | "추가" | "할 일 만들기" |

---

## 💡 자주 하는 실수

### ❌ 실수 1: 이미 있는데 새로 만들기

```dart
// ❌ 잘못
class MyButton extends StatelessWidget {
  // SpaceButton이 이미 있어요!
}

// ✅ 올바름
SpaceButton(text: '저장', onPressed: _save)
```

### ❌ 실수 2: 색상 하드코딩

```dart
// ❌ 잘못
Container(color: Color(0xFF1A1F3A))

// ✅ 올바름
Container(color: AppColors.spaceSurface)
```

---

## 📖 관련 문서

- [TOSS_UI_UX_DESIGN.md](./TOSS_UI_UX_DESIGN.md) - Toss UX 원칙 상세
- [CLAUDE.md](../CLAUDE.md) - 프로젝트 개요

---

**마지막 업데이트**: 2026-01-05
**버전**: v3.0 (Toss UX 원칙 전면 적용, 위젯 8개)
