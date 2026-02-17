import '../entities/timer_session_entity.dart';

abstract class TimerSessionRepository {
  List<TimerSessionEntity> getSessions();
  Future<void> addSession(TimerSessionEntity session);
  Future<void> clearSessions();
}
