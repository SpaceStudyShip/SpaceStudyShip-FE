import 'package:freezed_annotation/freezed_annotation.dart';

import 'fuel_transaction_entity.dart';

part 'fuel_transaction_filter.freezed.dart';

/// 거래 내역 페이지 조회 필터.
///
/// - [type] null → 전체
/// - [startDate] / [endDate] null → 전체 기간 (서버 default)
/// - [page] / [size] 기본값은 서버 default 와 동일 (0 / 20)
@freezed
class FuelTransactionFilter with _$FuelTransactionFilter {
  const factory FuelTransactionFilter({
    FuelTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    @Default(0) int page,
    @Default(20) int size,
  }) = _FuelTransactionFilter;
}
