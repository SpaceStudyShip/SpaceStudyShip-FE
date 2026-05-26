import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/timer_session_create_request_model.dart';
import '../models/timer_session_create_response_model.dart';
import '../models/timer_session_page_response_model.dart';
import '../models/today_stats_response_model.dart';

part 'timer_session_remote_datasource.g.dart';

/// Timer 백엔드 API 클라이언트.
@RestApi()
abstract class TimerSessionRemoteDataSource {
  factory TimerSessionRemoteDataSource(Dio dio) = _TimerSessionRemoteDataSource;

  /// POST /api/timer-sessions — 세션 저장 + 연료 자동 충전.
  @POST(ApiEndpoints.timerSessions)
  Future<TimerSessionCreateResponseModel> createSession({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required TimerSessionCreateRequestModel body,
  });

  /// GET /api/timer-sessions — 페이지네이션 조회.
  @GET(ApiEndpoints.timerSessions)
  Future<TimerSessionPageResponseModel> getSessions({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('todoId') String? todoId,
    @Query('page') int? page,
    @Query('size') int? size,
  });

  /// GET /api/timer-sessions/today-stats — 오늘 통계 (KST).
  @GET(ApiEndpoints.timerSessionsTodayStats)
  Future<TodayStatsResponseModel> getTodayStats();
}
