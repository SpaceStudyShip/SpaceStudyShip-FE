import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timer_session_page.dart';
import 'timer_session_response_model.dart';

part 'timer_session_page_response_model.freezed.dart';
part 'timer_session_page_response_model.g.dart';

@freezed
class TimerSessionPageResponseModel with _$TimerSessionPageResponseModel {
  const TimerSessionPageResponseModel._();

  const factory TimerSessionPageResponseModel({
    required List<TimerSessionResponseModel> content,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _TimerSessionPageResponseModel;

  factory TimerSessionPageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionPageResponseModelFromJson(json);

  TimerSessionPage toEntity() => TimerSessionPage(
    items: content.map((m) => m.toEntity()).toList(),
    page: page,
    size: size,
    totalElements: totalElements,
    totalPages: totalPages,
  );
}
