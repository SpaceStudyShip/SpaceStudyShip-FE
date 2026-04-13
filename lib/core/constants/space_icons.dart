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
  // Public API
  // ============================================

  /// ID 로 IconData 반환. 매핑이 없으면 placeholder.
  static IconData resolve(String id) {
    return _idToIcon[id] ?? Icons.help_outline_rounded;
  }

  /// ID 로 고유 색상 반환.
  static Color colorOf(String id) {
    return _idToColor[id] ?? AppColors.textTertiary;
  }

  /// ID 로 그라데이션 2색 반환.
  static List<Color> gradientOf(String id) {
    return _idToGradient[id] ??
        [AppColors.textTertiary, AppColors.spaceDivider];
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
