# 별 반짝임 설정 토글 + SpaceBackground 통합 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 설정 화면에서 별 반짝임 효과를 토글하고, SpaceBackground/SpaceMapBackground를 하나로 통합한다.

**Architecture:** Clean 3-Layer (features/settings/) + Freezed Entity + Riverpod Generator. SpaceBackground를 ConsumerStatefulWidget으로 변경하여 settings provider를 watch.

**Tech Stack:** Flutter, Riverpod 2.6 (Generator), Freezed 2.5, SharedPreferences

---

### Task 1: AppSettingsEntity (Freezed)

**Files:**
- Create: `lib/features/settings/domain/entities/app_settings_entity.dart`

**Step 1: Create entity file**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings_entity.freezed.dart';

@freezed
class AppSettingsEntity with _$AppSettingsEntity {
  const factory AppSettingsEntity({
    @Default(true) bool starTwinkleEnabled,
  }) = _AppSettingsEntity;
}
```

**Step 2: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `app_settings_entity.freezed.dart` generated

**Step 3: Commit**

```
feat : AppSettingsEntity Freezed 엔티티 생성
```

---

### Task 2: SettingsRepository 인터페이스

**Files:**
- Create: `lib/features/settings/domain/repositories/settings_repository.dart`

**Step 1: Create repository interface**

```dart
import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  AppSettingsEntity getSettings();
  Future<void> setStarTwinkleEnabled({required bool enabled});
}
```

**Step 2: Commit**

```
feat : SettingsRepository 인터페이스 정의
```

---

### Task 3: SettingsLocalDataSource

**Files:**
- Create: `lib/features/settings/data/datasources/settings_local_datasource.dart`

**Step 1: Create datasource**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  static const _keyStarTwinkle = 'settings_star_twinkle_enabled';

  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  bool getStarTwinkleEnabled() {
    return _prefs.getBool(_keyStarTwinkle) ?? true;
  }

  Future<void> setStarTwinkleEnabled({required bool enabled}) async {
    await _prefs.setBool(_keyStarTwinkle, enabled);
  }
}
```

**Step 2: Commit**

```
feat : SettingsLocalDataSource SharedPreferences 래퍼 생성
```

---

### Task 4: SettingsRepositoryImpl

**Files:**
- Create: `lib/features/settings/data/repositories/settings_repository_impl.dart`

**Step 1: Create repository implementation**

```dart
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  AppSettingsEntity getSettings() {
    return AppSettingsEntity(
      starTwinkleEnabled: _dataSource.getStarTwinkleEnabled(),
    );
  }

  @override
  Future<void> setStarTwinkleEnabled({required bool enabled}) async {
    await _dataSource.setStarTwinkleEnabled(enabled: enabled);
  }
}
```

**Step 2: Commit**

```
feat : SettingsRepositoryImpl 구현체 생성
```

---

### Task 5: SettingsProvider (@riverpod)

**Files:**
- Create: `lib/features/settings/presentation/providers/settings_provider.dart`

**Step 1: Create provider file**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_provider.g.dart';

// === DataSource & Repository ===

@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  throw StateError(
    'SettingsLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}

// === Settings 상태 관리 ===

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettingsEntity build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getSettings();
  }

  Future<void> toggleStarTwinkle() async {
    final repository = ref.read(settingsRepositoryProvider);
    final newValue = !state.starTwinkleEnabled;
    await repository.setStarTwinkleEnabled(enabled: newValue);
    state = state.copyWith(starTwinkleEnabled: newValue);
  }
}

// === 편의 Provider (SpaceBackground에서 사용) ===

@riverpod
bool starTwinkleEnabled(Ref ref) {
  return ref.watch(
    settingsNotifierProvider.select((s) => s.starTwinkleEnabled),
  );
}
```

**Step 2: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `settings_provider.g.dart` generated

**Step 3: Commit**

```
feat : SettingsProvider Riverpod 상태 관리 생성
```

---

### Task 6: main.dart에 SettingsLocalDataSource 주입

**Files:**
- Modify: `lib/main.dart`

**Step 1: Add imports** (line 28 부근, 기존 import 블록에 추가)

```dart
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
```

**Step 2: Add override** (ProviderScope overrides 배열에 추가, line 210 부근 badgeLocalDataSource 다음)

```dart
        if (prefs != null)
          settingsLocalDataSourceProvider.overrideWithValue(
            SettingsLocalDataSource(prefs),
          ),
