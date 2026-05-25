import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';
import '../entities/fuel_transaction_filter.dart';
import '../entities/fuel_transaction_page.dart';

abstract class FuelRepository {
  /// 현재 연료 잔량 조회. server-backed 구현은 네트워크 호출 + 캐시 폴백.
  Future<FuelEntity> getFuel();

  /// 연료 충전. server-backed 구현은 UnsupportedError 를 던진다 — 서버 변동은
  /// 도메인 액션 (타이머/탐험) 의 부수효과이며, Notifier 레벨에서 분기 흡수한다.
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);

  /// 연료 소비. server-backed 구현은 UnsupportedError 를 던진다.
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);

  /// 거래 내역 전체 조회 (게스트 전용). server-backed 는
  /// UnsupportedError — 페이지 API ([getTransactionsPage]) 를 사용한다.
  Future<List<FuelTransactionEntity>> getTransactions({int? limit});

  /// 거래 내역 페이지 조회 (server-backed 전용). LocalRepository 는
  /// UnsupportedError 를 던진다.
  Future<FuelTransactionPage> getTransactionsPage(
    FuelTransactionFilter filter,
  );

  /// 로컬 캐시 / 영속 데이터 전체 삭제 (로그아웃·탈퇴 흐름에서 호출).
  Future<void> clearAll();
}
