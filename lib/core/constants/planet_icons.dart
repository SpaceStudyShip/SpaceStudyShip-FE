import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 탐험 행성 SVG 아이콘 매핑
///
/// 행성 ID(예: 'earth')와 SVG 에셋 경로를 매핑한다.
/// 행성별 고유 색상/그라데이션도 제공한다.
class PlanetIcons {
  PlanetIcons._();

  /// 행성 ID → SVG 에셋 파일명
  static const _assetNames = {
    'mercury': 'Mercury.svg',
    'venus': 'Venus.svg',
    'earth': 'Earth.svg',
    'mars': 'Mars.svg',
    'jupiter': 'Jupiter.svg',
    'saturn': 'Saturn.svg',
    'uranus': 'Uranus.svg',
    'neptune': 'Neptune.svg',
  };

  /// 행성별 대표 색상 (border, glow 등에 사용)
  static const Map<String, Color> _colors = {
    'mercury': Color(0xFFB0BEC5),
    'venus': Color(0xFFFFB74D),
    'earth': Color(0xFF4FC3F7),
    'mars': Color(0xFFEF5350),
    'jupiter': Color(0xFFBCAAA4),
    'saturn': Color(0xFFFFD54F),
    'uranus': Color(0xFF80DEEA),
    'neptune': Color(0xFF5C6BC0),
  };

  static const _fallbackColor = Color(0xFF90A4AE);

  /// 행성 ID → SVG 에셋 경로
  static String assetPath(String planetId) {
    final fileName = _assetNames[planetId] ?? _assetNames['earth']!;
    return 'assets/icons/planets/$fileName';
  }

  /// 행성 ID → SvgPicture 위젯
  static Widget buildIcon(String planetId, {double? size}) {
    return SvgPicture.asset(assetPath(planetId), width: size, height: size);
  }

  /// 행성 대표 색상
  static Color colorOf(String planetId) {
    return _colors[planetId] ?? _fallbackColor;
  }
}
