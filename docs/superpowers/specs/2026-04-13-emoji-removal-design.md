# Spec — 이모지 전면 제거 마이그레이션 (Phase 1: lib/)

**Date:** 2026-04-13
**Issue:** #68
**Branch:** `20260412_#68_이모지_전면_제거_마이그레이션`
**Status:** Approved

---

## Problem

프로젝트 전역에 이모지가 산재해 있어 DESIGN.md 의 "이모지 전면 금지" 원칙과 충돌한다. 전수조사 결과 163개 파일, 2,729건 발견. 본 스펙은 그중 **사용자가 직접 보는 앱 코드 (`lib/`)** 에 한정하며, 특히 **뱃지 시스템처럼 시스템 차원의 의미를 갖는 주요 기능에 쓰인 이모지** 를 대상으로 한다.

핵심 문제:
- `space_icons.dart` 가 이모지를 **데이터 키** 로 사용하는 레지스트리 구조
- `badge_seed_data.dart` 의 icon 필드가 `\u{...}` 이모지 이스케이프를 저장
- `spaceship_data.dart` 의 icon 필드가 이모지 리터럴을 저장
- `badge_card.dart` / `badge_detail_dialog.dart` 가 `'🔒'` fallback 리터럴 사용

## Goal

`lib/` 하위 뱃지·우주선·space_icons 영역에서 이모지를 제거하고, String ID 기반 레지스트리로 전환한다. 기존 호출부 (`SpaceIcons.resolve(icon)`) 는 깨지 않는 하위 호환 전략으로 무중단 마이그레이션.

## Non-Goals

- `debugPrint` 로그의 이모지 (101건) — dev-only, 유지
- `test_widget_page.dart` (15건) — dev 테스트 화면, 유지
- 코드 주석의 이모지 (14건) — 예시/문서용, 유지
- 스낵바·알림 등 작은 장식용 이모지 — 유지
- `docs/` · `.github/` · `.claude/` · `docs/plans/` — 별도 이슈로
- Entity 구조 변경 (icon 필드 타입은 `String` 유지)

---

## Design Decisions

### 1. 접근법 — String ID 리팩터 (채택)

Entity 의 `icon: String` 필드는 유지하되 값을 이모지 문자에서 시맨틱 ID 문자열로 교체.

```dart
// Before
BadgeEntity(icon: '\u{1F680}', ...)  // '🚀'

// After
BadgeEntity(icon: 'rocket', ...)
```

**장점:**
- Entity 구조 변경 없음 → Freezed 재생성 불필요
- DB 직렬화 영향 없음
- 로그·JSON 디버깅 시 `"icon": "rocket"` 이 훨씬 명확
- i18n 시 번역 키 매핑에 유리

**Rejected:**
- **접근 B — Entity 구조 변경 (IconData 직접)**: Freezed 재생성·JSON 커스텀 converter·DB 영향 큼
- **접근 C — Icon enum**: 타입 안전하나 확장성 낮음 (새 아이콘 추가 시 enum 수정)

### 2. `space_icons.dart` 재설계

**Before:** `Map<String emoji, IconData>`
**After:** `Map<String id, IconData>` + `SpaceIcons.rocket` 같은 public 상수 노출

### 3. 하위 호환 전략

Phase 1 에서 레거시 이모지 → ID 변환 테이블 (`_legacyEmojiToId`) 을 임시 유지. 이렇게 하면:
- 기존 로컬 DB 에 저장된 이모지 값이 그대로 읽혀도 정상 렌더
- 모든 seed·UI 이 교체된 후 Phase 4 에서 레거시 테이블 제거

### 4. 네이밍 규칙

- **lowerCamelCase** (Dart 컨벤션)
- **단일 단어 우선** (`rocket`, `star`)
- **복합어는 camelCase** (`rocketLaunch`, `sparkleStar`)
- **의미 기반 네이밍** (이모지 모양이 아닌 의미)
- **aerospace 어휘와 조화** (DESIGN.md Section 7 과 일관)

---

## Scope

### In-Scope (대상 파일)

**카테고리 1 — Entity icon 필드 데이터 마이그레이션**

| 파일 | 현재 | 교체 후 |
|------|------|--------|
| `lib/features/badge/data/seed/badge_seed_data.dart` | `icon: '\u{1F680}'` 등 ~30건 | `icon: SpaceIcons.rocket` |
| `lib/features/home/presentation/models/spaceship_data.dart` | `icon: '🚀'` 등 6건 | `icon: SpaceIcons.rocket` |

**카테고리 2 — 이모지 리터럴 UI 제거**

| 파일 | 현재 | 교체 후 |
|------|------|--------|
| `lib/features/badge/presentation/widgets/badge_card.dart:123` | `widget.icon : '🔒'` | `SpaceIcons.resolve(... ?? SpaceIcons.lock)` → `Icon(...)` |
| `lib/features/badge/presentation/widgets/badge_detail_dialog.dart:34` | `? '🔒'` | 동일 패턴 |

**카테고리 3 — 레지스트리 재설계**

