# 별 반짝임 설정 토글 + SpaceBackground 통합

**Date:** 2026-03-04
**Status:** Approved

## 목표

1. 설정 화면에서 별 반짝임 효과를 토글(on/off)할 수 있게 한다 (기본값: on)
2. SpaceBackground와 SpaceMapBackground를 하나로 통합하여 코드 품질을 높인다

## 1. Settings Feature 구조 (Clean Architecture)

```
features/settings/
├── data/
│   ├── datasources/
│   │   └── settings_local_datasource.dart    # SharedPreferences 래퍼
│   └── repositories/
│       └── settings_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── app_settings_entity.dart          # Freezed
│   └── repositories/
│       └── settings_repository.dart          # 인터페이스
└── presentation/
    ├── providers/
    │   └── settings_provider.dart            # @riverpod AsyncNotifier
    └── screens/
        └── settings_screen.dart
```

### Entity

```dart
@freezed
class AppSettingsEntity with _$AppSettingsEntity {
  const factory AppSettingsEntity({
    @Default(true) bool starTwinkleEnabled,
  }) = _AppSettingsEntity;
}
```

### Provider Chain

```
SettingsLocalDataSource (SharedPreferences)
  → SettingsRepositoryImpl
    → SettingsProvider (@riverpod AsyncNotifier)
      → SpaceBackground (watch)
      → SettingsScreen (watch + toggle)
```

### SharedPreferences 키

```dart
static const _keyStarTwinkle = 'settings_star_twinkle_enabled';
```

`main.dart`에서 기존 패턴대로 `SettingsLocalDataSource`를 ProviderScope override로 주입.

## 2. SpaceBackground 통합

### 변경 사항

- SpaceBackground에 optional `height` 파라미터 추가 (null이면 SizedBox.expand)
- ConsumerStatefulWidget으로 변경 (settings Provider watch)
- starTwinkleEnabled=false → AnimationController.stop(), 별은 baseOpacity로 고정 (별 자체는 유지)
- starTwinkleEnabled=true → AnimationController.repeat(reverse: true)

### SpaceMapBackground 제거

- `features/exploration/presentation/widgets/space_map_background.dart` 삭제
- ExploreScreen에서 `SpaceBackground(height: ...)` 사용으로 변경
- SpaceBackground의 jittered grid 분포 로직 유지 (더 자연스러움)

## 3. 설정 화면 UI

- Scaffold + SpaceBackground (프로젝트 필수 패턴)
- ListView로 섹션 구성 (향후 확장 용이)
- 섹션: "화면 효과" → "별 반짝임 효과" Switch.adaptive 토글
- AppCard 안에 ListTile 스타일로 배치
- 모든 spacing/padding은 AppSpacing/AppPadding 사용
- 설명 텍스트: "배경의 별이 반짝입니다"

## 4. 라우터 변경

`app_router.dart`의 settings 라우트에서 PlaceholderScreen → SettingsScreen으로 교체.