```

**Step 3: Commit**

```
feat : main.dart에 SettingsLocalDataSource ProviderScope 주입
```

---

### Task 7: SpaceBackground 통합 (height + twinkle 제어)

**Files:**
- Modify: `lib/core/widgets/backgrounds/space_background.dart`

**Step 1: ConsumerStatefulWidget으로 변경 + height 파라미터 추가**

SpaceBackground 클래스 전체를 다음으로 교체:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';

/// 우주 별 배경 위젯 (화면 전체용 + 맵용)
///
/// 랜덤 배치된 별들이 반짝이는 우주 배경을 표현합니다.
/// [height]가 null이면 SizedBox.expand으로 화면 전체를 채우고,
/// 값이 있으면 해당 높이로 렌더링합니다 (ExploreScreen 스크롤 맵용).
/// Settings의 starTwinkleEnabled에 따라 반짝임을 on/off합니다.
class SpaceBackground extends ConsumerStatefulWidget {
  const SpaceBackground({super.key, this.height});

  /// 맵 전체 높이 (null이면 SizedBox.expand)
  final double? height;

  @override
  ConsumerState<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends ConsumerState<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  static const _starTintColors = [
    AppColors.primaryLight, // blue
    AppColors.secondaryLight, // purple
    AppColors.accentGoldLight, // gold
    AppColors.accentPinkLight, // pink
    Color(0xFF4DD0E1), // cyan - no AppColors match
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final random = Random(42); // 고정 시드로 일관된 별 배치

    // Jittered grid: 화면을 구역으로 나눠 골고루 분포시킴
    const cols = 7;
    const rows = 8;
    const totalStars = 50;

    _stars = List.generate(totalStars, (i) {
      final double x;
      final double y;

      if (i < cols * rows) {
        // 그리드 기반 jittered 배치 (균일 분포)
        final col = i % cols;
        final row = i ~/ cols;
        x = (col + 0.15 + random.nextDouble() * 0.7) / cols;
        y = (row + 0.15 + random.nextDouble() * 0.7) / rows;
      } else {
        // 나머지는 순수 랜덤 (자연스러운 불규칙성)
        x = random.nextDouble();
        y = random.nextDouble();
      }

      // 크기: 지수 분포 → 작은 별이 많고 큰 별은 드물게 (실제 밤하늘)
      final sizeRoll = random.nextDouble();
      final size = sizeRoll < 0.6
          ? 0.3 + random.nextDouble() * 0.5 // 60%: 아주 작은 별 (0.3~0.8)
          : sizeRoll < 0.85
          ? 0.8 + random.nextDouble() * 0.8 // 25%: 중간 별 (0.8~1.6)
          : 1.6 + random.nextDouble() * 1.0; // 15%: 큰 별 (1.6~2.6)

      // 틴트: 큰 별일수록 색상 가질 확률 높음
      final hasTint = size > 1.0 && random.nextDouble() < 0.4;
      final tintColor = hasTint
          ? _starTintColors[random.nextInt(_starTintColors.length)]
          : null;

      // 반짝임: 큰 별 + 일부 중간 별 (총 ~12개)
      final twinkle = size > 1.4 || (size > 0.8 && random.nextDouble() < 0.15);

      return _Star(
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
        size: size,
        twinkle: twinkle,
        twinkleOffset: random.nextDouble(),
        baseOpacity: 0.3 + random.nextDouble() * 0.4, // 별마다 기본 밝기 다르게
        tintColor: tintColor,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TickerMode가 false면 탭이 비활성 → 애니메이션 정지
    if (TickerMode.of(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final twinkleEnabled = ref.watch(starTwinkleEnabledProvider);

    // 반짝임 설정에 따라 애니메이션 제어
    if (twinkleEnabled && TickerMode.of(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (!twinkleEnabled) {
      _controller.stop();
    }

    final content = Stack(
      children: [
        // Layer 1: 네뷸라 오버레이
        Positioned.fill(
          child: CustomPaint(
            size: widget.height != null
                ? Size(double.infinity, widget.height!)
                : Size.zero,
            painter: _NebulaPainter(),
          ),
        ),

        // Layer 2: 별 필드
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: widget.height != null
                    ? Size(double.infinity, widget.height!)
                    : Size.zero,
                painter: _StarPainter(
                  stars: _stars,
                  twinkleValue: twinkleEnabled ? _controller.value : 0.0,
                  twinkleEnabled: twinkleEnabled,
                ),
              );
            },
          ),
        ),
      ],
    );

    return RepaintBoundary(
      child: widget.height != null
          ? SizedBox(
              width: double.infinity,
              height: widget.height,
              child: content,
            )
          : SizedBox.expand(child: content),
    );
  }
}
```