| 파일 | 작업 |
|------|------|
| `lib/core/constants/space_icons.dart` | `_idToIcon` + public String 상수 + `_legacyEmojiToId` 과도기 테이블 추가, `Color(0xFF...)` 는 `AppColors.*` 로 함께 정리 |

### Out-of-Scope

- `debugPrint` 101건 — dev-only, 유지
- `test_widget_page.dart` 15건 — dev 테스트, 유지
- 코드 주석 14건 — 문서용, 유지
- UI 작은 장식 이모지 (스낵바 등) — 유지
- `docs/` · `.github/` · `.claude/` · `docs/plans/` — 별도 이슈
- 로컬 DB 마이그레이션 스크립트 — 레거시 호환 테이블로 커버되므로 불필요

---

## Naming Table — 이모지 → String ID → IconData

| 이모지 | String ID | Material Icon |
|--------|-----------|---------------|
| 🚀 | `rocket` | `Icons.rocket_launch_rounded` |
| 🛸 | `ufo` | `Icons.flight_rounded` |
| 🛰️ | `satellite` | `Icons.satellite_alt_rounded` |
| 🚁 | `helicopter` | `Icons.flight_rounded` |
| ⭐ | `star` | `Icons.star_rounded` |
| 🌟 | `sparkleStar` | `Icons.auto_awesome_rounded` |
| ☀️ | `sun` | `Icons.wb_sunny_rounded` |
| 🌙 | `moon` | `Icons.nightlight_round` |
| 🌌 | `galaxy` | `Icons.blur_on_rounded` |
| 🌍 | `earth` | `Icons.public_rounded` |
| ⛽ | `fuel` | `Icons.local_gas_station_rounded` |
| 🔥 | `fire` | `Icons.local_fire_department_rounded` |
| 🔒 | `lock` | `Icons.lock_rounded` |
| ✅ | `check` | `Icons.check_circle_rounded` |
| ✨ | `sparkle` | `Icons.auto_awesome` |
| 🏆 | `trophy` | `Icons.emoji_events_rounded` |
| 👨‍🚀 / 🧑‍🚀 | `astronaut` | `Icons.person_rounded` |
| 👥 | `group` | `Icons.group_rounded` |
| 📝 | `note` | `Icons.edit_note_rounded` |
| 🏠 | `home` | `Icons.home_rounded` |
| 🛠️ | `tool` | `Icons.build_rounded` |
| 👣 | `footstep` | `Icons.directions_walk_rounded` |
| 📖 | `book` | `Icons.menu_book_rounded` |
| 🔭 | `telescope` | `Icons.visibility_rounded` |
| 🪐 | `planet` | `Icons.circle_rounded` |
| ⛵ | `sailboat` | `Icons.sailing_rounded` |
| 💫 | `dizzy` | `Icons.blur_circular_rounded` |
| 🎯 | `target` | `Icons.track_changes_rounded` |
| ✈️ | `airplane` | `Icons.airplanemode_active_rounded` |
| 🛡️ | `shield` | `Icons.shield_rounded` |
| 🥇 | `medal` | `Icons.military_tech_rounded` |
| 🗺️ | `map` | `Icons.map_rounded` |

**미매핑 이모지 처리:** 마이그레이션 중 테이블에 없는 이모지 발견 시 → Material Icons 에서 가장 근접한 것 찾기 → 없으면 FontAwesome → 여전히 없으면 `Icons.help_outline_rounded` placeholder + TODO 코멘트.

---

## Migration Phases

### Phase 1 — 새 `SpaceIcons` 레지스트리 (하위 호환)

**산출물:**
- `lib/core/constants/space_icons.dart` 재설계
  - Public `static const String` 상수 (`rocket`, `ufo` 등)
  - `_idToIcon: Map<String, IconData>` 주 테이블
  - `_legacyEmojiToId: Map<String, String>` 과도기 테이블 (DEPRECATED 주석)
  - `resolve()` 메서드가 ID/레거시 이모지 둘 다 처리
  - 기존 `Color(0xFF...)` 리터럴을 `AppColors.*` 로 정리

**테스트 (`test/core/constants/space_icons_test.dart`):**
- `resolve('rocket')` → `Icons.rocket_launch_rounded`
- `resolve('\u{1F680}')` → `Icons.rocket_launch_rounded` (레거시 호환)
- `resolve('unknown')` → `Icons.help_outline_rounded`
- 모든 public ID 상수가 `_idToIcon` 키와 일치

**완료 조건:**
- 새 테스트 RED → GREEN
- `flutter analyze` clean
- 기존 호출부 (`spaceship_avatar.dart`, `spaceship_card.dart`, `spaceship_collection_screen.dart`) 가 여전히 정상 동작

### Phase 2 — Seed 데이터 마이그레이션

**순서:**
1. `badge_seed_data.dart` — 모든 `icon: '\u{...}'` → `icon: SpaceIcons.xxx`
2. `spaceship_data.dart` — 모든 `icon: '🚀'` → `icon: SpaceIcons.xxx`

