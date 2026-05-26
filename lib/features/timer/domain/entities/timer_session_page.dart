import 'package:freezed_annotation/freezed_annotation.dart';

import 'timer_session_entity.dart';

part 'timer_session_page.freezed.dart';

@freezed
class TimerSessionPage with _$TimerSessionPage {
  const TimerSessionPage._();

  const factory TimerSessionPage({
    required List<TimerSessionEntity> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _TimerSessionPage;

  bool get hasNext => page < totalPages - 1;
}