**Step 2: _StarPainter에 twinkleEnabled 파라미터 추가**

```dart
class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.stars,
    required this.twinkleValue,
    required this.twinkleEnabled,
  });

  final List<_Star> stars;
  final double twinkleValue;
  final bool twinkleEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      double opacity;
      if (star.twinkle && twinkleEnabled) {
        final phase = (twinkleValue + star.twinkleOffset) % 1.0;
        opacity =
            star.baseOpacity +
            (1.0 - star.baseOpacity) * (0.5 + 0.5 * sin(phase * pi * 2));
      } else {
        opacity = star.baseOpacity;
      }

      final baseColor = star.tintColor ?? Colors.white;
      final center = Offset(star.x * size.width, star.y * size.height);

      // 틴트된 별은 미세한 glow 추가
      if (star.tintColor != null && star.size > 1.0) {
        final glowPaint = Paint()
          ..color = star.tintColor!.withValues(alpha: opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(center, star.size * 2.5, glowPaint);
      }

      final paint = Paint()
        ..color = baseColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) {
    return oldDelegate.twinkleValue != twinkleValue ||
        oldDelegate.twinkleEnabled != twinkleEnabled;
  }
}
```

_Star 클래스와 _NebulaPainter 클래스는 기존 그대로 유지.

**Step 3: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```
feat : SpaceBackground에 height 파라미터 + 반짝임 설정 연동 추가
```

---

### Task 8: SpaceMapBackground 삭제 + ExploreScreen 마이그레이션

**Files:**
- Delete: `lib/features/exploration/presentation/widgets/space_map_background.dart`
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`

**Step 1: ExploreScreen 수정**

import 변경:
```dart
// 삭제:
import '../../../exploration/presentation/widgets/space_map_background.dart';
// 추가:
import '../../../../core/widgets/backgrounds/space_background.dart';
```

사용 부분 변경:
```dart
// 변경 전:
Positioned.fill(child: SpaceMapBackground(height: mapHeight)),
// 변경 후:
Positioned.fill(child: SpaceBackground(height: mapHeight)),
```

**Step 2: SpaceMapBackground 파일 삭제**

Run: `rm lib/features/exploration/presentation/widgets/space_map_background.dart`

**Step 3: 다른 곳에서 SpaceMapBackground 참조 없는지 확인**

Run: `grep -r "SpaceMapBackground" lib/`
Expected: No matches

**Step 4: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 5: Commit**

```
refactor : SpaceMapBackground 삭제, ExploreScreen을 SpaceBackground로 통합
```

---

### Task 9: SettingsScreen UI 생성

**Files:**
- Create: `lib/features/settings/presentation/screens/settings_screen.dart`

**Step 1: Create settings screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '설정',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: ListView(
              padding: AppPadding.all20,
              children: [
                // 섹션 헤더: 화면 효과
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.s4,
                    bottom: AppSpacing.s12,
                  ),
                  child: Text(
                    '화면 효과',
                    style: AppTextStyles.label_12.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                // 별 반짝임 토글
                AppCard(
                  style: AppCardStyle.outlined,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '별 반짝임 효과',
                              style: AppTextStyles.subHeading_18.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s4),
                            Text(
                              '배경의 별이 반짝입니다',
                              style: AppTextStyles.paragraph_14.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.starTwinkleEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (_) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .toggleStarTwinkle();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```
feat : SettingsScreen UI 생성 (별 반짝임 토글)
```

---

### Task 10: app_router.dart 라우트 교체

**Files:**
- Modify: `lib/routes/app_router.dart`

**Step 1: import 추가**

```dart
import '../features/settings/presentation/screens/settings_screen.dart';
```

**Step 2: settings 라우트 변경** (line 322-327)

```dart
// 변경 전:
builder: (context, state) =>
    const PlaceholderScreen(title: '설정'),
// 변경 후:
builder: (context, state) => const SettingsScreen(),
```

**Step 3: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```
feat : settings 라우트를 SettingsScreen으로 교체
```

---

### Task 11: 최종 검증

**Step 1: 전체 분석**

Run: `flutter analyze`
Expected: No issues

**Step 2: 빌드 확인**

Run: `flutter build apk --debug 2>&1 | tail -5`
Expected: BUILD SUCCESSFUL

**Step 3: 커밋 로그 확인**

Run: `git log --oneline -10`
Expected: Task 1~10 커밋이 순서대로 나열
