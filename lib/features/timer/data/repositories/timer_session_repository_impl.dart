import '../../domain/entities/timer_session_entity.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../datasources/timer_session_local_datasource.dart';
import '../models/timer_session_model.dart';

class TimerSessionRepositoryImpl implements TimerSessionRepository {
  final TimerSessionLocalDataSource _localDataSource;

  TimerSessionRepositoryImpl(this._localDataSource);

  @override
  List<TimerSessionEntity> getSessions() {
    return _localDataSource.getSessions().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addSession(TimerSessionEntity session) async {
    await _localDataSource.addSession(session.toModel());
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
