# 이모지 제거 마이그레이션 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `lib/` 하위 뱃지·우주선·space_icons 영역에서 이모지를 String ID 방식으로 교체한다. 뱃지 시스템처럼 시스템 차원의 의미를 갖는 이모지만 제거하며, debugPrint·test widget·주석의 이모지는 그대로 둔다.

**Architecture:** Entity 의 `icon: String` 필드는 유지하고 값을 이모지 → 시맨틱 ID (`rocket`, `lock` 등) 로 교체. `space_icons.dart` 레지스트리를 ID 키 방식으로 재설계하되, Phase 4 까지 레거시 이모지 키 호환 테이블을 유지해 무중단 교체.

**Tech Stack:** Flutter 3.9 · Dart · ScreenUtil · Freezed (entity 재생성 불필요)

**Spec:** `docs/superpowers/specs/2026-04-13-emoji-removal-design.md`

**Branch:** `20260412_#68_이모지_전면_제거_마이그레이션`

---

## File Structure

### Files to Create
- `test/core/constants/space_icons_test.dart` — SpaceIcons 단위 테스트
- `test/features/badge/data/seed/badge_seed_data_test.dart` — 시드 데이터 검증
- `test/features/home/presentation/models/spaceship_data_test.dart` — 우주선 데이터 검증
- `test/features/badge/presentation/widgets/badge_card_test.dart` — BadgeCard 위젯 테스트

### Files to Modify
- `lib/core/constants/space_icons.dart` — String ID 레지스트리 재설계 + `Color(0xFF)` 정리
- `lib/features/home/presentation/models/spaceship_data.dart` — 이모지 → ID 교체
- `lib/features/badge/data/seed/badge_seed_data.dart` — 이모지 → ID 교체
- `lib/features/badge/presentation/widgets/badge_card.dart` — `Text('🔒')` → `Icon(...)`
- `lib/features/badge/presentation/widgets/badge_detail_dialog.dart` — 동일 패턴

---

## Naming Table (최종)

아래 표는 `badge_seed_data.dart` 코드포인트 실제 조사 결과 + 스펙 테이블 병합이다.

| 이모지 | 코드포인트 | String ID | Material Icon |
|--------|-----------|-----------|---------------|
| 🚀 | `\u{1F680}` | `rocket` | `Icons.rocket_launch_rounded` |
| 🛸 | `\u{1F6F8}` | `ufo` | `Icons.flight_rounded` |
| 🛰️ | `\u{1F6F0}\u{FE0F}` | `satellite` | `Icons.satellite_alt_rounded` |
| 🚁 | `\u{1F681}` | `helicopter` | `Icons.flight_rounded` |
| ⭐ | `\u{2B50}` | `star` | `Icons.star_rounded` |
| 🌟 | `\u{1F31F}` | `sparkleStar` | `Icons.auto_awesome_rounded` |
| ☀️ | `\u{2600}\u{FE0F}` | `sun` | `Icons.wb_sunny_rounded` |
| 🌙 | `\u{1F319}` | `moon` | `Icons.nightlight_round` |
| 🌌 | `\u{1F30C}` | `galaxy` | `Icons.blur_on_rounded` |
| 🌍 | `\u{1F30D}` | `earth` | `Icons.public_rounded` |
| 🪐 | `\u{1FA90}` | `planet` | `Icons.circle_rounded` |
| ⛽ | `\u{26FD}` | `fuel` | `Icons.local_gas_station_rounded` |
| 🔥 | `\u{1F525}` | `fire` | `Icons.local_fire_department_rounded` |
| 🔒 | `\u{1F512}` | `lock` | `Icons.lock_rounded` |
| ✅ | `\u{2705}` | `check` | `Icons.check_circle_rounded` |
| ✨ | `\u{2728}` | `sparkle` | `Icons.auto_awesome` |
| 🏆 | `\u{1F3C6}` | `trophy` | `Icons.emoji_events_rounded` |
| 👨‍🚀 | `\u{1F468}\u{200D}\u{1F680}` | `astronaut` | `Icons.person_rounded` |
| 🧑‍🚀 | `\u{1F9D1}\u{200D}\u{1F680}` | `astronaut` | `Icons.person_rounded` |
| 👥 | `\u{1F465}` | `group` | `Icons.group_rounded` |
| 📝 | `\u{1F4DD}` | `note` | `Icons.edit_note_rounded` |
| 🏠 | `\u{1F3E0}` | `home` | `Icons.home_rounded` |
| 🛠️ | `\u{1F6E0}\u{FE0F}` | `tool` | `Icons.build_rounded` |
| 👣 | `\u{1F463}` | `footstep` | `Icons.directions_walk_rounded` |
| 📖 | `\u{1F4D6}` | `book` | `Icons.menu_book_rounded` |
| 🔭 | `\u{1F52D}` | `telescope` | `Icons.visibility_rounded` |
| ⛵ | `\u{26F5}` | `sailboat` | `Icons.sailing_rounded` |
| 💫 | `\u{1F4AB}` | `dizzy` | `Icons.blur_circular_rounded` |
| 🎯 | `\u{1F3AF}` | `target` | `Icons.track_changes_rounded` |
| ✈️ | `\u{2708}\u{FE0F}` | `airplane` | `Icons.airplanemode_active_rounded` |
| 🥇 | `\u{1F947}` | `goldMedal` | `Icons.military_tech_rounded` |
| 🏅 | `\u{1F3C5}` | `medal` | `Icons.workspace_premium_rounded` |
| 🗺️ | `\u{1F5FA}\u{FE0F}` | `map` | `Icons.map_rounded` |
| 🛢️ | `\u{1F6E2}\u{FE0F}` | `oilDrum` | `Icons.propane_tank_rounded` |
| ⚡ | `\u{26A1}` | `bolt` | `Icons.bolt_rounded` |
| 🦉 | `\u{1F989}` | `owl` | `Icons.dark_mode_rounded` |
| 🐦 | `\u{1F426}` | `bird` | `Icons.wb_twilight_rounded` |

**주의:** 위 테이블 36개가 레지스트리에 들어갈 최종 ID 목록이다.

---

## Task 0: 새 브랜치 상태 확인