**테스트:**
- Seed 데이터가 로드될 때 `SpaceIcons.resolve()` 가 `Icons.help_outline_rounded` 를 반환하지 않는지 (즉, 모든 icon 값이 매핑 테이블에 존재하는지) 검증

**완료 조건:**
- `flutter analyze` clean
- 기존 뱃지/우주선 리스트 화면이 정상 렌더

### Phase 3 — UI 위젯 이모지 리터럴 제거

**대상:**
- `badge_card.dart:123` — `Text('🔒')` → `Icon(SpaceIcons.resolve(SpaceIcons.lock))`
- `badge_detail_dialog.dart:34` — 동일 패턴

**주의:** `Text` 위젯의 이모지 그리기와 `Icon` 위젯은 시각적 크기·정렬·색상 처리가 다르므로, 교체 후 배지 화면을 **시각 확인** 필수.

**테스트:**
- `badge_card_test.dart` — 잠금 상태에서 lock 아이콘 렌더 확인 (Widget Test)
- `badge_detail_dialog_test.dart` — 동일

**완료 조건:**
- 새 Widget Test RED → GREEN
- 실제 디바이스/에뮬레이터에서 배지 화면 시각 확인
- `flutter-design-guardian` 에이전트 호출 → lib/features/badge/ grep 셀프체크 통과

### Phase 4 — 레거시 매핑 제거 & 최종 검증

**작업:**
- `space_icons.dart` 에서 `_legacyEmojiToId` 테이블 제거
- `resolve()` 메서드를 ID 전용으로 단순화

**최종 검증:**
1. `flutter analyze` — 경고 0개
2. `flutter test` — 전체 통과
3. `flutter-design-guardian` 에이전트 호출 → `lib/` 전체 grep 셀프체크
   - 예상 잔존: debugPrint 이모지·test_widget_page·주석·작은 장식 이모지
4. 앱 실행 → 배지 탭 / 우주선 컬렉션 / 홈 화면 / 탐험 화면 시각 확인
5. `.claude/scripts/check_design_violations.py` 훅이 신규 이모지 삽입을 차단하는지 재확인

---

## Commits

각 Phase 를 독립 커밋으로 분리 (롤백 단위):

1. `refactor : space_icons 레지스트리 String ID 방식으로 재설계 #68`
2. `refactor : 뱃지·우주선 seed 데이터 이모지 → String ID 교체 #68`
3. `refactor : 뱃지 위젯 이모지 리터럴 제거 #68`
4. `chore : space_icons 레거시 이모지 매핑 제거 #68`

---

## Test Plan

| 레벨 | 대상 | 검증 |
|------|------|------|
| Unit | `SpaceIcons.resolve()` | ID · 레거시 이모지 · 미매핑 → 각 기대값 |
| Unit | Seed 데이터 로드 | 모든 `icon` 값이 매핑 테이블에 존재 |
| Widget | `BadgeCard` 잠금 상태 | lock 아이콘 렌더 |
| Widget | `BadgeDetailDialog` 잠금 상태 | lock 아이콘 렌더 |
| 통합 | 앱 실행 | 배지 · 우주선 · 홈 · 탐험 시각 확인 |
| 훅 | `check_design_violations.py` | 신규 이모지 삽입 차단 |

---

## Risks

- **시각적 차이** — `Text('🔒')` → `Icon(Icons.lock_rounded)` 교체 시 크기·정렬·색상이 달라 보일 수 있음
  - **완화:** Phase 3 에서 시각 확인 필수, 필요 시 `Icon` 의 size·color 파라미터를 원래 Text 스타일에 맞춰 조정

- **레거시 데이터 호환** — 로컬 DB 에 이모지가 저장되어 있을 가능성
  - **완화:** Phase 1 의 `_legacyEmojiToId` 가 흡수. Phase 4 제거 전 "레거시 데이터가 남아있지 않은가" 확인 필요 (가능하면 마이그레이션 카운터 로그)

- **미매핑 이모지 발견** — 네이밍 테이블에 없는 이모지
  - **완화:** `Icons.help_outline_rounded` placeholder + TODO 코멘트, 이후 별도 작업

---

## Success Criteria

- [ ] `SpaceIcons` 가 String ID 방식으로 재설계됨
- [ ] `badge_seed_data.dart` 의 모든 `\u{...}` icon 값이 `SpaceIcons.xxx` 로 교체됨
- [ ] `spaceship_data.dart` 의 모든 이모지 icon 값이 `SpaceIcons.xxx` 로 교체됨
- [ ] `badge_card.dart` / `badge_detail_dialog.dart` 의 `'🔒'` 리터럴 제거됨
- [ ] `_legacyEmojiToId` 테이블 제거됨
- [ ] `flutter analyze` clean · `flutter test` 통과
- [ ] `flutter-design-guardian` 이 카테고리 1~3 영역에서 이모지를 발견하지 않음
- [ ] 실제 앱 실행 시 배지/우주선/홈/탐험 화면이 정상 렌더

## Open Questions

없음 (브레인스토밍 중 모든 결정 확정).
