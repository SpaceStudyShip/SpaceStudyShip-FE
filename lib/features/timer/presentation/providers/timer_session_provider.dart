import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/timer_session_local_datasource.dart';
import '../../data/datasources/timer_session_remote_datasource.dart';
import '../../data/repositories/local_timer_session_repository_impl.dart';
import '../../data/repositories/timer_session_repository_impl.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/entities/timer_session_filter.dart';
import '../../domain/entities/timer_session_page.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../utils/timer_format_utils.dart';

part 'timer_session_provider.g.dart';

// === DataSources ===

@Riverpod(keepAlive: true)
TimerSessionLocalDataSource timerSessionLocalDataSource(Ref ref) {
  throw StateError('TimerSessionLocalDataSource 가 초기화되지 않았습니다.');
}

@Riverpod(keepAlive: true)
TimerSessionRemoteDataSource timerSessionRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return TimerSessionRemoteDataSource(dio);
}

// === Repository (auth branch) ===

@Riverpod(keepAlive: true)
TimerSessionRepository timerSessionRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (isAuthenticated) {
    return TimerSessionRepositoryImpl(
      remote: ref.watch(timerSessionRemoteDataSourceProvider),
      cache: ref.watch(timerSessionLocalDataSourceProvider),
    );
  }
  return LocalTimerSessionRepositoryImpl(
    ref.watch(timerSessionLocalDataSourceProvider),
  );
}

// === 세션 리스트 (게스트: 로컬 동기, 인증: 첫 페이지 비동기 로딩) ===

@riverpod
class TimerSessionListNotifier extends _$TimerSessionListNotifier {
  @override
  Future<List<TimerSessionEntity>> build() async {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final repository = ref.watch(timerSessionRepositoryProvider);

    if (isAuthenticated) {
      // 인증 모드: 첫 페이지만 로딩 (UI 무한 스크롤 시 timerSessionsPageProvider 사용).
      final page = await repository.getSessionsPage(const TimerSessionFilter());
      return page.items;
    }
    return repository.getSessions();
  }

  /// 게스트 모드 전용. 인증 모드에서 호출되면 안전망으로 invalidate 만 수행.
  Future<void> addSession(TimerSessionEntity session) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      ref.invalidateSelf();
      return;
    }
    final repository = ref.read(timerSessionRepositoryProvider);
    await repository.addSession(session);
    state = AsyncValue.data(repository.getSessions());
  }
}

// === 인증 모드 페이지 조회 (UI 무한 스크롤·필터용) ===

@riverpod
Future<TimerSessionPage> timerSessionsPage(
  Ref ref,
  TimerSessionFilter filter,
) async {
  final repository = ref.watch(timerSessionRepositoryProvider);
  return repository.getSessionsPage(filter);
}

// === 기록 화면 페이지네이션 (인증·게스트 통합) ===

/// 한 페이지에 표시할 세션 개수 (기록 화면 전용).
const int timerHistoryPageSize = 20;

/// 기록 화면용 페이지 조회.
/// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
/// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
@riverpod
Future<TimerSessionPage> timerHistoryPage(Ref ref, int page) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final repository = ref.watch(timerSessionRepositoryProvider);

  if (isAuthenticated) {
    return repository.getSessionsPage(
      TimerSessionFilter(page: page, size: timerHistoryPageSize),
    );
  }

  // 게스트: 로컬 전체 리스트를 직접 슬라이스해서 동일한 TimerSessionPage 모양으로 반환.
  final all = [...repository.getSessions()]
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  final total = all.length;
  final totalPages = total == 0 ? 0 : (total / timerHistoryPageSize).ceil();
  final start = page * timerHistoryPageSize;
  final end = (start + timerHistoryPageSize).clamp(0, total);
  final items = start >= total
      ? const <TimerSessionEntity>[]
      : all.sublist(start, end);

  return TimerSessionPage(
    items: items,
    page: page,
    size: timerHistoryPageSize,
    totalElements: total,
    totalPages: totalPages,
  );
}

// === 날짜별 그룹화 (페이지네이션용) ===

/// 날짜별 세션 그룹 (페이지네이션 아이템 단위)
class DateGroup {
  final DateTime date;
  final List<TimerSessionEntity> sessions;
  final int totalMinutes;

  DateGroup({required this.date, required this.sessions})
    : totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 세션을 날짜별로 그룹화 (최신순 정렬)
@riverpod
List<DateGroup> sortedDateGroups(Ref ref) {
  final sessions =
      ref.watch(timerSessionListNotifierProvider).valueOrNull ?? [];
  final grouped = <DateTime, List<TimerSessionEntity>>{};

  for (final session in sessions) {
    final date = normalizeDate(session.startedAt);
    grouped.putIfAbsent(date, () => []).add(session);
  }

  // 각 그룹 내부: 최신 시작 시간 순
  for (final list in grouped.values) {
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // 날짜 최신순 정렬
  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

  return sortedKeys
      .map((date) => DateGroup(date: date, sessions: grouped[date]!))
      .toList();
}