**Files:** (확인만)

- [ ] **Step 1: 현재 브랜치 및 작업 디렉토리 확인**

Run:
```bash
git status
git branch --show-current
```

Expected:
```
20260412_#68_이모지_전면_제거_마이그레이션
```

상태는 clean 이거나 `docs/issues/` 가 untracked 인 상태여야 함.

- [ ] **Step 2: 스펙 파일 존재 확인**

Run:
```bash
ls docs/superpowers/specs/2026-04-13-emoji-removal-design.md
```

Expected: 파일 존재 (Phase 브레인스토밍 단계에서 이미 커밋됨)

---

## Phase 1: `SpaceIcons` 레지스트리 재설계 (하위 호환)

### Task 1.1: SpaceIcons 단위 테스트 작성 (RED)

**Files:**
- Create: `test/core/constants/space_icons_test.dart`

- [ ] **Step 1: 테스트 파일 생성**

Create `test/core/constants/space_icons_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';

void main() {
  group('SpaceIcons.resolve', () {
    test('String ID 로 IconData 반환', () {
      expect(SpaceIcons.resolve(SpaceIcons.rocket), Icons.rocket_launch_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.lock), Icons.lock_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.trophy), Icons.emoji_events_rounded);
      expect(SpaceIcons.resolve(SpaceIcons.fuel), Icons.local_gas_station_rounded);
    });

    test('레거시 이모지 키도 IconData 로 변환 (하위 호환)', () {
      expect(SpaceIcons.resolve('\u{1F680}'), Icons.rocket_launch_rounded);
      expect(SpaceIcons.resolve('\u{1F512}'), Icons.lock_rounded);
      expect(SpaceIcons.resolve('\u{1F463}'), Icons.directions_walk_rounded);
      expect(SpaceIcons.resolve('\u{2600}\u{FE0F}'), Icons.wb_sunny_rounded);
    });

    test('알 수 없는 키는 기본 placeholder 반환', () {
      expect(SpaceIcons.resolve('not_a_real_id'), Icons.help_outline_rounded);
      expect(SpaceIcons.resolve(''), Icons.help_outline_rounded);
    });
  });

  group('SpaceIcons.colorOf', () {
    test('행성 ID 로 고유 색상 반환', () {
      expect(SpaceIcons.colorOf(SpaceIcons.rocket), isA<Color>());
      expect(SpaceIcons.colorOf(SpaceIcons.star), isA<Color>());
    });

    test('레거시 이모지로도 색상 반환 (하위 호환)', () {
      expect(SpaceIcons.colorOf('\u{1F680}'), isA<Color>());
    });
  });

  group('SpaceIcons.gradientOf', () {
    test('행성 ID 로 2색 그라데이션 반환', () {
      final gradient = SpaceIcons.gradientOf(SpaceIcons.rocket);
      expect(gradient, hasLength(2));
      expect(gradient.every((c) => c is Color), isTrue);
    });

    test('레거시 이모지로도 그라데이션 반환', () {
      final gradient = SpaceIcons.gradientOf('\u{1F680}');
      expect(gradient, hasLength(2));
    });
  });

  group('SpaceIcons 상수', () {
    test('모든 public String 상수가 _idToIcon 맵에 존재', () {
      const ids = [
        SpaceIcons.rocket,
        SpaceIcons.ufo,
        SpaceIcons.satellite,
        SpaceIcons.helicopter,
        SpaceIcons.star,
        SpaceIcons.sparkleStar,
        SpaceIcons.sun,
        SpaceIcons.moon,
        SpaceIcons.galaxy,
        SpaceIcons.earth,
        SpaceIcons.planet,
        SpaceIcons.fuel,
        SpaceIcons.fire,
        SpaceIcons.lock,
        SpaceIcons.check,
        SpaceIcons.sparkle,
        SpaceIcons.trophy,
        SpaceIcons.astronaut,
        SpaceIcons.group,
        SpaceIcons.note,
        SpaceIcons.home,
        SpaceIcons.tool,
        SpaceIcons.footstep,
        SpaceIcons.book,
        SpaceIcons.telescope,
        SpaceIcons.sailboat,
        SpaceIcons.dizzy,
        SpaceIcons.target,
        SpaceIcons.airplane,
        SpaceIcons.goldMedal,
        SpaceIcons.medal,
        SpaceIcons.map,
        SpaceIcons.oilDrum,
        SpaceIcons.bolt,
        SpaceIcons.owl,
        SpaceIcons.bird,
      ];
      for (final id in ids) {
        expect(
          SpaceIcons.resolve(id),
          isNot(Icons.help_outline_rounded),
          reason: 'ID "$id" 가 _idToIcon 에서 매핑되지 않음',
        );
      }
    });
  });
}
```

- [ ] **Step 2: 테스트 실행해서 실패 확인**

Run:
```bash
flutter test test/core/constants/space_icons_test.dart
```

Expected: 컴파일 에러 또는 테스트 실패 (`SpaceIcons.rocket` 상수 없음, `Icons.help_outline_rounded` fallback 아님)

---

### Task 1.2: SpaceIcons 재설계 구현 (GREEN)

**Files:**
- Modify: `lib/core/constants/space_icons.dart`

- [ ] **Step 1: 파일 전체 재작성**

Replace entire contents of `lib/core/constants/space_icons.dart`:

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// String ID → Material Icon 레지스트리
///
/// Entity 의 `String icon` 필드는 이모지가 아닌 시맨틱 ID 를 저장한다.
/// UI 렌더링 시 `SpaceIcons.resolve(id)` 로 `IconData` 를 가져온다.
///
/// **사용 예시**:
/// ```dart
/// final iconData = SpaceIcons.resolve(SpaceIcons.rocket);
/// SpaceIcons.buildIcon(SpaceIcons.earth, size: 32);
/// ```
///
/// **레거시 이모지 호환:** Phase 4 마이그레이션 완료 전까지 기존 이모지 키
/// (`\u{1F680}` 등) 도 `resolve()` 를 통해 동일한 IconData 로 변환된다.
class SpaceIcons {
  SpaceIcons._();

  // ============================================
  // Public String ID 상수
  // ============================================

