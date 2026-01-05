# 📊 Core Widgets Toss UX 리디자인 - 구현 분석서

## 분석 요약

**감지된 프로젝트 타입**: Flutter Mobile App
**주요 기술 스택**: Flutter 3.9.2+, Riverpod 2.6.1, Freezed 2.5.7, flutter_screenutil 5.9.3
**코드 스타일**: StatelessWidget 위주, `.w`/`.h`/`.sp`/`.r` 사용, `AppTextStyles.body1.medium()` 패턴

---

## 🔍 현재 상태

### 삭제할 파일 목록 (7개)
```
lib/core/widgets/
├── atoms/
│   ├── buttons/space_primary_button.dart      ❌ 삭제
│   ├── inputs/space_text_field.dart           ❌ 삭제
│   └── indicators/space_loading_indicator.dart ❌ 삭제
├── molecules/
│   ├── cards/space_card.dart                  ❌ 삭제
│   └── dialogs/space_dialog.dart              ❌ 삭제
└── organisms/
    └── empty_states/space_empty_state.dart    ❌ 삭제

lib/core/utils/
└── snackbar_utils.dart                        ❌ 삭제
```

### 의존성 상태
```yaml
# pubspec.yaml에 이미 존재 - 추가 설치 불필요
shimmer: ^3.0.0  ✅ 이미 있음
```

---

## 🎯 구현 목표

1. Atomic Design 폐기 → 기능별 플랫 구조
2. 7개 위젯 전면 재작성 (Toss UX 원칙 적용)
3. 기존 API 호환성 80% 이상 유지
4. 새 barrel export 파일 생성

---

## 📝 상세 구현 계획

### Phase 0: 준비 단계

```
📁 작업 순서
1. 기존 파일 전체 삭제 (lib/core/widgets/*, lib/core/utils/snackbar_utils.dart)
2. 새 디렉토리 구조 생성
3. barrel export 파일 생성
```

**생성할 디렉토리 구조:**
```
lib/core/widgets/
├── buttons/
│   └── space_button.dart
├── inputs/
│   ├── space_text_field.dart
│   └── formatters/
│       └── input_formatters.dart
├── cards/
│   └── space_card.dart
├── dialogs/
│   └── space_dialog.dart
├── feedback/
│   ├── space_loading.dart
│   ├── space_skeleton.dart
│   └── space_snackbar.dart
├── states/
│   └── space_empty_state.dart
└── widgets.dart  (barrel export)
```

---

### Phase 1: SpaceButton (최우선)

**파일**: `lib/core/widgets/buttons/space_button.dart`

**적용할 Toss UX 원칙:**
- 피츠의 법칙: 최소 높이 48dp, 터치 영역 최적화
- 도허티 임계: 눌림 애니메이션 (scale 0.95)
- 폰 레스토프: 4가지 버튼 타입 색상 구분

**API 설계:**
```dart
enum SpaceButtonType { primary, secondary, text, destructive }
enum SpaceButtonSize { small, medium, large }

class SpaceButton extends StatefulWidget {
  const SpaceButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = SpaceButtonType.primary,
    this.size = SpaceButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconPosition = IconPosition.leading,
  });

  // 호환성 레이어 (deprecated)
  factory SpaceButton.primary({...}) = SpacePrimaryButton;
}

// 기존 코드 호환을 위한 deprecated alias
@Deprecated('Use SpaceButton instead')
typedef SpacePrimaryButton = SpaceButton;
```

**구현 상세:**
| 속성 | 값 | Toss 원칙 |
|-----|-----|----------|
| 최소 높이 | `48.h` (small: 40.h, large: 56.h) | 피츠의 법칙 |
| 눌림 효과 | `Transform.scale(0.95)` + 150ms | 도허티 임계 |
| 터치 피드백 | Ink Ripple + 색상 변화 | 심미적 사용성 |
| Primary 색상 | `AppColors.primary` | 폰 레스토프 |
| Destructive 색상 | `AppColors.error` | 폰 레스토프 |

---

### Phase 2: SpaceTextField

**파일**: `lib/core/widgets/inputs/space_text_field.dart`

