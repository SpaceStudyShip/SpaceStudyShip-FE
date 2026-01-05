# 🎯 Core Widgets Toss UX 원칙 리디자인 전략 문서

## 1. 요약

현재 6개의 core/widgets를 **Toss UI/UX 10가지 심리학 법칙 + 8가지 라이팅 원칙**에 맞게 전면 재설계합니다. 기존 파일을 모두 삭제하고, 심리학적 근거가 내재된 새로운 위젯 시스템을 구축합니다.

---

## 2. 배경 및 목적

### 문제/필요성
현재 위젯들은 기능적으로는 동작하지만 **Toss UX 원칙이 체계적으로 적용되지 않음**:

| 현재 위젯 | 주요 문제점 |
|----------|-----------|
| `SpacePrimaryButton` | 피츠의 법칙 미적용 (터치 영역 최적화 부족), 도허티 임계 미적용 (피드백 애니메이션 부재) |
| `SpaceTextField` | 포스텔의 법칙 미적용 (입력 유연성 부족), 테슬러의 법칙 미적용 (복잡성 감소 기능 없음) |
| `SpaceCard` | 심미적 사용성 효과 미적용 (50ms 이내 긍정적 인상 유도 부족) |
| `SpaceDialog` | 힉의 법칙 미적용 (선택지 최적화 부족), 피크엔드 법칙 미적용 (감정 공감 부재) |
| `SpaceLoadingIndicator` | 도허티 임계 미적용 (0.4초 이내 피드백 시스템 부재) |
| `SpaceEmptyState` | 피크엔드 법칙 미적용 (실패/빈 상태에서 감정 완화 부족) |
| `SpaceSnackBar` | 폰 레스토프 효과 미적용 (알림 강조 시스템 부재) |

### 목표
1. **10가지 UX 심리학 법칙**을 각 위젯에 체계적으로 적용
2. **8가지 라이팅 원칙**을 모든 텍스트/힌트에 적용
3. **5가지 코어밸류**(Clear, Concise, Casual, Respect, Emotional) 반영
4. 기존 API 호환성 유지 (breaking change 최소화)

### 범위
- **포함**: 6개 위젯 + 1개 유틸리티 전면 재작성
- **제외**: `lib/core/constants/` (색상, 간격 등은 유지)

---

## 3. 요구사항

### 필수 (P0)
- [ ] 모든 위젯에 Toss UX 심리학 법칙 적용
- [ ] 기존 API 시그니처 호환성 유지 (80% 이상)
- [ ] 애니메이션/피드백 시스템 적용 (도허티 임계)
- [ ] 터치 영역 최적화 (피츠의 법칙)
- [ ] 코드 문서화 (각 위젯에 적용된 원칙 명시)

### 중요 (P1)
- [ ] 스켈레톤 UI 지원 (로딩 상태)
- [ ] 접근성 지원 강화 (Semantics)
- [ ] 테마 확장성 (다크/라이트 모드 준비)

### 선택 (P2)
- [ ] 햅틱 피드백 지원
- [ ] 커스텀 애니메이션 커브 옵션

---

## 4. 위젯별 Toss UX 원칙 적용 계획

### 4.1 SpacePrimaryButton (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **피츠의 법칙** | 최소 터치 영역 48x48dp 보장, 터치 영역 8dp 이상 간격 |
| **도허티 임계** | 0.4초 이내 시각적 피드백 (ripple + scale 애니메이션) |
| **심미적 사용성** | 둥글둥글한 디자인, 부드러운 그림자, 50ms 이내 긍정적 인상 |
| **폰 레스토프** | Primary/Secondary/Destructive 색상 구분으로 중요도 강조 |

**새 기능:**
```dart
// 버튼 타입 (폰 레스토프 효과)
enum SpaceButtonType { primary, secondary, text, destructive }

// 피드백 애니메이션 (도허티 임계)
class SpaceButton extends StatelessWidget {
  final SpaceButtonType type;
  final bool enableHaptic;  // 햅틱 피드백
  final bool enableScale;   // 눌림 애니메이션
  // ...
}
```

