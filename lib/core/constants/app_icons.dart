import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 공용 SVG 아이콘
///
/// assets/icons/ 디렉토리의 공용 아이콘을 중앙 관리합니다.
/// SVG 자체에 색상이 포함되어 있으므로 colorFilter를 적용하지 않습니다.
class AppIcons {
  AppIcons._();

  static const _basePath = 'assets/icons';

  /// 메뉴/리스트 토글 아이콘
  static Widget menu({double? size}) =>
      SvgPicture.asset('$_basePath/Menu.svg', width: size, height: size);

  /// 추가(+) 아이콘
  static Widget plus({double? size}) =>
      SvgPicture.asset('$_basePath/Plus.svg', width: size, height: size);

  /// 설정 아이콘
  static Widget settings({double? size}) =>
      SvgPicture.asset('$_basePath/Settings.svg', width: size, height: size);
}
