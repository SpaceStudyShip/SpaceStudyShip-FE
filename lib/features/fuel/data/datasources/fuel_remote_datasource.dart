import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/fuel_response_model.dart';
import '../models/fuel_transaction_page_response_model.dart';

part 'fuel_remote_datasource.g.dart';

/// Fuel 백엔드 API 클라이언트.
///
/// `api-docs.json` 의 Fuel 태그 2 엔드포인트 매핑.
@RestApi()
abstract class FuelRemoteDataSource {
  factory FuelRemoteDataSource(Dio dio) = _FuelRemoteDataSource;

  /// 연료 잔량 조회 — 200
  @GET(ApiEndpoints.fuel)
  Future<FuelResponseModel> getFuel();

  /// 거래 내역 페이지네이션 조회 — 200
  ///
  /// - type: 'charge' | 'consume' (선택)
  /// - startDate / endDate: YYYY-MM-DD (선택)
  /// - page: 기본 0
  /// - size: 기본 20, 최대 100
  @GET(ApiEndpoints.fuelTransactions)
  Future<FuelTransactionPageResponseModel> getTransactions({
    @Query('type') String? type,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('page') int? page,
    @Query('size') int? size,
  });
}