---

### 4.2 SpaceTextField (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **포스텔의 법칙** | 유연한 입력 수용 (전화번호 자동 포맷팅, 공백 자동 제거) |
| **테슬러의 법칙** | 자동 완성 제안, 입력 형식 자동 감지 (이메일/전화/금액) |
| **밀러의 법칙** | 긴 입력값 청킹 (계좌번호, 카드번호 자동 분리) |
| **도허티 임계** | 실시간 유효성 검사 피드백 (0.4초 이내) |

**라이팅 원칙 적용:**
```dart
// Before (현재)
hintText: '이름을 입력하세요'

// After (Toss 라이팅)
hintText: '이름'  // Weed Cutting - 불필요한 "을 입력하세요" 제거
helperText: '실명을 입력해 주세요'  // Easy to Speak - 자연스러운 말투
```

**새 기능:**
```dart
class SpaceTextField extends StatelessWidget {
  // 테슬러의 법칙: 자동 포맷팅
  final SpaceInputFormat? autoFormat;  // phone, card, account, currency

  // 포스텔의 법칙: 유연한 입력
  final bool autoTrimWhitespace;
  final bool autoCorrectFormat;

  // 도허티 임계: 실시간 피드백
  final Duration validationDebounce;  // default: 400ms
}

enum SpaceInputFormat { phone, card, account, currency, email }
```

---

### 4.3 SpaceCard (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **심미적 사용성** | 캐주얼하고 둥글둥글한 디자인, 부드러운 그림자 |
| **피츠의 법칙** | 클릭 가능한 카드는 전체 영역 터치 가능 |
| **도허티 임계** | 눌림 시 즉각적인 시각적 피드백 (scale/color 변화) |
| **제이콥의 법칙** | 익숙한 카드 패턴 유지 |

**새 기능:**
```dart
class SpaceCard extends StatelessWidget {
  // 심미적 사용성: 카드 스타일 프리셋
  final SpaceCardStyle style;  // elevated, outlined, filled

  // 도허티 임계: 터치 피드백
  final bool enablePressAnimation;

  // 선택 상태 지원
  final bool isSelected;
}

enum SpaceCardStyle { elevated, outlined, filled }
```

---

### 4.4 SpaceDialog (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **힉의 법칙** | 선택지 최대 2개 (확인/취소), 복잡한 선택은 별도 화면 |
| **피크엔드 법칙** | 결과에 따른 감정 공감 메시지, 친근한 비격식체 |
| **밀러의 법칙** | 내용을 청크로 구분, 핵심 메시지만 전달 |
| **심미적 사용성** | 부드러운 애니메이션, 둥글둥글한 디자인 |

**라이팅 원칙 적용:**
```dart
// Before (현재)
title: '삭제 확인'
message: '정말로 삭제하시겠습니까?'

// After (Toss 라이팅)
title: '삭제할까요?'  // Easy to Speak, Weed Cutting
message: '삭제하면 되돌릴 수 없어요'  // Find Hidden Emotion - 결과 명확히
confirmText: '삭제'
cancelText: '취소'  // Suggest Over Force - 선택권 명확히
```

**새 기능:**
```dart
class SpaceDialog extends StatelessWidget {
  // 피크엔드 법칙: 감정 타입
  final SpaceDialogEmotion? emotion;  // success, warning, error, info

  // 심미적 사용성: 아이콘/이모지 지원
  final Widget? headerIcon;

  // 진입/퇴장 애니메이션
  final bool enableAnimation;
}

enum SpaceDialogEmotion { success, warning, error, info }
```

---

### 4.5 SpaceLoadingIndicator (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **도허티 임계** | 스켈레톤 UI, 프로그레스 표시, 톡톡 튀는 애니메이션 |
| **피크엔드 법칙** | 로딩 완료 시 작은 성공 애니메이션 |
| **테슬러의 법칙** | 예상 시간 표시로 불확실성 감소 |

