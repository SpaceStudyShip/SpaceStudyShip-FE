// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_create_request_model.freezed.dart';
part 'timer_session_create_request_model.g.dart';

/// POST /api/timer-sessions 요청 본문.
/// 서버는 camelCase 를 사용한다.
@freezed
class TimerSessionCreateRequestModel with _$TimerSessionCreateRequestModel {
  const factory TimerSessionCreateRequestModel({
    @JsonKey(includeIfNull: false) String? todoId,
    @JsonKey(includeIfNull: false) String? todoTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
  }) = _TimerSessionCreateRequestModel;

  factory TimerSessionCreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionCreateRequestModelFromJson(json);
}
