import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 탭 재탭 이벤트 카운터
///
/// MainShell에서 홈 탭 재탭 시 increment → HomeScreen에서 listen하여 시트 접기.
final homeReTapProvider = StateProvider<int>((ref) => 0);

/// 플로팅 네비게이션 바 표시 여부
///
/// 특정 화면(예: 행성 상세)에서 네비 바를 숨기고 싶을 때 false로 설정.
final isFloatingNavVisibleProvider = StateProvider<bool>((ref) => true);
