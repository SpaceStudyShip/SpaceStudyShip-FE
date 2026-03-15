import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 카테고리 행성 아이콘 매핑
///
/// 아이콘 ID(예: 'planet_1')와 SVG 에셋 경로를 매핑한다.
/// 백엔드 연동 시 이 ID를 API에서 주고받는다.
class CategoryIcons {
  CategoryIcons._();

  /// 사용 가능한 카테고리 아이콘 ID 목록
  static const List<String> presets = [
    'planet_1',
    'planet_2',
    'planet_3',
    'planet_4',
    'planet_5',
    'planet_6',
    'planet_7',
    'planet_8',
    'planet_9',
    'planet_10',
    'planet_11',
    'planet_12',
    'planet_13',
    'planet_14',
    'planet_15',
    'planet_16',
    'planet_17',
    'planet_18',
    'planet_19',
    'planet_20',
  ];

  /// 기본 아이콘 ID
  static const defaultIconId = 'planet_1';

  /// 아이콘 ID → SVG 에셋 경로
  static String assetPath(String? iconId) {
    final id = iconId ?? defaultIconId;
    final fileName = _assetNames[id] ?? _assetNames[defaultIconId]!;
    return 'assets/icons/categories/$fileName';
  }

  /// 아이콘 ID → SvgPicture 위젯
  static Widget buildIcon(String? iconId, {double? size}) {
    return SvgPicture.asset(
      assetPath(iconId),
      width: size,
      height: size,
    );
  }

  static const _assetNames = {
    'planet_1': 'Planet 1.svg',
    'planet_2': 'Planet 2.svg',
    'planet_3': 'Planet 3.svg',
    'planet_4': 'Planet 4.svg',
    'planet_5': 'Planet 5.svg',
    'planet_6': 'Planet 6.svg',
    'planet_7': 'Planet 7.svg',
    'planet_8': 'Planet 8.svg',
    'planet_9': 'Planet 9.svg',
    'planet_10': 'Planet 10.svg',
    'planet_11': 'Planet 11.svg',
    'planet_12': 'Planet 12.svg',
    'planet_13': 'Planet 13.svg',
    'planet_14': 'Planet 14.svg',
    'planet_15': 'Planet 15.svg',
    'planet_16': 'Planet 16.svg',
    'planet_17': 'Planet 17.svg',
    'planet_18': 'Planet 18.svg',
    'planet_19': 'Planet 19.svg',
    'planet_20': 'Planet 20.svg',
  };
}