  static const String rocket = 'rocket';
  static const String ufo = 'ufo';
  static const String satellite = 'satellite';
  static const String helicopter = 'helicopter';
  static const String star = 'star';
  static const String sparkleStar = 'sparkleStar';
  static const String sun = 'sun';
  static const String moon = 'moon';
  static const String galaxy = 'galaxy';
  static const String earth = 'earth';
  static const String planet = 'planet';
  static const String fuel = 'fuel';
  static const String fire = 'fire';
  static const String lock = 'lock';
  static const String check = 'check';
  static const String sparkle = 'sparkle';
  static const String trophy = 'trophy';
  static const String astronaut = 'astronaut';
  static const String group = 'group';
  static const String note = 'note';
  static const String home = 'home';
  static const String tool = 'tool';
  static const String footstep = 'footstep';
  static const String book = 'book';
  static const String telescope = 'telescope';
  static const String sailboat = 'sailboat';
  static const String dizzy = 'dizzy';
  static const String target = 'target';
  static const String airplane = 'airplane';
  static const String goldMedal = 'goldMedal';
  static const String medal = 'medal';
  static const String map = 'map';
  static const String oilDrum = 'oilDrum';
  static const String bolt = 'bolt';
  static const String owl = 'owl';
  static const String bird = 'bird';

  // ============================================
  // ID → IconData (primary mapping)
  // ============================================

  static const Map<String, IconData> _idToIcon = {
    rocket: Icons.rocket_launch_rounded,
    ufo: Icons.flight_rounded,
    satellite: Icons.satellite_alt_rounded,
    helicopter: Icons.flight_rounded,
    star: Icons.star_rounded,
    sparkleStar: Icons.auto_awesome_rounded,
    sun: Icons.wb_sunny_rounded,
    moon: Icons.nightlight_round,
    galaxy: Icons.blur_on_rounded,
    earth: Icons.public_rounded,
    planet: Icons.circle_rounded,
    fuel: Icons.local_gas_station_rounded,
    fire: Icons.local_fire_department_rounded,
    lock: Icons.lock_rounded,
    check: Icons.check_circle_rounded,
    sparkle: Icons.auto_awesome,
    trophy: Icons.emoji_events_rounded,
    astronaut: Icons.person_rounded,
    group: Icons.group_rounded,
    note: Icons.edit_note_rounded,
    home: Icons.home_rounded,
    tool: Icons.build_rounded,
    footstep: Icons.directions_walk_rounded,
    book: Icons.menu_book_rounded,
    telescope: Icons.visibility_rounded,
    sailboat: Icons.sailing_rounded,
    dizzy: Icons.blur_circular_rounded,
    target: Icons.track_changes_rounded,
    airplane: Icons.airplanemode_active_rounded,
    goldMedal: Icons.military_tech_rounded,
    medal: Icons.workspace_premium_rounded,
    map: Icons.map_rounded,
    oilDrum: Icons.propane_tank_rounded,
    bolt: Icons.bolt_rounded,
    owl: Icons.dark_mode_rounded,
    bird: Icons.wb_twilight_rounded,
  };

  // ============================================
  // ID → 행성 고유 색상
  // ============================================

  static final Map<String, Color> _idToColor = {
    star: AppColors.accentGold,
    sparkleStar: AppColors.accentGold,
    sun: AppColors.warning,
    rocket: AppColors.primary,
    ufo: AppColors.secondary,
    satellite: AppColors.textTertiary,
    helicopter: AppColors.success,
  };

  // ============================================
  // ID → 행성 그라데이션
  // ============================================

  static final Map<String, List<Color>> _idToGradient = {
    star: [AppColors.accentGoldLight, AppColors.accentGoldDark],
    sparkleStar: [AppColors.accentGoldLight, AppColors.accentGold],
    sun: [AppColors.warning, AppColors.accentGoldDark],
    rocket: [AppColors.primaryLight, AppColors.primaryDark],
    ufo: [AppColors.secondaryLight, AppColors.secondaryDark],
    satellite: [AppColors.textTertiary, AppColors.spaceDivider],
    helicopter: [AppColors.success, AppColors.primaryDark],
  };

  // ============================================
  // [DEPRECATED — Phase 4 에서 제거]
  // 레거시 이모지 → String ID 변환 테이블
  // ============================================

  static const Map<String, String> _legacyEmojiToId = {
    '\u{1F680}': rocket,
    '\u{1F6F8}': ufo,
    '\u{1F6F0}\u{FE0F}': satellite,
    '\u{1F681}': helicopter,
    '\u{2B50}': star,
    '\u{1F31F}': sparkleStar,
    '\u{2600}\u{FE0F}': sun,
    '\u{1F319}': moon,
    '\u{1F30C}': galaxy,
    '\u{1F30D}': earth,
    '\u{1FA90}': planet,
    '\u{26FD}': fuel,
    '\u{1F525}': fire,
    '\u{1F512}': lock,
    '\u{2705}': check,
    '\u{2728}': sparkle,
    '\u{1F3C6}': trophy,
    '\u{1F468}\u{200D}\u{1F680}': astronaut,
    '\u{1F9D1}\u{200D}\u{1F680}': astronaut,
    '\u{1F465}': group,
    '\u{1F4DD}': note,
    '\u{1F3E0}': home,
    '\u{1F6E0}\u{FE0F}': tool,
    '\u{1F463}': footstep,
    '\u{1F4D6}': book,
    '\u{1F52D}': telescope,
    '\u{26F5}': sailboat,
    '\u{1F4AB}': dizzy,
    '\u{1F3AF}': target,
    '\u{2708}\u{FE0F}': airplane,
    '\u{1F947}': goldMedal,
    '\u{1F3C5}': medal,
    '\u{1F5FA}\u{FE0F}': map,
    '\u{1F6E2}\u{FE0F}': oilDrum,
    '\u{26A1}': bolt,
    '\u{1F989}': owl,
    '\u{1F426}': bird,
  };

  // ============================================
  // Public API
  // ============================================

