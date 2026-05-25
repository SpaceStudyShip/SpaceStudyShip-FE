import 'package:freezed_annotation/freezed_annotation.dart';

import 'timer_session_entity.dart';

part 'timer_session_create_result.freezed.dart';

/// POST /api/timer-sessions 응답의 도메인 모델.
/// 서버가 검증 후 저장한 세션 + 자동 충전된 연료량.
@freezed
class TimerSessionCreateResult with _$TimerSessionCreateResult {
  const factory TimerSessionCreateResult({
    required TimerSessionEntity session,
    required int fuelCharged,
  }) = _TimerSessionCreateResult;
}
