import 'package:flutter/material.dart';
import '../../constants/text_styles.dart';

import '../../constants/app_colors.dart';

/// 타이머 디스플레이 크기
enum TimerDisplaySize {
  /// 작은 크기 (24sp) - 리스트 아이템용
  small,

  /// 중간 크기 (32sp) - 서브 타이머
  medium,

  /// 큰 크기 (48sp) - 메인 타이머
  large,

  /// 초대형 (64sp) - 집중 화면
  xlarge,
}

/// 타이머 디스플레이 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// TimerDisplay(
///   duration: Duration(hours: 0, minutes: 45, seconds: 32),
///   size: TimerDisplaySize.large,
///   isRunning: true,
/// )
/// ```
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.duration,
    this.size = TimerDisplaySize.large,
    this.isRunning = false,
    this.showMilliseconds = false,
    this.color,
  });

  /// 표시할 시간
  final Duration duration;

  /// 크기
  final TimerDisplaySize size;

  /// 실행 중 여부 (색상 결정)
  final bool isRunning;

  /// 밀리초 표시 여부
  final bool showMilliseconds;

  /// 커스텀 색상
  final Color? color;

  String get _formattedTime {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (showMilliseconds) {
      final milliseconds = duration.inMilliseconds.remainder(1000) ~/ 10;
      return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}.${_twoDigits(milliseconds)}';
    }

    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  TextStyle get _textStyle {
    switch (size) {
      case TimerDisplaySize.small:
        return AppTextStyles.timer_24;
      case TimerDisplaySize.medium:
        return AppTextStyles.timer_32;
      case TimerDisplaySize.large:
        return AppTextStyles.timer_48;
      case TimerDisplaySize.xlarge:
        return AppTextStyles.timer_64;
    }
  }

  Color get _textColor {
    if (color != null) return color!;
    if (isRunning) return AppColors.timerRunning;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formattedTime, style: _textStyle.copyWith(color: _textColor));
  }
}