  /// ID (또는 레거시 이모지) 로 IconData 반환.
  /// 매핑이 없으면 `Icons.help_outline_rounded` placeholder 반환.
  static IconData resolve(String key) {
    final direct = _idToIcon[key];
    if (direct != null) return direct;
    final legacyId = _legacyEmojiToId[key];
    if (legacyId != null) {
      return _idToIcon[legacyId] ?? Icons.help_outline_rounded;
    }
    return Icons.help_outline_rounded;
  }

  /// ID (또는 레거시 이모지) 로 고유 색상 반환.
  static Color colorOf(String key) {
    final direct = _idToColor[key];
    if (direct != null) return direct;
    final legacyId = _legacyEmojiToId[key];
    if (legacyId != null) {
      return _idToColor[legacyId] ?? AppColors.textTertiary;
    }
    return AppColors.textTertiary;
  }

  /// ID (또는 레거시 이모지) 로 그라데이션 2색 반환.
  static List<Color> gradientOf(String key) {
    final direct = _idToGradient[key];
    if (direct != null) return direct;
    final legacyId = _legacyEmojiToId[key];
    if (legacyId != null) {
      return _idToGradient[legacyId] ??
          const [AppColors.textTertiary, AppColors.spaceDivider];
    }
    return const [AppColors.textTertiary, AppColors.spaceDivider];
  }

  /// ID 를 그라데이션 원형 아이콘 위젯으로 변환
  static Widget buildIcon(
    String key, {
    double size = 24,
    Color? color,
    bool useGradient = true,
  }) {
    final iconData = resolve(key);
    final iconColor = color ?? colorOf(key);

    if (!useGradient) {
      return Icon(iconData, size: size, color: iconColor);
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientOf(key),
      ).createShader(bounds),
      child: Icon(iconData, size: size, color: Colors.white),
    );
  }
}
```

- [ ] **Step 2: 테스트 실행해서 통과 확인**

Run:
```bash
flutter test test/core/constants/space_icons_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 3: 정적 분석 통과 확인**

Run:
```bash
flutter analyze lib/core/constants/space_icons.dart
```

Expected: `No issues found!` 또는 경고 0개

- [ ] **Step 4: 기존 호출부가 여전히 동작하는지 확인 (레거시 호환)**

Run:
```bash
flutter analyze lib/core/widgets/space/spaceship_avatar.dart lib/core/widgets/space/spaceship_card.dart lib/features/profile/presentation/screens/spaceship_collection_screen.dart
```

Expected: `No issues found!` (이 파일들은 여전히 이모지를 resolve 에 전달할 것이고, `_legacyEmojiToId` 가 흡수)

- [ ] **Step 5: 커밋**

Run:
```bash
git add lib/core/constants/space_icons.dart test/core/constants/space_icons_test.dart
git commit -m "refactor : space_icons 레지스트리 String ID 방식으로 재설계 #68

- String ID 상수 36개 public 노출 (rocket, lock, trophy 등)
- _idToIcon/_idToColor/_idToGradient 맵을 ID 키로 재구성
- 기존 Color(0xFF) 리터럴을 AppColors.* 로 교체
- 레거시 이모지 호환용 _legacyEmojiToId 과도기 테이블 유지
- resolve()/colorOf()/gradientOf() 가 ID/레거시 이모지 모두 처리
- help_outline_rounded placeholder 로 미매핑 키 처리
- 단위 테스트: ID 매핑·레거시 호환·알 수 없는 키·public 상수 검증"
```

---

## Phase 2: Seed 데이터 & 모델 마이그레이션

### Task 2.1: 우주선 데이터 마이그레이션 (spaceship_data.dart)

**Files:**
- Modify: `lib/features/home/presentation/models/spaceship_data.dart`
- Create: `test/features/home/presentation/models/spaceship_data_test.dart`

- [ ] **Step 1: 테스트 파일 생성 (RED)**

Create `test/features/home/presentation/models/spaceship_data_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/home/presentation/models/spaceship_data.dart';

void main() {
  group('SpaceshipData.sampleList', () {
    test('모든 샘플의 icon 값이 SpaceIcons.resolve 에서 placeholder 가 아님', () {
      for (final ship in SpaceshipData.sampleList) {
        final icon = SpaceIcons.resolve(ship.icon);
        expect(
          icon,
          isNot(Icons.help_outline_rounded),
          reason: 'Spaceship "${ship.id}" 의 icon "${ship.icon}" 이 매핑 실패',
        );
      }
    });

    test('모든 icon 값이 이모지가 아닌 String ID 임', () {
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      );
      for (final ship in SpaceshipData.sampleList) {
        expect(
          emojiPattern.hasMatch(ship.icon),
          isFalse,
          reason: 'Spaceship "${ship.id}" 의 icon "${ship.icon}" 에 이모지가 남아있음',
        );
      }
    });
  });
}
```

- [ ] **Step 2: 테스트 실행해서 실패 확인**

Run:
```bash
flutter test test/features/home/presentation/models/spaceship_data_test.dart
```

Expected: 두 번째 테스트 FAIL ("icon 에 이모지가 남아있음")

- [ ] **Step 3: spaceship_data.dart 교체 (GREEN)**

Replace `lib/features/home/presentation/models/spaceship_data.dart`:

```dart
import '../../../../core/constants/space_icons.dart';
import '../../../../core/widgets/space/spaceship_card.dart';

/// 우주선 데이터 모델 (임시 — 서버 연동 시 domain entity 로 전환)
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

  /// 임시 샘플 데이터 (나중에 Riverpod Provider 로 이동)
  static const sampleList = [
    SpaceshipData(
      id: 'default',
      icon: SpaceIcons.rocket,
      name: '우주공부선',
      isUnlocked: true,
      rarity: SpaceshipRarity.normal,
      lottieAsset: 'assets/lotties/default_rocket.json',
    ),
    SpaceshipData(
      id: 'ufo',
      icon: SpaceIcons.ufo,
      name: 'UFO',
      isUnlocked: true,
      rarity: SpaceshipRarity.rare,
    ),
    SpaceshipData(
      id: 'satellite',
      icon: SpaceIcons.satellite,
      name: '인공위성',
      isUnlocked: true,
      isAnimated: true,
      rarity: SpaceshipRarity.epic,
    ),
    SpaceshipData(
      id: 'star',
      icon: SpaceIcons.sparkleStar,
      name: '스타쉽',
      isUnlocked: false,
      rarity: SpaceshipRarity.legendary,
    ),
    SpaceshipData(
      id: 'shuttle',
      icon: SpaceIcons.helicopter,
      name: '셔틀',
      isUnlocked: false,
      rarity: SpaceshipRarity.normal,
    ),
    SpaceshipData(
      id: 'moon',
      icon: SpaceIcons.moon,
      name: '달 탐사선',
      isUnlocked: false,
      rarity: SpaceshipRarity.rare,
    ),
  ];
}
```

