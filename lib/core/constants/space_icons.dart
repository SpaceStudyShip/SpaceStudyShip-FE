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
          [AppColors.textTertiary, AppColors.spaceDivider];
    }
    return [AppColors.textTertiary, AppColors.spaceDivider];
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