**적용할 Toss UX 원칙:**
- 포스텔의 법칙: 입력 유연성 (autoTrim, 자동 포맷팅)
- 테슬러의 법칙: 복잡성 흡수 (자동 완성 힌트)
- 밀러의 법칙: 청킹 (계좌번호, 전화번호 자동 분리)
- 도허티 임계: 실시간 유효성 검사

**API 설계:**
```dart
enum SpaceInputFormat { none, phone, card, account, currency, email }

class SpaceTextField extends StatefulWidget {
  const SpaceTextField({
    super.key,
    this.controller,
    this.hintText,  // Toss 라이팅: "이름" (X: "이름을 입력하세요")
    this.labelText,
    this.helperText,  // 추가: 힌트 아래 도움말
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    // 새 기능 (Toss 원칙)
    this.autoFormat = SpaceInputFormat.none,  // 테슬러 법칙
    this.autoTrimWhitespace = true,           // 포스텔 법칙
    this.showCharacterCount = false,          // 밀러 법칙
    this.validateOnChange = false,            // 도허티 임계
    this.validationDebounce = const Duration(milliseconds: 400),
  });
}
```

**자동 포맷터 (테슬러/밀러 법칙):**
```dart
// lib/core/widgets/inputs/formatters/input_formatters.dart

/// 전화번호 자동 포맷팅: 01012345678 → 010-1234-5678
class PhoneInputFormatter extends TextInputFormatter { ... }

/// 카드번호 자동 포맷팅: 1234567890123456 → 1234 5678 9012 3456
class CardInputFormatter extends TextInputFormatter { ... }

/// 계좌번호 자동 포맷팅: 은행별 패턴 감지
class AccountInputFormatter extends TextInputFormatter { ... }

/// 통화 자동 포맷팅: 1000000 → 1,000,000
class CurrencyInputFormatter extends TextInputFormatter { ... }
```

---

### Phase 3: SpaceSnackBar

**파일**: `lib/core/widgets/feedback/space_snackbar.dart`

**적용할 Toss UX 원칙:**
- 폰 레스토프: 타입별 색상/아이콘 차별화
- 도허티 임계: 즉각적 표시 (0ms 딜레이)
- 피크엔드: 성공 시 작은 축하 이펙트

**API 설계:**
```dart
enum SpaceSnackBarType { success, error, warning, info, neutral }

class SpaceSnackBar {
  SpaceSnackBar._();

  // 기존 API 호환
  static void success(BuildContext context, String message, {Duration? duration});
  static void error(BuildContext context, String message, {Duration? duration});
  static void info(BuildContext context, String message, {Duration? duration});
  static void warning(BuildContext context, String message, {Duration? duration});

  // 새 기능
  static void show({
    required BuildContext context,
    required String message,
    SpaceSnackBarType type = SpaceSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  });

  // 실행 취소 지원 (테슬러 법칙)
  static void showWithUndo({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration undoWindow = const Duration(seconds: 5),
  });

  // 기존 SnackBar 즉시 닫기
  static void hide(BuildContext context);
}
```

---

### Phase 4: SpaceCard

**파일**: `lib/core/widgets/cards/space_card.dart`

**적용할 Toss UX 원칙:**
- 심미적 사용성: 둥글둥글한 디자인, 부드러운 그림자
- 피츠의 법칙: 클릭 가능 시 전체 영역 터치
- 도허티 임계: 눌림 피드백 애니메이션

**API 설계:**
```dart
enum SpaceCardStyle { elevated, outlined, filled }

class SpaceCard extends StatefulWidget {
  const SpaceCard({
    super.key,
    required this.child,
    this.style = SpaceCardStyle.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.enablePressAnimation = true,  // 도허티 임계
    this.width,
    this.height,
  });
}
```

**스타일별 외관:**
| 스타일 | 배경색 | 테두리 | 그림자 |
|-------|-------|-------|-------|
| elevated | `spaceSurface` | 없음 | `elevation: 2` |
| outlined | 투명 | `spaceDivider` | 없음 |
| filled | `spaceElevated` | 없음 | 없음 |

---

### Phase 5: SpaceDialog

**파일**: `lib/core/widgets/dialogs/space_dialog.dart`