- [ ] **Step 4: 테스트 실행해서 통과 확인**

Run:
```bash
flutter test test/features/home/presentation/models/spaceship_data_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: analyze 확인**

Run:
```bash
flutter analyze lib/features/home/presentation/models/spaceship_data.dart
```

Expected: `No issues found!`

- [ ] **Step 6: 커밋**

Run:
```bash
git add lib/features/home/presentation/models/spaceship_data.dart test/features/home/presentation/models/spaceship_data_test.dart
git commit -m "refactor : 우주선 샘플 데이터 이모지 → SpaceIcons ID 교체 #68"
```

---

### Task 2.2: 뱃지 시드 데이터 마이그레이션 (badge_seed_data.dart)

**Files:**
- Modify: `lib/features/badge/data/seed/badge_seed_data.dart`
- Create: `test/features/badge/data/seed/badge_seed_data_test.dart`

- [ ] **Step 1: 테스트 파일 생성 (RED)**

Create `test/features/badge/data/seed/badge_seed_data_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/badge/data/seed/badge_seed_data.dart';

void main() {
  group('BadgeSeedData.allBadges', () {
    test('25개 이상의 뱃지가 정의됨', () {
      expect(BadgeSeedData.allBadges.length, greaterThanOrEqualTo(25));
    });

    test('모든 뱃지 id 가 고유함', () {
      final ids = BadgeSeedData.allBadges.map((b) => b.id).toList();
      final unique = ids.toSet();
      expect(unique.length, ids.length, reason: '중복 id 존재');
    });

    test('모든 뱃지 icon 값이 SpaceIcons.resolve 에서 placeholder 가 아님', () {
      for (final badge in BadgeSeedData.allBadges) {
        final icon = SpaceIcons.resolve(badge.icon);
        expect(
          icon,
          isNot(Icons.help_outline_rounded),
          reason: 'Badge "${badge.id}" 의 icon "${badge.icon}" 이 매핑 실패',
        );
      }
    });

    test('모든 icon 값이 이모지가 아닌 String ID 임', () {
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      );
      for (final badge in BadgeSeedData.allBadges) {
        expect(
          emojiPattern.hasMatch(badge.icon),
          isFalse,
          reason: 'Badge "${badge.id}" 의 icon "${badge.icon}" 에 이모지가 남아있음',
        );
      }
    });
  });
}
```

- [ ] **Step 2: 테스트 실행해서 실패 확인**

Run:
```bash
flutter test test/features/badge/data/seed/badge_seed_data_test.dart
```

Expected: "icon 에 이모지가 남아있음" 테스트 FAIL

- [ ] **Step 3: badge_seed_data.dart 교체 (GREEN)**

Replace `lib/features/badge/data/seed/badge_seed_data.dart`:

```dart
import '../../../../core/constants/space_icons.dart';
import '../../domain/entities/badge_entity.dart';

/// 배지 시드 데이터 (25개)
///
/// 정적 배지 정의. 해금 상태는 기본값(false).
/// 서버 연동 시 API 응답으로 교체 예정.
///
/// `icon` 필드는 `SpaceIcons` 의 String ID 상수를 사용한다.
/// UI 렌더링 시 `SpaceIcons.resolve(badge.icon)` 로 IconData 변환.
class BadgeSeedData {
  BadgeSeedData._();

  // ──────────────────────────────────────
  // studyTime — 공부 시간 (requiredValue: 분)
  // ──────────────────────────────────────
  static const List<BadgeEntity> studyTime = [
    BadgeEntity(
      id: 'study_1h',
      name: '첫 발걸음',
      icon: SpaceIcons.footstep,
      description: '누적 공부 시간 1시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 60,
    ),
    BadgeEntity(
      id: 'study_10h',
      name: '꾸준한 학습자',
      icon: SpaceIcons.book,
      description: '누적 공부 시간 10시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 600,
    ),
    BadgeEntity(
      id: 'study_50h',
      name: '지식 탐험가',
      icon: SpaceIcons.telescope,
      description: '누적 공부 시간 50시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 3000,
    ),
    BadgeEntity(
      id: 'study_100h',
      name: '학문의 별',
      icon: SpaceIcons.star,
      description: '누적 공부 시간 100시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 6000,
    ),
    BadgeEntity(
      id: 'study_500h',
      name: '우주 학자',
      icon: SpaceIcons.planet,
      description: '누적 공부 시간 500시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.epic,
      requiredValue: 30000,
    ),
    BadgeEntity(
      id: 'study_1000h',
      name: '은하의 현자',
      icon: SpaceIcons.galaxy,
      description: '누적 공부 시간 1,000시간 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.legendary,
      requiredValue: 60000,
    ),
  ];

  // ──────────────────────────────────────
  // streak — 연속 기록 (requiredValue: 일)
  // ──────────────────────────────────────
  static const List<BadgeEntity> streak = [
    BadgeEntity(
      id: 'streak_3',
      name: '3일의 약속',
      icon: SpaceIcons.fire,
      description: '3일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 3,
    ),
    BadgeEntity(
      id: 'streak_7',
      name: '일주일 파일럿',
      icon: SpaceIcons.rocket,
      description: '7일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 7,
    ),
    BadgeEntity(
      id: 'streak_14',
      name: '2주 항해사',
      icon: SpaceIcons.sailboat,
      description: '14일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      requiredValue: 14,
    ),
    BadgeEntity(
      id: 'streak_30',
      name: '한 달의 궤도',
      icon: SpaceIcons.moon,
      description: '30일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 30,
    ),
    BadgeEntity(
      id: 'streak_60',
      name: '60일의 항성',
      icon: SpaceIcons.sun,
      description: '60일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 60,
    ),
    BadgeEntity(
      id: 'streak_100',
      name: '백일의 전설',
      icon: SpaceIcons.dizzy,
      description: '100일 연속 공부 달성',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.legendary,
      requiredValue: 100,
    ),
  ];

