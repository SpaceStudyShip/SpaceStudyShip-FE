import 'package:freezed_annotation/freezed_annotation.dart';

import 'fuel_transaction_entity.dart';

part 'fuel_transaction_page.freezed.dart';

/// 거래 내역 페이지 응답 도메인 모델.
///
/// 페이지네이션 메타 (`page`, `size`, `totalElements`, `totalPages`) +
/// 현재 페이지 항목 (`items`) 을 포함한다.
@freezed
class FuelTransactionPage with _$FuelTransactionPage {
  const FuelTransactionPage._();

  const factory FuelTransactionPage({
    required List<FuelTransactionEntity> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _FuelTransactionPage;

  /// 다음 페이지가 더 있는지 여부 (`page + 1 < totalPages`)
  bool get hasNext => page + 1 < totalPages;
}
