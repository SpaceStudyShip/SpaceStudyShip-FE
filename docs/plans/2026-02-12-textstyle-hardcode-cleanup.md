# TextStyle 하드코딩 제거 — AppTextStyles 상수 통일

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 모든 텍스트 스타일을 `AppTextStyles` 상수로 통일하고, `fontWeight` 등 고정 속성 오버라이드 제거

**Architecture:** AppTextStyles는 fontFamily(Pretendard 변형), fontSize, letterSpacing, height를 고정 값으로 제공. `.copyWith()`로 color만 변경 허용.

**Tech Stack:** Flutter, AppTextStyles (text_styles.dart)

---

## 현재 상태 분석

### 핵심 발견: fontWeight 오버라이드는 NO-OP

`pubspec.yaml`에서 Pretendard 폰트가 개별 fontFamily로 등록되어 있음:
```yaml
- family: Pretendard-SemiBold    # w600
- family: Pretendard-Medium      # w500
- family: Pretendard-Bold        # w700
```

AppTextStyles에서 `fontFamily: 'Pretendard-SemiBold'`로 설정된 스타일에 `.copyWith(fontWeight: FontWeight.w700)`를 적용해도, Flutter 폰트 매칭이 같은 family 내에서만 검색하므로 **시각적 변화 없음(NO-OP)**. 따라서 모든 fontWeight 오버라이드를 제거해도 렌더링 결과 동일.

### 위반 유형 요약

| 유형 | 건수 | 심각도 |
|------|------|--------|
| 하드코딩 `TextStyle()` (AppTextStyles 미사용) | 1 | Critical |
| 잘못된 base style + fontSize 오버라이드 | 1 | Major |
| `fontWeight:` no-op 오버라이드 | 19 | Minor (시각 변화 없음) |

---

## Task 1: timer_screen.dart — 잘못된 base style 교체

**커밋 메시지:** `refactor: 타이머 스크린 TextStyle을 AppTextStyles.timer_48로 교체`

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:73-78`

**변경 내용:**

```dart
// ❌ 현재: heading_20에서 fontSize, letterSpacing, fontWeight 전부 오버라이드
style: AppTextStyles.heading_20.copyWith(
  fontSize: 48.sp,
  color: Colors.white,
  letterSpacing: 4,
  fontWeight: FontWeight.w700,
),

// ✅ 수정: timer_48 상수 사용 (48.sp, SemiBold, letterSpacing: 3)
style: AppTextStyles.timer_48.copyWith(
  color: Colors.white,
),
```

> **Note:** timer_48의 letterSpacing은 3이고 현재 코드는 4. fontWeight 오버라이드가 NO-OP이었으므로 기존에도 SemiBold로 렌더링됨. letterSpacing 1px 차이는 시각적으로 미미하며, 디자인 시스템 일관성을 위해 timer_48 상수값 사용.

---

## Task 2: exploration_detail_screen.dart — 하드코딩 TextStyle

**커밋 메시지:** (Task 3에서 함께 커밋)

**Files:**
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart:147`

**변경 내용:**

```dart
// ❌ 현재: 하드코딩 TextStyle
child: Text(planet.icon, style: TextStyle(fontSize: 36.sp)),

// ✅ 수정: 이모지 아이콘 크기는 fontSize이지만 typography가 아님.
// 가장 가까운 크기는 semibold28(28sp) 또는 timer_48(48sp).
// 이모지에는 fontFamily/fontWeight가 적용되지 않으므로
// semibold28을 base로 사용하고 fontSize만 조정하는 것도 방법이나,
// 이모지 렌더링은 시스템 폰트 사용이므로 fontSize만 지정하는 현재 방식이 합리적.
// → 예외로 유지하되 주석으로 의도 명시
child: Text(
  planet.icon,
  style: TextStyle(fontSize: 36.sp), // 이모지 아이콘 크기 (typography 아님)
),
```

> **Decision:** 이모지는 Pretendard 폰트를 사용하지 않으므로 AppTextStyles 적용 불가. 주석 추가로 의도 명시.

---

## Task 3: fontWeight NO-OP 오버라이드 일괄 제거 (12파일 19건)

**커밋 메시지:** `refactor: fontWeight no-op 오버라이드 제거 (Pretendard 개별 fontFamily 등록으로 효과 없음)`

**변경 전략:** 모든 `.copyWith(fontWeight: ...)` 제거. fontWeight 제거 후 다른 파라미터(color 등)만 남는 경우 copyWith 유지. fontWeight만 있었던 경우는 copyWith 자체 불필요하면 제거.

### 파일별 변경 목록:

**`about_screen.dart:134-136`**
```dart
// ❌ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
```

**`ranking_item.dart:145-149`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: ..., fontWeight: FontWeight.w800),
// ✅ style: AppTextStyles.tag_12.copyWith(color: ...),
```

**`ranking_item.dart:200-202`**
```dart
// ❌ style: AppTextStyles.paragraph_14.copyWith(color: Colors.white, fontWeight: widget.isCurrentUser ? FontWeight.w600 : FontWeight.w400),
// ✅ style: AppTextStyles.paragraph_14.copyWith(color: Colors.white),
```

**`ranking_item.dart:223-225`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.tag_12.copyWith(color: Colors.white),
```

**`ranking_item.dart:251-255`**
```dart
// ❌ style: AppTextStyles.paragraph_14.copyWith(color: ..., fontWeight: FontWeight.w600),
// ✅ style: AppTextStyles.paragraph_14.copyWith(color: ...),
```

**`space_stat_item.dart:59-61`**
```dart
// ❌ style: AppTextStyles.paragraph_14.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
// ✅ style: AppTextStyles.paragraph_14.copyWith(color: Colors.white),
```

**`streak_badge.dart:89-91`**
```dart
// ❌ style: _textStyle.copyWith(color: _color, fontWeight: FontWeight.w600),
// ✅ style: _textStyle.copyWith(color: _color),
```

**`streak_badge.dart:97-99`**
```dart
// ❌ style: _textStyle.copyWith(color: _color, fontWeight: FontWeight.w600),
// ✅ style: _textStyle.copyWith(color: _color),
```

**`fuel_gauge.dart:105-107`**
```dart
// ❌ style: _textStyle.copyWith(color: _fuelColor, fontWeight: FontWeight.w600),
// ✅ style: _textStyle.copyWith(color: _fuelColor),
```

**`planet_node.dart:97-99`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: ..., fontWeight: FontWeight.w600),
// ✅ style: AppTextStyles.tag_12.copyWith(color: ...),
```

**`planet_node.dart:126-128`**
```dart
// ❌ style: AppTextStyles.tag_10.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
// ✅ style: AppTextStyles.tag_10.copyWith(color: AppColors.primary),
```

**`planet_node.dart:144-146`**
```dart
// ❌ style: AppTextStyles.tag_10.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
// ✅ style: AppTextStyles.tag_10.copyWith(color: AppColors.success),
```

**`exploration_progress_bar.dart:78-82`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: ..., fontWeight: FontWeight.w500),
// ✅ style: AppTextStyles.tag_12.copyWith(color: ...),
```

**`region_card.dart:184-186`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: fuelColor, fontWeight: _canUnlock ? FontWeight.w600 : FontWeight.w400),
// ✅ style: AppTextStyles.tag_12.copyWith(color: fuelColor),
```

**`region_card.dart:214-216`**
```dart
// ❌ style: AppTextStyles.tag_12.copyWith(color: ..., fontWeight: FontWeight.w600),
// ✅ style: AppTextStyles.tag_12.copyWith(color: ...),
```

**`spaceship_selector.dart:138-140`**
```dart
// ❌ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
```

**`home_screen.dart:266-268`**
```dart
// ❌ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
```

**`home_screen.dart:367-369`**
```dart
// ❌ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
```

**`home_stat_chip.dart:74-76`**
```dart
// ❌ style: AppTextStyles.label_16.copyWith(color: color, fontWeight: FontWeight.w700),
// ✅ style: AppTextStyles.label_16.copyWith(color: color),
```

---

## Task 4: 검증

**커밋 메시지:** (커밋 없음 — 검증만)

**Step 1:** `flutter analyze` — 정적 분석 통과 확인
**Step 2:** `grep -r "fontWeight:" lib/ --include="*.dart" | grep -v text_styles.dart | grep -v .g.dart | grep -v .freezed.dart` — fontWeight 잔존 없음 확인
**Step 3:** `grep -r "TextStyle(" lib/ --include="*.dart" | grep -v text_styles.dart | grep -v .g.dart | grep -v .freezed.dart` — 하드코딩 TextStyle 없음 확인 (이모지 1건 예외)

---

## 요약

| Task | 파일 수 | 변경 건수 | 영향 |
|------|---------|----------|------|
| 1. timer_screen 교체 | 1 | 1 | letterSpacing 4→3 (미미) |
| 2. 이모지 주석 추가 | 1 | 1 | 변경 없음 |
| 3. fontWeight 제거 | 12 | 19 | **시각 변화 없음** (NO-OP 제거) |
| **합계** | **12** | **21** | |