  // ──────────────────────────────────────
  // session — 세션 수 (requiredValue: 횟수)
  // ──────────────────────────────────────
  static const List<BadgeEntity> session = [
    BadgeEntity(
      id: 'session_1',
      name: '엔진 점화',
      icon: SpaceIcons.target,
      description: '첫 번째 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 1,
    ),
    BadgeEntity(
      id: 'session_10',
      name: '열 번의 비행',
      icon: SpaceIcons.airplane,
      description: '공부 세션 10회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'session_50',
      name: '반백의 여정',
      icon: SpaceIcons.ufo,
      description: '공부 세션 50회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'session_100',
      name: '백전백승',
      icon: SpaceIcons.medal,
      description: '공부 세션 100회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 100,
    ),
    BadgeEntity(
      id: 'session_500',
      name: '전설의 조종사',
      icon: SpaceIcons.astronaut,
      description: '공부 세션 500회 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.epic,
      requiredValue: 500,
    ),
  ];

  // ──────────────────────────────────────
  // exploration — 탐험 (requiredValue: 해금 수)
  // ──────────────────────────────────────
  static const List<BadgeEntity> exploration = [
    BadgeEntity(
      id: 'explore_first_planet',
      name: '우주의 문',
      icon: SpaceIcons.earth,
      description: '행성 2개 해금 (지구 포함)',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2,
    ),
    BadgeEntity(
      id: 'explore_all_planets',
      name: '태양계 정복자',
      icon: SpaceIcons.trophy,
      description: '모든 행성 해금',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.epic,
      requiredValue: 4,
    ),
    BadgeEntity(
      id: 'explore_first_region',
      name: '첫 탐사',
      icon: SpaceIcons.map,
      description: '지역 2개 해금 (대한민국 포함)',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2,
    ),
  ];

  // ──────────────────────────────────────
  // fuel — 연료 (requiredValue: 총 충전량)
  // ──────────────────────────────────────
  static const List<BadgeEntity> fuel = [
    BadgeEntity(
      id: 'fuel_10',
      name: '연료 수집가',
      icon: SpaceIcons.fuel,
      description: '연료 총 10 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'fuel_50',
      name: '연료 비축대장',
      icon: SpaceIcons.oilDrum,
      description: '연료 총 50 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'fuel_100',
      name: '에너지 마스터',
      icon: SpaceIcons.bolt,
      description: '연료 총 100 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.epic,
      requiredValue: 100,
    ),
  ];

  // ──────────────────────────────────────
  // hidden — 히든 (requiredValue: 24시간 기준 시각)
  // ──────────────────────────────────────
  static const List<BadgeEntity> hidden = [
    BadgeEntity(
      id: 'hidden_night_owl',
      name: '올빼미',
      icon: SpaceIcons.owl,
      description: '새벽 3시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 3,
    ),
    BadgeEntity(
      id: 'hidden_early_bird',
      name: '얼리버드',
      icon: SpaceIcons.bird,
      description: '오전 5시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 5,
    ),
  ];

  /// 전체 배지 목록 (25개)
  static const List<BadgeEntity> allBadges = [
    ...studyTime,
    ...streak,
    ...session,
    ...exploration,
    ...fuel,
    ...hidden,
  ];
}
```

- [ ] **Step 4: 테스트 실행해서 통과 확인**

Run:
```bash
flutter test test/features/badge/data/seed/badge_seed_data_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: analyze 확인**

Run:
```bash
flutter analyze lib/features/badge/data/seed/badge_seed_data.dart
```

Expected: `No issues found!`

- [ ] **Step 6: 커밋**

Run:
```bash
git add lib/features/badge/data/seed/badge_seed_data.dart test/features/badge/data/seed/badge_seed_data_test.dart
git commit -m "refactor : 뱃지 시드 데이터 이모지 → SpaceIcons ID 교체 #68"
```

---

## Phase 3: UI 위젯 이모지 리터럴 제거

### Task 3.1: BadgeCard 위젯 이모지 리터럴 제거

**Files:**
- Modify: `lib/features/badge/presentation/widgets/badge_card.dart`
- Create: `test/features/badge/presentation/widgets/badge_card_test.dart`

- [ ] **Step 1: 위젯 테스트 파일 생성 (RED)**

Create `test/features/badge/presentation/widgets/badge_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/badge/domain/entities/badge_entity.dart';
import 'package:space_study_ship/features/badge/presentation/widgets/badge_card.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => child,
      ),
    ),
  );
}

void main() {
  group('BadgeCard', () {
    testWidgets('잠금 상태에서 lock 아이콘 렌더링', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const BadgeCard(
            icon: SpaceIcons.rocket,
            name: 'Test Badge',
            isUnlocked: false,
            rarity: BadgeRarity.normal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // lock 아이콘이 렌더되어야 함
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      // 이모지 문자 '🔒' 은 없어야 함
      expect(find.text('\u{1F512}'), findsNothing);
    });

    testWidgets('해금 상태에서 실제 뱃지 아이콘 렌더링', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const BadgeCard(
            icon: SpaceIcons.rocket,
            name: 'Test Badge',
            isUnlocked: true,
            rarity: BadgeRarity.normal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // rocket 아이콘이 렌더되어야 함
      expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행해서 실패 확인**

Run:
```bash
flutter test test/features/badge/presentation/widgets/badge_card_test.dart
```

Expected: 테스트 FAIL (현재 `badge_card.dart` 가 `Text('🔒')` 를 사용하므로 `find.byIcon` 이 실패)

- [ ] **Step 3: badge_card.dart 수정 (GREEN)**

Modify `lib/features/badge/presentation/widgets/badge_card.dart`. 다음과 같이 변경한다:

import 섹션 상단에 추가:

```dart
import '../../../../core/constants/space_icons.dart';
```

`_BadgeCardState.build()` 내부의 아이콘 렌더링 부분 (line 119-127) 을 다음과 같이 교체:

```dart
// 아이콘 (SpaceIcons 에서 IconData 로 변환)
Semantics(
  label: widget.isUnlocked ? '${widget.name} 배지 아이콘' : '잠긴 배지',
  child: ExcludeSemantics(
    child: Icon(
      SpaceIcons.resolve(widget.isUnlocked ? widget.icon : SpaceIcons.lock),
      size: 28.sp,
      color: widget.isUnlocked
          ? _iconColor
          : AppColors.textTertiary,
    ),
  ),
),
```

그리고 클래스 내부에 `_iconColor` getter 를 추가 (`_borderColor` getter 아래):

```dart
Color get _iconColor {
  switch (widget.rarity) {
    case BadgeRarity.normal:
      return Colors.white;
    case BadgeRarity.rare:
      return AppColors.primary;
    case BadgeRarity.epic:
      return AppColors.secondary;
    case BadgeRarity.legendary:
      return AppColors.accentGold;
    case BadgeRarity.hidden:
      return AppColors.accentPink;
  }
}
```

**주의:** 기존 `Text(widget.icon)` 은 `fontSize: 28.sp` 였다. `Icon` 위젯의 `size` 에 `28.sp` 를 그대로 전달해 시각적 크기를 유지한다.

- [ ] **Step 4: 테스트 실행해서 통과 확인**

Run:
```bash
flutter test test/features/badge/presentation/widgets/badge_card_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: analyze 확인**

