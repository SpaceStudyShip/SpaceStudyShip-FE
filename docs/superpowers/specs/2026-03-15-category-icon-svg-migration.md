# 카테고리 아이콘 SVG 전환 설계

## 목표

카테고리 아이콘을 이모지 문자열에서 SVG 행성 아이콘으로 교체하고, 백엔드 연동 시 아이콘 ID 매핑이 가능하도록 확장성을 확보한다.

## 배경

- 앱 미배포, 백엔드 미연결 → 기존 데이터 마이그레이션 불필요
- SVG 에셋: `assets/icons/categories/Planet 1.svg` ~ `Planet 20.svg` (20개)
- 기존: `_emojiPresets` 이모지 리스트 + Entity/Model의 `String? emoji` 필드

## 설계

### 1. CategoryIcons 상수 클래스

**파일:** `lib/core/constants/category_icons.dart`

- `presets`: `List<String>` — `['planet_1', 'planet_2', ..., 'planet_20']`
- `defaultIconId`: `'planet_1'`
- `assetPath(String iconId)`: 아이콘 ID → SVG 에셋 경로 변환
- 내부 `_assetNames` Map으로 ID ↔ 파일명 매핑 (파일명에 공백 포함이라 규칙 변환보다 안전)

### 2. Entity/Model 필드 리네이밍

| 레이어 | 파일 | 변경 |
|--------|------|------|
| Domain | `todo_category_entity.dart` | `emoji` → `iconId` (String?) |
| Data | `todo_category_model.dart` | `emoji` → `iconId` + `@JsonKey(name: 'icon_id')` |
| Data | `todo_category_model.dart` ext | `toEntity()`/`toModel()` 매핑 변경 |

### 3. Repository / UseCase / Provider 파라미터 변경

| 파일 | 변경 |
|------|------|
| `todo_repository.dart` | `String? emoji` → `String? iconId` |
| `create_category_usecase.dart` | `emoji` → `iconId` |
| `update_category_usecase.dart` | `emoji` → `iconId` |
| `todo_provider.dart` | `addCategory()` 등 파라미터 변경 |

### 4. UI 변경

| 파일 | 변경 내용 |
|------|----------|
| `category_icons.dart` | 신규 생성 — 매핑 상수 |
| `category_add_bottom_sheet.dart` | `_emojiPresets` → `CategoryIcons.presets`, Text → SvgPicture, record 타입 `emoji` → `iconId` |
| `category_card.dart` | `emoji` param → `iconId`, Text → SvgPicture |
| `category_select_bottom_sheet.dart` | emoji 참조 → iconId + SVG |
| `todo_add_bottom_sheet.dart` | `_CategoryChip` API 변경 — iconId + name 분리, leading SVG 아이콘 |
| `todo_select_bottom_sheet.dart` | emoji 참조 → iconId |
| `todo_list_screen.dart` | CategoryCard/라우터에 iconId 전달 |
| `category_todo_screen.dart` | `categoryEmoji` → `categoryIconId`, AppBar SVG 표시 |
| `app_router.dart` | extra `'emoji'` → `'iconId'` |

### 5. 미분류 기본 아이콘

기존 `'📁'` 폴백 → `CategoryIcons.defaultIconId` (`'planet_1'`) 사용

## 구현 순서

1. `CategoryIcons` 상수 클래스 생성
2. Entity `emoji` → `iconId`
3. Model `emoji` → `iconId` + `@JsonKey(name: 'icon_id')`
4. Repository / UseCase / Provider 파라미터명 변경
5. `build_runner` 실행 (freezed + json_serializable 재생성)
6. UI 위젯 일괄 변경
7. `flutter analyze` 확인

## 제외 사항

- 기존 데이터 마이그레이션 (앱 미배포)
- SpaceIcons 클래스 변경 (카테고리와 독립적)
