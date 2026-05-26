// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_create_request_model.freezed.dart';
part 'timer_session_create_request_model.g.dart';

/// 서버(Jackson Instant) 가 요구하는 UTC ISO-8601 (`Z` 접미사) 로 직렬화.
/// local DateTime 입력도 안전하게 UTC 로 정규화한다.
String _toUtcIso(DateTime dt) => dt.toUtc().toIso8601String();

/// POST /api/timer-sessions 요청 본문.
/// 서버는 camelCase 를 사용한다.
@freezed
class TimerSessionCreateRequestModel with _$TimerSessionCreateRequestModel {
  const factory TimerSessionCreateRequestModel({
    @JsonKey(includeIfNull: false) String? todoId,
    @JsonKey(includeIfNull: false) String? todoTitle,
    @JsonKey(toJson: _toUtcIso) required DateTime startedAt,
    @JsonKey(toJson: _toUtcIso) required DateTime endedAt,
    required int durationMinutes,
  }) = _TimerSessionCreateRequestModel;

  factory TimerSessionCreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionCreateRequestModelFromJson(json);
}