Run:
```bash
flutter analyze lib/features/badge/presentation/widgets/badge_card.dart
```

Expected: `No issues found!`

- [ ] **Step 6: 시각 확인 (수동)**

Run:
```bash
flutter run
```

앱이 뜨면 프로필 탭 → 뱃지 컬렉션 진입 → 잠긴 뱃지와 해금된 뱃지의 아이콘 크기·색상·정렬이 정상인지 확인.

Expected: 아이콘 교체 후에도 카드 레이아웃이 깨지지 않음. 잠긴 뱃지는 회색 lock 아이콘, 해금된 뱃지는 rarity 색상의 아이콘.

(시각 확인 후 앱 종료: `q` 입력)

- [ ] **Step 7: 커밋**

```bash
git add lib/features/badge/presentation/widgets/badge_card.dart test/features/badge/presentation/widgets/badge_card_test.dart
git commit -m "refactor : BadgeCard 이모지 리터럴 → Icon 위젯 교체 #68"
```

---

### Task 3.2: BadgeDetailDialog 이모지 리터럴 제거

**Files:**
- Modify: `lib/features/badge/presentation/widgets/badge_detail_dialog.dart`

- [ ] **Step 1: 파일 수정**

Replace `lib/features/badge/presentation/widgets/badge_detail_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../domain/entities/badge_entity.dart';

/// 배지 상세 다이얼로그 (공통)
///
/// [isUnlockCelebration] 이 true 이면 해금 축하 팝업으로 표시합니다.
Future<void> showBadgeDetailDialog(
  BuildContext context,
  BadgeEntity badge, {
  bool isUnlockCelebration = false,
}) {
  final showRealIcon = badge.isUnlocked || isUnlockCelebration;
  final hiddenAndLocked =
      !showRealIcon && badge.category == BadgeCategory.hidden;
  final iconId = hiddenAndLocked ? SpaceIcons.lock : badge.icon;
  final iconColor = showRealIcon ? Colors.white : AppColors.textTertiary;

  return AppDialog.show(
    context: context,
    title: isUnlockCelebration
        ? '배지 획득!'
        : badge.isUnlocked
        ? badge.name
        : badge.category == BadgeCategory.hidden
        ? '???'
        : badge.name,
    customContent: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          SpaceIcons.resolve(iconId),
          size: 48.sp,
          color: iconColor,
        ),
        SizedBox(height: AppSpacing.s12),
        if (isUnlockCelebration) ...[
          Text(
            badge.name,
            style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.s8),
        ],
        Text(
          showRealIcon
              ? badge.description
              : badge.category == BadgeCategory.hidden
              ? '아직 해금되지 않은 배지예요'
              : '해금 조건: ${badge.unlockConditionText}',
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: analyze 확인**

Run:
```bash
flutter analyze lib/features/badge/presentation/widgets/badge_detail_dialog.dart
```

Expected: `No issues found!`

- [ ] **Step 3: 전체 뱃지 관련 테스트 재실행**

Run:
```bash
flutter test test/features/badge/
```

Expected: 모든 테스트 PASS

- [ ] **Step 4: 시각 확인 (수동)**

Run `flutter run` (이미 떠있다면 hot reload `r`). 뱃지 컬렉션에서 아무 뱃지를 탭 → 상세 다이얼로그가 열리고, 잠긴 뱃지는 lock 아이콘, 해금된 뱃지는 실제 아이콘이 48sp 크기로 렌더.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/badge/presentation/widgets/badge_detail_dialog.dart
git commit -m "refactor : BadgeDetailDialog 이모지 리터럴 → Icon 위젯 교체 #68"
```

---

## Phase 4: 레거시 매핑 제거 & 최종 검증

### Task 4.1: 레거시 이모지 테이블 제거

**Files:**
- Modify: `lib/core/constants/space_icons.dart`
- Modify: `test/core/constants/space_icons_test.dart`

- [ ] **Step 1: 레거시 테스트 케이스 먼저 제거 (테스트 RED 방지)**

Edit `test/core/constants/space_icons_test.dart` — "레거시 이모지 키도 IconData 로 변환" 과 "레거시 이모지로도 색상 반환" / "레거시 이모지로도 그라데이션 반환" 테스트 3개를 삭제.

레거시 테스트 3개를 제거한 후 다음 테스트를 추가:

```dart
test('레거시 이모지 키는 더 이상 매핑되지 않고 placeholder 반환', () {
  expect(SpaceIcons.resolve('\u{1F680}'), Icons.help_outline_rounded);
  expect(SpaceIcons.resolve('\u{1F512}'), Icons.help_outline_rounded);
});
```

- [ ] **Step 2: `space_icons.dart` 에서 `_legacyEmojiToId` 및 관련 로직 제거**