**적용할 Toss UX 원칙:**
- 힉의 법칙: 선택지 최대 2개 (확인/취소)
- 피크엔드: 감정 공감 메시지 + 애니메이션
- 심미적 사용성: 부드러운 진입/퇴장 애니메이션

**API 설계:**
```dart
enum SpaceDialogEmotion { none, success, warning, error, info }

class SpaceDialog extends StatelessWidget {
  const SpaceDialog({
    super.key,
    this.title,
    this.message,
    this.child,
    this.emotion = SpaceDialogEmotion.none,  // 피크엔드
    this.headerIcon,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonType = SpaceButtonType.primary,
    this.barrierDismissible = true,
  });

  // 기존 API 호환
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? child,
    SpaceDialogEmotion emotion = SpaceDialogEmotion.none,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  });

  // 간편 메서드
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
  });
}
```

**Toss 라이팅 적용 예시:**
```dart
// Before
SpaceDialog.show(
  title: '삭제 확인',
  message: '정말로 삭제하시겠습니까?',
)

// After (Toss 라이팅)
SpaceDialog.show(
  title: '삭제할까요?',
  message: '삭제하면 되돌릴 수 없어요',
  emotion: SpaceDialogEmotion.warning,
)
```

---

### Phase 6: SpaceLoading + SpaceSkeleton

**파일 1**: `lib/core/widgets/feedback/space_loading.dart`

**적용할 Toss UX 원칙:**
- 도허티 임계: 다양한 로딩 타입, 예상 시간 표시
- 피크엔드: 완료 시 작은 성공 애니메이션

**API 설계:**
```dart
enum SpaceLoadingType { spinner, dots, progress }

class SpaceLoading extends StatelessWidget {
  const SpaceLoading({
    super.key,
    this.type = SpaceLoadingType.spinner,
    this.message,
    this.size = 40,
    this.color,
    this.progress,  // 0.0 ~ 1.0 (type이 progress일 때)
    this.estimatedSeconds,  // 예상 시간 표시
  });

  // 호환성 레이어
  factory SpaceLoading.indicator({...}) => SpaceLoading(...);
}

// 기존 코드 호환
@Deprecated('Use SpaceLoading instead')
typedef SpaceLoadingIndicator = SpaceLoading;
```

**파일 2**: `lib/core/widgets/feedback/space_skeleton.dart`

**적용할 Toss UX 원칙:**
- 도허티 임계: 콘텐츠 형태 미리 보여주기

**API 설계:**
```dart
class SpaceSkeleton extends StatelessWidget {
  const SpaceSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  // 프리셋 팩토리
  factory SpaceSkeleton.text({double? width, int lines = 1});
  factory SpaceSkeleton.avatar({double size = 48});
  factory SpaceSkeleton.card({double? width, double? height});
  factory SpaceSkeleton.listTile();
}
```

---

### Phase 7: SpaceEmptyState

**파일**: `lib/core/widgets/states/space_empty_state.dart`

**적용할 Toss UX 원칙:**
- 피크엔드: 친근한 비격식체 + 귀여운 애니메이션
- 심미적 사용성: 일러스트/Lottie 지원
- Predictable Hint: 다음 단계 안내

**API 설계:**
```dart
enum SpaceEmptyType { noData, noSearch, error, offline }

class SpaceEmptyState extends StatelessWidget {
  const SpaceEmptyState({
    super.key,
    this.type = SpaceEmptyType.noData,
    this.icon,
    this.iconWidget,
    this.lottieAsset,  // Lottie 애니메이션
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.secondaryActionText,  // 보조 액션
    this.onSecondaryAction,
  }) : assert(icon != null || iconWidget != null || lottieAsset != null);
}
```

**Toss 라이팅 적용 예시:**
```dart
// Before
SpaceEmptyState(
  title: '데이터가 없습니다',
  description: '새로운 항목을 추가해보세요',
)

// After (Toss 라이팅)
SpaceEmptyState(
  title: '아직 할 일이 없어요',
  description: '첫 번째 할 일을 만들어볼까요?',
  actionText: '할 일 만들기',  // Predictable Hint
)
```

---

### Phase 8: Barrel Export

**파일**: `lib/core/widgets/widgets.dart`