**새 기능:**
```dart
// 로딩 타입 확장
enum SpaceLoadingType {
  spinner,      // 기본 원형 스피너
  skeleton,     // 스켈레톤 UI
  shimmer,      // 반짝이는 효과
  dots,         // 점 3개 애니메이션
  progress,     // 진행률 표시
}

class SpaceLoadingIndicator extends StatelessWidget {
  final SpaceLoadingType type;
  final double? progress;           // 진행률 (0.0 ~ 1.0)
  final String? estimatedTime;      // 예상 시간 표시
  final bool showCompletionEffect;  // 완료 시 효과
}
```

---

### 4.6 SpaceEmptyState (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **피크엔드 법칙** | 귀여운 애니메이션 + 친근한 비격식체로 빈 상태 불편함 최소화 |
| **심미적 사용성** | 일러스트레이션/Lottie 애니메이션 지원 |
| **제이콥의 법칙** | 다음 단계 힌트 제공 (Predictable Hint) |

**라이팅 원칙 적용:**
```dart
// Before (현재)
title: '데이터가 없습니다'
description: '새로운 항목을 추가해보세요'

// After (Toss 라이팅)
title: '아직 할 일이 없어요'  // Casual, Easy to Speak
description: '첫 번째 할 일을 만들어볼까요?'  // Find Hidden Emotion
actionText: '할 일 만들기'  // Predictable Hint - 다음 화면 예측 가능
```

**새 기능:**
```dart
class SpaceEmptyState extends StatelessWidget {
  // 피크엔드 법칙: 상태 타입별 감정
  final SpaceEmptyType type;  // noData, noSearch, error, offline

  // 심미적 사용성: 애니메이션 지원
  final Widget? illustration;     // 일러스트레이션
  final String? lottieAsset;      // Lottie 애니메이션

  // Predictable Hint: 다음 단계 안내
  final String? nextStepHint;
}

enum SpaceEmptyType { noData, noSearch, error, offline }
```

---

### 4.7 SpaceSnackBar (새로 설계)

**적용할 UX 심리학 법칙:**

| 법칙 | 적용 방안 |
|-----|---------|
| **폰 레스토프 효과** | 중요도별 색상/아이콘 차별화, 진한 컬러로 눈에 띄게 |
| **도허티 임계** | 즉각적인 피드백 (0.4초 이내 표시) |
| **피츠의 법칙** | 액션 버튼 터치 영역 최적화 |
| **피크엔드 법칙** | 성공 시 작은 축하 이펙트 |

**새 기능:**
```dart
class SpaceSnackBar {
  // 액션 버튼 지원
  static void show({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    SpaceSnackBarType type,
    Duration duration,
    bool enableHaptic,  // 햅틱 피드백
  });

  // 프로그레스 SnackBar (도허티 임계)
  static void showProgress({
    required String message,
    required double progress,
  });

  // 실행 취소 지원
  static void showWithUndo({
    required String message,
    required VoidCallback onUndo,
    Duration undoWindow,
  });
}

enum SpaceSnackBarType { success, error, warning, info, neutral }
```

---

## 5. 디렉토리 구조

```
lib/core/widgets/
├── buttons/
│   ├── space_button.dart           # Primary/Secondary/Text/Destructive
│   └── space_icon_button.dart      # 아이콘 전용 버튼
├── inputs/
│   ├── space_text_field.dart       # 텍스트 입력
│   ├── space_search_field.dart     # 검색 전용 입력
│   └── formatters/                 # 자동 포맷터
│       ├── phone_formatter.dart
│       ├── card_formatter.dart
│       └── currency_formatter.dart
├── cards/
│   └── space_card.dart             # 카드 컴포넌트
├── dialogs/
│   ├── space_dialog.dart           # 다이얼로그
│   └── space_bottom_sheet.dart     # 바텀시트 (추가)
├── feedback/
│   ├── space_loading.dart          # 로딩 인디케이터
│   ├── space_skeleton.dart         # 스켈레톤 UI (추가)
│   ├── space_shimmer.dart          # 시머 효과 (추가)
│   └── space_snackbar.dart         # 스낵바
├── states/
│   └── space_empty_state.dart      # 빈 상태
└── widgets.dart                    # Barrel export
```

