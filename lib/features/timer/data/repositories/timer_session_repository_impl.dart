import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/timer_session_create_result.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/entities/timer_session_filter.dart';
import '../../domain/entities/timer_session_page.dart';
import '../../domain/entities/today_stats.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../datasources/timer_session_local_datasource.dart';
import '../datasources/timer_session_remote_datasource.dart';
import '../models/timer_session_create_request_model.dart';

/// 서버 source-of-truth Timer 세션 Repository.
/// 게스트 전용 메서드(getSessions/addSession) 는 UnsupportedError 를 던진다.
class TimerSessionRepositoryImpl implements TimerSessionRepository {
  final TimerSessionRemoteDataSource remote;
  final TimerSessionLocalDataSource cache;

  TimerSessionRepositoryImpl({required this.remote, required this.cache});

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Future<TimerSessionCreateResult> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
    String? todoId,
    String? todoTitle,
    required String idempotencyKey,
  }) async {
    try {
      final response = await remote.createSession(
        idempotencyKey: idempotencyKey,
        body: TimerSessionCreateRequestModel(
          todoId: todoId,
          todoTitle: todoTitle,
          startedAt: startedAt,
          endedAt: endedAt,
          durationMinutes: durationMinutes,
        ),
      );
      return response.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TimerSessionPage> getSessionsPage(TimerSessionFilter filter) async {
    try {
      final response = await remote.getSessions(
        startDate: filter.startDate != null ? _dateFmt.format(filter.startDate!) : null,
        endDate:   filter.endDate   != null ? _dateFmt.format(filter.endDate!)   : null,
        todoId:    filter.todoId,
        page:      filter.page,
        size:      filter.size,
      );
      return response.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodayStats> getTodayStats() async {
    try {
      final response = await remote.getTodayStats();
      return response.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  List<TimerSessionEntity> getSessions() => throw UnsupportedError(
        'Server-backed repo does not support local getSessions(). '
        'Use getSessionsPage(filter) for paginated server reads.',
      );

  @override
  Future<void> addSession(TimerSessionEntity session) => throw UnsupportedError(
        'Server-backed repo persists via createSession(); '
        'addSession() is guest-only.',
      );

  @override
  Future<void> clearAll() async {
    await cache.clearAll();
  }
}