```dart
// Buttons
export 'buttons/space_button.dart';

// Inputs
export 'inputs/space_text_field.dart';
export 'inputs/formatters/input_formatters.dart';

// Cards
export 'cards/space_card.dart';

// Dialogs
export 'dialogs/space_dialog.dart';

// Feedback
export 'feedback/space_loading.dart';
export 'feedback/space_skeleton.dart';
export 'feedback/space_snackbar.dart';

// States
export 'states/space_empty_state.dart';
```

---

## 📁 파일 변경 요약

### 삭제할 파일 (7개)
| 파일 | 이유 |
|-----|------|
| `atoms/buttons/space_primary_button.dart` | SpaceButton으로 통합 |
| `atoms/inputs/space_text_field.dart` | 새 버전으로 교체 |
| `atoms/indicators/space_loading_indicator.dart` | SpaceLoading으로 통합 |
| `molecules/cards/space_card.dart` | 새 버전으로 교체 |
| `molecules/dialogs/space_dialog.dart` | 새 버전으로 교체 |
| `organisms/empty_states/space_empty_state.dart` | 새 버전으로 교체 |
| `utils/snackbar_utils.dart` | SpaceSnackBar로 이동 |

### 삭제할 디렉토리 (3개)
| 디렉토리 | 이유 |
|---------|------|
| `atoms/` | Atomic Design 폐기 |
| `molecules/` | Atomic Design 폐기 |
| `organisms/` | Atomic Design 폐기 |

### 생성할 파일 (9개)
| 파일 | 역할 |
|-----|------|
| `buttons/space_button.dart` | 통합 버튼 |
| `inputs/space_text_field.dart` | 텍스트 입력 |
| `inputs/formatters/input_formatters.dart` | 입력 포맷터 |
| `cards/space_card.dart` | 카드 |
| `dialogs/space_dialog.dart` | 다이얼로그 |
| `feedback/space_loading.dart` | 로딩 인디케이터 |
| `feedback/space_skeleton.dart` | 스켈레톤 UI (신규) |
| `feedback/space_snackbar.dart` | 스낵바 |
| `states/space_empty_state.dart` | 빈 상태 |
| `widgets.dart` | Barrel export |

---

## ⚠️ 주의사항

### Breaking Changes
1. **import 경로 변경**: `atoms/`, `molecules/`, `organisms/` → 기능별 폴더
   ```dart
   // Before
   import 'package:space_study_ship/core/widgets/atoms/buttons/space_primary_button.dart';

   // After
   import 'package:space_study_ship/core/widgets/widgets.dart';
   // 또는
   import 'package:space_study_ship/core/widgets/buttons/space_button.dart';
   ```

2. **클래스명 변경** (deprecated alias 제공):
   - `SpacePrimaryButton` → `SpaceButton`
   - `SpaceLoadingIndicator` → `SpaceLoading`

3. **새 파라미터**: 기존 파라미터는 모두 유지, 새 기능만 추가

### 호환성 보장
- Deprecated alias로 기존 코드 동작 보장
- 단계적 마이그레이션 가능

### 성능 고려사항
- 애니메이션은 `AnimatedContainer` 또는 `TweenAnimationBuilder` 사용
- 무거운 위젯 리빌드 방지를 위한 `const` 활용

---

## ✅ 구현 순서 (TodoWrite용)

```
1. [Phase 0] 기존 파일 삭제 및 디렉토리 구조 생성
2. [Phase 1] SpaceButton 구현
3. [Phase 2] SpaceTextField 구현 (+ formatters)
4. [Phase 3] SpaceSnackBar 구현
5. [Phase 4] SpaceCard 구현
6. [Phase 5] SpaceDialog 구현
7. [Phase 6] SpaceLoading + SpaceSkeleton 구현
8. [Phase 7] SpaceEmptyState 구현
9. [Phase 8] Barrel export 생성
10. [Phase 9] 문서 업데이트 (05_WIDGETS_GUIDE.md)
```

---

## ✅ 다음 단계

**다음 명령어**: `/implement` - 이 계획을 바탕으로 실제 구현 진행

**워크플로우**: `/plan` ✅ → `/analyze` ✅ (현재) → `/implement` → `/review` → `/test`

---

**작성일**: 2026-01-05
**상태**: 분석 완료, 구현 준비 완료
