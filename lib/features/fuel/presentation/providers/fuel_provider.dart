import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/fuel_local_datasource.dart';
import '../../data/datasources/fuel_remote_datasource.dart';
import '../../data/repositories/fuel_repository_impl.dart';
import '../../data/repositories/local_fuel_repository_impl.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/entities/fuel_transaction_filter.dart';
import '../../domain/entities/fuel_transaction_page.dart';
import '../../domain/repositories/fuel_repository.dart';

part 'fuel_provider.g.dart';

// === DataSource ===

@Riverpod(keepAlive: true)
FuelLocalDataSource fuelLocalDataSource(Ref ref) {
  throw StateError(
    'FuelLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@Riverpod(keepAlive: true)
FuelRemoteDataSource fuelRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FuelRemoteDataSource(dio);
}

// === Repository 분기 ===

@Riverpod(keepAlive: true)
FuelRepository fuelRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (isAuthenticated) {
    return FuelRepositoryImpl(
      remote: ref.watch(fuelRemoteDataSourceProvider),
      cache: ref.watch(fuelLocalDataSourceProvider),
    );
  }
  return LocalFuelRepositoryImpl(ref.watch(fuelLocalDataSourceProvider));
}

// === Fuel State (async) ===

@Riverpod(keepAlive: true)
class FuelNotifier extends _$FuelNotifier {
  @override
  Future<FuelEntity> build() async {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getFuel();
  }

  /// 공부 시간으로 연료 충전. server-backed 사용자는 도메인 액션 API 가
  /// 서버 쪽에서 잔량을 변동시키므로, 본 메서드는 잔량 재조회만 수행한다.
  Future<void> chargeFuel({
    required int studyMinutes,
    String? sessionId,
  }) async {
    if (studyMinutes <= 0) return;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      // Notifier 레벨 분기 흡수: 서버 mutation 은 timer/exploration 도메인
      // 액션 API 가 담당. 본 메서드는 재조회로 동기화.
      ref.invalidateSelf();
      ref.invalidate(fuelTransactionListNotifierProvider);
      return;
    }

    // 게스트: 기존 로컬 mutation 그대로. build() 완료 전이면 future 를 await.
    final current = state.valueOrNull ?? await future;
    final totalMinutes = current.pendingMinutes + studyMinutes;
    final amount = totalMinutes ~/ 30;
    final newPendingMinutes = totalMinutes % 30;
    final repository = ref.read(fuelRepositoryProvider);
    final updated = await repository.chargeFuel(
      amount,
      newPendingMinutes,
      FuelTransactionReason.studySession,
      sessionId,
    );
    state = AsyncValue.data(updated);
    if (amount > 0) {
      ref.invalidate(fuelTransactionListNotifierProvider);
    }
  }

  /// 탐험 해금 등으로 연료 소비. server-backed 는 재조회만.
  Future<void> consumeFuel({required int amount, String? nodeId}) async {
    if (amount <= 0) return;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      ref.invalidateSelf();
      ref.invalidate(fuelTransactionListNotifierProvider);
      return;
    }

    // build() 완료 전이면 future 를 await 하여 초기 상태 확보
    await future;
    final repository = ref.read(fuelRepositoryProvider);
    final updated = await repository.consumeFuel(
      amount,
      FuelTransactionReason.explorationUnlock,
      nodeId,
    );
    state = AsyncValue.data(updated);
    ref.invalidate(fuelTransactionListNotifierProvider);
  }
}

// === Transaction History (게스트 전용 단순 목록) ===

@riverpod
class FuelTransactionListNotifier extends _$FuelTransactionListNotifier {
  @override
  Future<List<FuelTransactionEntity>> build() async {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) {
      // server-backed 는 페이지 API 만 지원 → 단순 목록은 빈 결과.
      // 후속 거래 내역 UI 에서 fuelTransactionsPageProvider 사용.
      return [];
    }
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getTransactions();
  }
}

// === Server-backed 거래 내역 페이지 ===

@riverpod
Future<FuelTransactionPage> fuelTransactionsPage(
  Ref ref,
  FuelTransactionFilter filter,
) async {
  final repository = ref.watch(fuelRepositoryProvider);
  return repository.getTransactionsPage(filter);
}

// === Convenience ===

@riverpod
AsyncValue<int> currentFuel(Ref ref) {
  return ref.watch(fuelNotifierProvider).whenData((fuel) => fuel.currentFuel);
}