Modify `lib/core/constants/space_icons.dart`:

1. `_legacyEmojiToId` Map 선언 전체를 삭제
2. `resolve()` 를 다음으로 교체:

```dart
/// ID 로 IconData 반환. 매핑이 없으면 placeholder.
static IconData resolve(String id) {
  return _idToIcon[id] ?? Icons.help_outline_rounded;
}
```

3. `colorOf()` 를 다음으로 교체:

```dart
/// ID 로 고유 색상 반환.
static Color colorOf(String id) {
  return _idToColor[id] ?? AppColors.textTertiary;
}
```

4. `gradientOf()` 를 다음으로 교체:

```dart
/// ID 로 그라데이션 2색 반환.
static List<Color> gradientOf(String id) {
  return _idToGradient[id] ??
      const [AppColors.textTertiary, AppColors.spaceDivider];
}
```

5. 클래스 DocComment 의 "**레거시 이모지 호환:**" 문단 삭제

- [ ] **Step 3: 테스트 실행**

Run:
```bash
flutter test test/core/constants/space_icons_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 4: 전체 프로젝트 analyze**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

만약 `lib/` 어딘가에서 아직 이모지 문자열을 `SpaceIcons.resolve(...)` 에 전달하고 있다면 analyze 는 통과하지만 런타임에 `help_outline_rounded` 가 렌더된다. 그래서 다음 Step 에서 grep 으로 재확인.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/constants/space_icons.dart test/core/constants/space_icons_test.dart
git commit -m "chore : space_icons 레거시 이모지 매핑 제거 #68"
```

---

### Task 4.2: 최종 검증 — design-guardian 셀프체크

**Files:** (검증만, 수정 없음)

- [ ] **Step 1: 전체 테스트 실행**

Run:
```bash
flutter test
```

Expected: 모든 테스트 PASS, 실패 0건

- [ ] **Step 2: 전체 analyze**

Run:
```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: 대상 영역 이모지 잔존 확인 (수동 grep)**

Run:
```bash
python3 <<'PY'
import os, re, pathlib
EMOJI = re.compile(
    r"[\U0001F300-\U0001F9FF"
    r"\U00002600-\U000027BF"
    r"\U0001F600-\U0001F64F"
    r"\U0001FA00-\U0001FAFF]"
)
TARGETS = [
    "lib/core/constants/space_icons.dart",
    "lib/features/home/presentation/models/spaceship_data.dart",
    "lib/features/badge/data/seed/badge_seed_data.dart",
    "lib/features/badge/presentation/widgets/badge_card.dart",
    "lib/features/badge/presentation/widgets/badge_detail_dialog.dart",
]
violations = 0
for t in TARGETS:
    p = pathlib.Path(t)
    if not p.exists():
        print(f"MISSING: {t}")
        continue
    for i, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
        # Dart 의 \u{...} escape 는 컴파일 시 이모지가 되므로 이것도 잡힘
        if EMOJI.search(line):
            stripped = line.strip()
            # 주석은 허용
            if stripped.startswith("//") or stripped.startswith("///") or stripped.startswith("*"):
                continue
            # debugPrint 는 허용
            if "debugPrint" in line or "print(" in line:
                continue
            print(f"VIOLATION {t}:{i} — {stripped[:100]}")
            violations += 1
print(f"\nTotal violations: {violations}")
PY
```

Expected: `Total violations: 0`

- [ ] **Step 4: Design Guardian 에이전트 호출 (선택)**

더 확실하게 검증하려면 `flutter-design-guardian` 에이전트를 호출해 `lib/` 전체를 검사:

Use the Agent tool with `subagent_type: flutter-design-guardian` and prompt:

```
lib/features/badge/ · lib/features/home/presentation/models/ ·
lib/core/constants/space_icons.dart 를 검사하세요. 이모지·Color(0xFF)·
TextStyle inline·BoxShadow·Material 위젯 직접 사용을 grep 으로 검출해
보고서를 반환합니다.
```

Expected: 대상 파일에서 이모지 0건 보고

- [ ] **Step 5: 실행 테스트 (수동)**

Run:
```bash
flutter run
```

확인할 화면:
1. **홈** — 우주선 카드에서 rocket 아이콘이 정상 렌더
2. **프로필 → 뱃지 컬렉션** — 25개 뱃지 카드가 정상 렌더, 잠긴 것은 lock, 해금된 것은 각 아이콘
3. **뱃지 탭** — 아무 뱃지 상세 다이얼로그 열기 → 48sp 아이콘 렌더
4. **프로필 → 우주선 컬렉션** — 모든 우주선 카드가 정상 렌더

Expected: 4개 화면 모두 정상 렌더, 이모지가 그려지던 자리에 Material Icon 이 대체되어 있음.

(확인 후 `q` 로 앱 종료)

- [ ] **Step 6: 최종 커밋 없음**

이 Task 는 검증만 수행하므로 별도 커밋을 만들지 않는다. 문제가 있으면 이전 Task 로 돌아가 수정 후 amend 가 아닌 새 커밋 생성.

---

## 완료 조건 (Spec Success Criteria 매핑)

- [x] `SpaceIcons` 가 String ID 방식으로 재설계됨 → **Task 1.2**
- [x] `badge_seed_data.dart` 의 모든 `\u{...}` icon 값이 `SpaceIcons.xxx` 로 교체됨 → **Task 2.2**
- [x] `spaceship_data.dart` 의 모든 이모지 icon 값이 `SpaceIcons.xxx` 로 교체됨 → **Task 2.1**
- [x] `badge_card.dart` / `badge_detail_dialog.dart` 의 `'🔒'` 리터럴 제거됨 → **Task 3.1 / 3.2**
- [x] `_legacyEmojiToId` 테이블 제거됨 → **Task 4.1**
- [x] `flutter analyze` clean · `flutter test` 통과 → **Task 4.2 Step 1-2**
- [x] design-guardian 이 대상 영역에서 이모지를 발견하지 않음 → **Task 4.2 Step 3-4**
- [x] 앱 실행 시 배지/우주선/홈/탐험 정상 렌더 → **Task 4.2 Step 5**
