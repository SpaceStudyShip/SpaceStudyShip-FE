import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timer_session_create_result.dart';
import 'timer_session_response_model.dart';

part 'timer_session_create_response_model.freezed.dart';
part 'timer_session_create_response_model.g.dart';

/// POST /api/timer-sessions 응답 DTO.
@freezed
class TimerSessionCreateResponseModel with _$TimerSessionCreateResponseModel {
  const TimerSessionCreateResponseModel._();

  const factory TimerSessionCreateResponseModel({
    required TimerSessionResponseModel session,
    required int fuelCharged,
  }) = _TimerSessionCreateResponseModel;

  factory TimerSessionCreateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionCreateResponseModelFromJson(json);

  TimerSessionCreateResult toEntity() => TimerSessionCreateResult(
    session: session.toEntity(),
    fuelCharged: fuelCharged,
  );
}
