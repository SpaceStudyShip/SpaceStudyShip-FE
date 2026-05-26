import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timer_session_entity.dart';

part 'timer_session_response_model.freezed.dart';
part 'timer_session_response_model.g.dart';

/// 서버 응답의 단건 세션 DTO (camelCase).
/// 기존 [timer_session_model.dart] 는 게스트 SharedPreferences 호환용 snake_case 이므로 분리한다.
@freezed
class TimerSessionResponseModel with _$TimerSessionResponseModel {
  const TimerSessionResponseModel._();

  const factory TimerSessionResponseModel({
    required String id,
    String? todoId,
    String? todoTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
  }) = _TimerSessionResponseModel;

  factory TimerSessionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionResponseModelFromJson(json);

  TimerSessionEntity toEntity() => TimerSessionEntity(
    id: id,
    todoId: todoId,
    todoTitle: todoTitle,
    startedAt: startedAt,
    endedAt: endedAt,
    durationMinutes: durationMinutes,
  );
}
