import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_filter.freezed.dart';

/// GET /api/timer-sessions 쿼리 파라미터 VO.
@freezed
class TimerSessionFilter with _$TimerSessionFilter {
  const factory TimerSessionFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? todoId,
    @Default(0) int page,
    @Default(20) int size,
  }) = _TimerSessionFilter;
}
