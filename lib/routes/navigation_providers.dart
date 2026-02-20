import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 탭 재탭 이벤트 카운터
///
/// MainShell에서 홈 탭 재탭 시 increment → HomeScreen에서 listen하여 시트 접기.
final homeReTapProvider = StateProvider<int>((ref) => 0);
