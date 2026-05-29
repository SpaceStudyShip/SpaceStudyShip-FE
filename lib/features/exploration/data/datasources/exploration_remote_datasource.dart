import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/planet_response_model.dart';
import '../models/region_response_model.dart';
import '../models/unlock_response_models.dart';

part 'exploration_remote_datasource.g.dart';

/// Exploration 백엔드 API 클라이언트 (api-docs.json Exploration 태그 4 엔드포인트).
@RestApi()
abstract class ExplorationRemoteDataSource {
  factory ExplorationRemoteDataSource(Dio dio) = _ExplorationRemoteDataSource;

  /// 전체 행성 목록 — 200
  @GET(ApiEndpoints.explorationPlanets)
  Future<List<PlanetResponseModel>> getPlanets();

  /// 행성 하위 지역 목록 — 200 / 404 PLANET_NOT_FOUND
  @GET('/api/explorations/planets/{planetId}/regions')
  Future<List<RegionResponseModel>> getRegions(
    @Path('planetId') String planetId,
  );

  /// 지역 해금 — 200 / 400 / 404
  @POST('/api/explorations/regions/{regionId}/unlock')
  Future<RegionUnlockResponseModel> unlockRegion(
    @Path('regionId') String regionId,
  );

  /// 행성 해금 — 200 / 400 / 404
  @POST('/api/explorations/planets/{planetId}/unlock')
  Future<PlanetUnlockResponseModel> unlockPlanet(
    @Path('planetId') String planetId,
  );
}
