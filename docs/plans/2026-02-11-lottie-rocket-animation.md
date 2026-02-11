# Lottie 로켓 애니메이션 적용 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면의 기본 로켓(`id: 'default'`)을 `assets/lotties/default_rocket.json` Lottie 애니메이션으로 교체한다.

**Architecture:** `SpaceshipAvatar`에 `lottieAsset` 옵셔널 파라미터를 추가하여, 값이 있으면 Lottie를 렌더링하고 없으면 기존 GradientCircleIcon을 그대로 사용한다. 기존 glow 애니메이션은 Lottie 위에도 동일하게 유지한다.

**Tech Stack:** Flutter, lottie (lottie_flutter 패키지), 기존 SpaceshipAvatar 위젯

---

## Task 1: lottie 패키지 추가 및 에셋 등록

**Files:**
- Modify: `pubspec.yaml:28` (dependencies 섹션)
- Modify: `pubspec.yaml:62-64` (assets 섹션)

**Step 1: pubspec.yaml에 lottie 패키지 추가**

`dependencies:` 섹션의 `shimmer: ^3.0.0` 아래에 추가:

```yaml
  lottie: ^3.3.1 # Lottie 애니메이션 재생
```

**Step 2: pubspec.yaml에 lotties 에셋 디렉토리 등록**

`assets:` 섹션에 추가:

```yaml
  assets:
    - assets/fonts/
    - assets/lotties/
    - .env
```

**Step 3: flutter pub get 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter pub get`
Expected: `Got dependencies!` 성공

**Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: lottie 패키지 추가 및 lotties 에셋 디렉토리 등록"
```

---

## Task 2: SpaceshipAvatar에 Lottie 지원 추가

**Files:**
- Modify: `lib/core/widgets/space/spaceship_avatar.dart`

**Step 1: lottie import 추가**

파일 상단에 import 추가:

```dart
import 'package:lottie/lottie.dart';
```

**Step 2: lottieAsset 파라미터 추가**

`SpaceshipAvatar` 클래스에 옵셔널 파라미터 추가:

```dart
class SpaceshipAvatar extends StatefulWidget {
  const SpaceshipAvatar({
    super.key,
    required this.icon,
    this.size = 120,
    this.showGlow = true,
    this.lottieAsset,
  });

  /// 우주선 이모지/아이콘 키
  final String icon;

  /// 전체 크기 (기본 120)
  final double size;

  /// glow 애니메이션 표시 여부
  final bool showGlow;

  /// Lottie 에셋 경로 (null이면 기존 GradientCircleIcon 사용)
  final String? lottieAsset;

  @override
  State<SpaceshipAvatar> createState() => _SpaceshipAvatarState();
}
```

**Step 3: build 메서드에서 child를 조건부 렌더링**

`_SpaceshipAvatarState.build()` 메서드에서, 기존 TODO 주석을 제거하고 `AnimatedBuilder`의 `child:`를 조건부로 변경:

```dart
@override
Widget build(BuildContext context) {
  final baseColor = SpaceIcons.colorOf(widget.icon);

  return AnimatedBuilder(
    animation: _glowController,
    builder: (context, child) {
      final glowOpacity = 0.15 + _glowController.value * 0.15;
      final glowSpread = 4.0 + _glowController.value * 8.0;
      final glowBlur = 24.0 + _glowController.value * 16.0;

      return Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: widget.showGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: glowOpacity),
                    blurRadius: glowBlur,
                    spreadRadius: glowSpread,
                  ),
                ],
              )
            : null,
        child: child,
      );
    },
    child: widget.lottieAsset != null
        ? Lottie.asset(
            widget.lottieAsset!,
            width: widget.size.w,
            height: widget.size.w,
            fit: BoxFit.contain,
          )
        : GradientCircleIcon(
            icon: SpaceIcons.resolve(widget.icon),
            color: baseColor,
            size: widget.size,
            iconSize: widget.size * 0.42,
            gradientColors: SpaceIcons.gradientOf(widget.icon),
          ),
  );
}
```

**핵심 변경점:**
- `lottieAsset != null` → `Lottie.asset()` 렌더링
- `lottieAsset == null` → 기존 `GradientCircleIcon` 유지
- glow 애니메이션은 두 경우 모두 동일하게 적용
- 사용하지 않는 `gradient` 변수 제거 (`lottieAsset`이 있으면 gradient 불필요)

