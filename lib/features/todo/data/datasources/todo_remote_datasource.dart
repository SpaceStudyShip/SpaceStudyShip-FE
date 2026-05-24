import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/category_create_request_model.dart';
import '../models/category_update_request_model.dart';
import '../models/todo_category_model.dart';
import '../models/todo_create_request_model.dart';
import '../models/todo_model.dart';
import '../models/todo_update_request_model.dart';

part 'todo_remote_datasource.g.dart';

/// Todo·Category 백엔드 API 클라이언트
///
/// `api-docs.json` 의 Todo · TodoCategory 태그 8 엔드포인트 매핑.
@RestApi()
abstract class TodoRemoteDataSource {
  factory TodoRemoteDataSource(Dio dio) = _TodoRemoteDataSource;

  // ============================================
  // Todo
  // ============================================

  /// 할 일 목록 조회 — date / categoryId 옵션 필터, createdAt 내림차순
  @GET(ApiEndpoints.todos)
  Future<List<TodoModel>> getTodos({
    @Query('date') String? date,
    @Query('categoryId') String? categoryId,
  });

  /// 할 일 생성 — 201
  ///
  /// - 400 INVALID_INPUT_VALUE
  /// - 404 CATEGORY_NOT_FOUND (categoryIds 검증 실패)
  /// - 409 TODO_ALREADY_EXISTS
  @POST(ApiEndpoints.todos)
  Future<TodoModel> createTodo(@Body() TodoCreateRequestModel request);

  /// 할 일 부분 수정 — 200
  ///
  /// - 404 TODO_NOT_FOUND (다른 사용자 소유 포함)
  @PATCH('${ApiEndpoints.todos}/{todoId}')
  Future<TodoModel> updateTodo(
    @Path('todoId') String todoId,
    @Body() TodoUpdateRequestModel request,
  );

  /// 할 일 삭제 — 204
  @DELETE('${ApiEndpoints.todos}/{todoId}')
  Future<void> deleteTodo(@Path('todoId') String todoId);

  // ============================================
  // Category
  // ============================================

  /// 카테고리 목록 조회 — createdAt 오름차순
  @GET(ApiEndpoints.todoCategories)
  Future<List<TodoCategoryModel>> getCategories();

  /// 카테고리 생성 — 201
  @POST(ApiEndpoints.todoCategories)
  Future<TodoCategoryModel> createCategory(
    @Body() CategoryCreateRequestModel request,
  );

  /// 카테고리 부분 수정 — 200
  @PATCH('${ApiEndpoints.todoCategories}/{categoryId}')
  Future<TodoCategoryModel> updateCategory(
    @Path('categoryId') String categoryId,
    @Body() CategoryUpdateRequestModel request,
  );

  /// 카테고리 삭제 — 204
  ///
  /// 서버가 연관 Todo 의 categoryIds 에서 자동 제거.
  @DELETE('${ApiEndpoints.todoCategories}/{categoryId}')
  Future<void> deleteCategory(@Path('categoryId') String categoryId);
}