---

## 6. 마이그레이션 전략

### Phase 1: 새 위젯 작성 (기존 파일 삭제 후)
1. 기존 `lib/core/widgets/` 전체 삭제
2. 새로운 디렉토리 구조 생성
3. 새 위젯 하나씩 구현

### Phase 2: 호환성 레이어 (필요 시)
기존 API 시그니처와 다른 경우 deprecated 어노테이션으로 마이그레이션 안내:
```dart
@Deprecated('Use SpaceButton instead. See migration guide.')
class SpacePrimaryButton extends SpaceButton {
  SpacePrimaryButton({...}) : super(type: SpaceButtonType.primary, ...);
}
```

### Phase 3: 문서 업데이트
1. `docs/05_WIDGETS_GUIDE.md` 전면 개정
2. 각 위젯 docstring에 적용된 UX 원칙 명시

---

## 7. 주요 결정사항

| 결정 | 선택 | 이유 |
|------|------|------|
| Atomic Design 유지 여부 | **폐기** | 과도한 계층화, 실제 사용 시 혼란 유발 |
| 위젯 네이밍 | `Space*` 유지 | 기존 코드 호환성, 브랜드 일관성 |
| 애니메이션 라이브러리 | Flutter 내장 | 외부 의존성 최소화 |
| 스켈레톤 UI | `shimmer` 패키지 사용 | 성숙한 생태계, 커스터마이징 용이 |
| 입력 포맷터 | 자체 구현 | 프로젝트 특화 포맷 지원 필요 |

---

## 8. 고려사항 및 위험요소

### 기술적 위험
- ⚠️ **Breaking Change**: 일부 API 변경으로 기존 코드 수정 필요
  - 대응: Deprecated 어노테이션 + 마이그레이션 가이드 제공
- ⚠️ **애니메이션 성능**: 과도한 애니메이션으로 저사양 기기 성능 저하
  - 대응: `ReduceMotion` 옵션, 기기 성능 기반 자동 조절

### 비즈니스 위험
- ⚠️ **개발 시간**: 전면 재작성으로 예상보다 오래 걸릴 수 있음
  - 대응: 핵심 위젯(Button, TextField, SnackBar) 우선 구현

---

## 9. 성공 기준

- [ ] 모든 위젯에 최소 2개 이상의 UX 심리학 법칙 적용
- [ ] 버튼 터치 영역 48x48dp 이상 확보 (피츠의 법칙)
- [ ] 모든 인터랙션에 0.4초 이내 피드백 (도허티 임계)
- [ ] 모든 텍스트에 Toss 라이팅 원칙 적용
- [ ] 기존 코드 90% 이상 수정 없이 동작
- [ ] 위젯 가이드 문서 전면 개정 완료

---

## 10. 구현 순서 (우선순위)

1. **SpaceButton** (가장 많이 사용)
2. **SpaceTextField** (입력 경험 핵심)
3. **SpaceSnackBar** (피드백 핵심)
4. **SpaceCard** (레이아웃 기본)
5. **SpaceDialog** (중요 인터랙션)
6. **SpaceLoadingIndicator + SpaceSkeleton** (로딩 경험)
7. **SpaceEmptyState** (빈 상태 경험)

---

## ✅ 다음 단계

**다음 명령어**: `/analyze` - 이 전략을 바탕으로 구체적인 구현 계획 수립

**그 다음**: `/implement` - 분석된 계획대로 실제 구현 진행

---

## 📝 참고 문서

- [TOSS_UI_UX_DESIGN.md](../docs/TOSS_UI_UX_DESIGN.md) - Toss UX 원칙 상세
- [05_WIDGETS_GUIDE.md](../docs/05_WIDGETS_GUIDE.md) - 현재 위젯 가이드
- [Laws of UX](https://lawsofux.com/) - UX 심리학 법칙 원문

---

**작성일**: 2026-01-05
**작성자**: Claude Opus 4.5
**상태**: Plan 완료, 사용자 승인 대기
