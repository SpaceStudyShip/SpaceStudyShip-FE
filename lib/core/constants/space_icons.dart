import 'package:flutter/material.dart';

/// 이모지 → Material Icon 매핑 레지스트리
///
/// Entity의 `String icon` 필드는 변경하지 않고,
/// UI 렌더링 시 이모지를 Material Icons으로 교체합니다.
///
/// **사용 예시**:
/// ```dart
/// // IconData 가져오기
/// final iconData = SpaceIcons.resolve('🚀');
///
/// // 위젯 직접 생성
/// SpaceIcons.buildIcon('🌍', size: 32, color: Colors.blue);
/// ```
class SpaceIcons {
  SpaceIcons._();

  // ============================================
  // 이모지 → IconData 매핑
  // ============================================

  static const Map<String, IconData> _emojiToIcon = {
    // 행성
    '🌍': Icons.public_rounded,
    '🌎': Icons.public_rounded,
    '🌏': Icons.public_rounded,
    '🌙': Icons.nightlight_round,
    '🔴': Icons.circle,
    '🟤': Icons.circle,
    '⭐': Icons.star_rounded,
    '🌟': Icons.auto_awesome_rounded,
    '☀️': Icons.wb_sunny_rounded,

    // 탈것
    '🚀': Icons.rocket_launch_rounded,
    '🛸': Icons.flight_rounded,
    '🛰️': Icons.satellite_alt_rounded,
    '🚁': Icons.flight_rounded,

    // 상태/아이템
    '⛽': Icons.local_gas_station_rounded,
    '🔥': Icons.local_fire_department_rounded,
    '🔒': Icons.lock_rounded,
    '✅': Icons.check_circle_rounded,
    '✨': Icons.auto_awesome,
    '🏆': Icons.emoji_events_rounded,

    // 사람
    '👨‍🚀': Icons.person_rounded,
    '🧑‍🚀': Icons.person_rounded,
    '👥': Icons.group_rounded,

    // 기타
    '📝': Icons.edit_note_rounded,
    '🏠': Icons.home_rounded,
    '🛠️': Icons.build_rounded,
    '🌌': Icons.blur_on_rounded,
  };

  // ============================================
  // 행성별 고유 색상 매핑
  // ============================================

  static const Map<String, Color> _planetColors = {
    '🌍': Color(0xFF4FC3F7), // Earth: blue-green
    '🌎': Color(0xFF4FC3F7),
    '🌏': Color(0xFF4FC3F7),
    '🌙': Color(0xFFB0BEC5), // Moon: silver
    '🔴': Color(0xFFEF5350), // Mars: red
    '🟤': Color(0xFFBCAAA4), // Jupiter: brown
    '⭐': Color(0xFFFFD740), // Star: gold
    '🌟': Color(0xFFFFD740),
    '☀️': Color(0xFFFFA726), // Sun: orange
    '🚀': Color(0xFF42A5F5), // Rocket: blue
    '🛸': Color(0xFFAB47BC), // UFO: purple
    '🛰️': Color(0xFF78909C), // Satellite: blue-grey
    '🚁': Color(0xFF66BB6A), // Shuttle: green
  };

  // ============================================
  // 행성별 그라데이션 매핑
  // ============================================

  static const Map<String, List<Color>> _planetGradients = {
    '🌍': [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    '🌎': [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    '🌏': [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    '🌙': [Color(0xFFCFD8DC), Color(0xFF78909C)],
    '🔴': [Color(0xFFEF5350), Color(0xFFC62828)],
    '🟤': [Color(0xFFD7CCC8), Color(0xFF8D6E63)],
    '⭐': [Color(0xFFFFD740), Color(0xFFFFA000)],
    '🌟': [Color(0xFFFFE57F), Color(0xFFFFAB00)],
    '☀️': [Color(0xFFFFCC02), Color(0xFFFF6F00)],
    '🚀': [Color(0xFF64B5F6), Color(0xFF1565C0)],
    '🛸': [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
    '🛰️': [Color(0xFFB0BEC5), Color(0xFF546E7A)],
    '🚁': [Color(0xFF81C784), Color(0xFF2E7D32)],
  };

  // ============================================
  // Public API
  // ============================================

  /// 이모지를 IconData로 변환 (매핑 없으면 기본 아이콘)
  static IconData resolve(String emoji) {
    return _emojiToIcon[emoji] ?? Icons.circle_outlined;
  }

  /// 이모지의 고유 색상 반환
  static Color colorOf(String emoji) {
    return _planetColors[emoji] ?? const Color(0xFF90A4AE);
  }

  /// 이모지의 그라데이션 색상 반환
  static List<Color> gradientOf(String emoji) {
    return _planetGradients[emoji] ??
        const [Color(0xFF90A4AE), Color(0xFF607D8B)];
  }

  /// 이모지를 그라데이션 원형 아이콘 위젯으로 변환
  static Widget buildIcon(
    String emoji, {
    double size = 24,
    Color? color,
    bool useGradient = true,
  }) {
    final iconData = resolve(emoji);
    final iconColor = color ?? colorOf(emoji);

    if (!useGradient) {
      return Icon(iconData, size: size, color: iconColor);
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientOf(emoji),
      ).createShader(bounds),
      child: Icon(iconData, size: size, color: Colors.white),
    );
  }

  /// 그라데이션 원형 배경 + 아이콘 위젯 (행성 노드용)
  static Widget buildCircleIcon(
    String emoji, {
    double circleSize = 56,
    double iconSize = 28,
    double glowOpacity = 0.0,
  }) {
    final gradient = gradientOf(emoji);
    final baseColor = colorOf(emoji);

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            gradient[0].withValues(alpha: 0.3),
            gradient[1].withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: baseColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: glowOpacity > 0
            ? [
                BoxShadow(
                  color: baseColor.withValues(alpha: glowOpacity),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ).createShader(bounds),
          child: Icon(resolve(emoji), size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}