**Step 4: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter analyze`
Expected: `No issues found!`

**Step 5: Commit**

```bash
git add lib/core/widgets/space/spaceship_avatar.dart
git commit -m "feat: SpaceshipAvatar에 lottieAsset 파라미터 추가"
```

---

## Task 3: HomeScreen에서 기본 로켓에 Lottie 적용

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart:249`

**Step 1: SpaceshipData에 lottieAsset 필드 추가**

`lib/features/home/presentation/widgets/spaceship_selector.dart`의 `SpaceshipData` 클래스에 필드 추가:

```dart
class SpaceshipData {
  const SpaceshipData({
    required this.id,
    required this.icon,
    required this.name,
    this.isUnlocked = false,
    this.isAnimated = false,
    this.rarity = SpaceshipRarity.normal,
    this.lottieAsset,
  });

  final String id;
  final String icon;
  final String name;
  final bool isUnlocked;
  final bool isAnimated;
  final SpaceshipRarity rarity;
  final String? lottieAsset;
}
```

**Step 2: HomeScreen의 기본 로켓 데이터에 lottieAsset 지정**

`home_screen.dart`의 `_spaceships` 리스트에서 `id: 'default'` 항목에 추가:

```dart
const SpaceshipData(
  id: 'default',
  icon: '🚀',
  name: '화성 탐사선',
  isUnlocked: true,
  rarity: SpaceshipRarity.normal,
  lottieAsset: 'assets/lotties/default_rocket.json',
),
```

**Step 3: 선택된 lottieAsset 상태 추가 및 전달**

`_HomeScreenState`에 상태 변수 추가:

```dart
String? _selectedLottieAsset = 'assets/lotties/default_rocket.json';
```

`_showSpaceshipSelector()` 콜백에서 lottieAsset도 업데이트:

```dart
void _showSpaceshipSelector() {
  showSpaceshipSelector(
    context: context,
    spaceships: _spaceships,
    selectedId: _selectedSpaceshipId,
    onSelect: (id) {
      final selected = _spaceships.firstWhere((s) => s.id == id);
      setState(() {
        _selectedSpaceshipId = id;
        _selectedSpaceshipIcon = selected.icon;
        _selectedSpaceshipName = selected.name;
        _selectedLottieAsset = selected.lottieAsset;
      });
    },
  );
}
```

**Step 4: SpaceshipAvatar 호출부에 lottieAsset 전달**

`_buildSpaceshipArea()`의 249번 줄을 변경:

```dart
// Before:
SpaceshipAvatar(icon: _selectedSpaceshipIcon, size: 200),

// After:
SpaceshipAvatar(
  icon: _selectedSpaceshipIcon,
  size: 200,
  lottieAsset: _selectedLottieAsset,
),
```

**Step 5: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter analyze`
Expected: `No issues found!`

**Step 6: Commit**

```bash
git add lib/features/home/presentation/screens/home_screen.dart lib/features/home/presentation/widgets/spaceship_selector.dart
git commit -m "feat: 홈 화면 기본 로켓에 Lottie 애니메이션 적용"
```

---

## Task 4: 시각적 검증

**Step 1: 앱 실행하여 확인**

Run: `flutter run`

**검증 항목:**
- [ ] 홈 화면 진입 시 Lottie 로켓 애니메이션이 재생되는지 확인
- [ ] 로켓 주변 glow(빛) 효과가 정상 작동하는지 확인
- [ ] 로켓 탭 → 우주선 선택기 열림 확인
- [ ] 다른 우주선(UFO, 인공위성 등) 선택 시 기존 GradientCircleIcon으로 정상 표시 확인
- [ ] 다시 '화성 탐사선' 선택 시 Lottie 애니메이션 복귀 확인
- [ ] 하단 시트 드래그/탭 상호작용 정상 확인

---

## 영향 범위 요약

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `pubspec.yaml` | Modify | lottie 패키지 + assets/lotties/ 등록 |
| `spaceship_avatar.dart` | Modify | `lottieAsset` 파라미터 + 조건부 렌더링 |
| `spaceship_selector.dart` | Modify | SpaceshipData에 `lottieAsset` 필드 추가 |
| `home_screen.dart` | Modify | lottieAsset 상태 관리 + SpaceshipAvatar 전달 |

**변경 파일 수:** 4개
**예상 변경 라인 수:** ~30줄
**위험도:** 낮음 (기존 동작 완전 보존, 옵셔널 파라미터만 추가)
