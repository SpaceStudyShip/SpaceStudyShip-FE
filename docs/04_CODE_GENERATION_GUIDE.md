# 04_CODE_GENERATION_GUIDE.md - 우주공부선 코드 생성 가이드

## 목차
1. [코드 생성 도구](#코드-생성-도구)
2. [Feature 생성 템플릿](#feature-생성-템플릿)
3. [MVP 구현 순서](#mvp-구현-순서)
4. [공통 패턴](#공통-패턴)
5. [자동화 스크립트](#자동화-스크립트)

---

## 코드 생성 도구

### 1. Build Runner
```yaml
용도: Freezed, Riverpod, Retrofit, JsonSerializable 코드 생성

명령어:
  # 모든 코드 생성 (기존 파일 삭제 후 재생성)
  flutter pub run build_runner build --delete-conflicting-outputs

  # Watch 모드 (파일 변경 시 자동 재생성)
  flutter pub run build_runner watch --delete-conflicting-outputs

  # 캐시 삭제 후 재생성
  flutter pub run build_runner clean
  flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Freezed
```yaml
용도: 불변 데이터 클래스 생성 (Entity, Model)

생성 파일:
  - {file}.freezed.dart
  - {file}.g.dart (JsonSerializable 포함 시)

장점:
  - copyWith() 자동 생성
  - == / hashCode 자동 구현
  - toString() 자동 생성
  - Union Type 지원
```

### 3. Riverpod Generator
```yaml
용도: Riverpod Provider 코드 생성

생성 파일:
  - {file}.g.dart

장점:
  - @riverpod 어노테이션으로 간결한 코드
  - 타입 안전성
  - 자동 의존성 관리
```

### 4. Retrofit
```yaml
용도: REST API 클라이언트 코드 생성

생성 파일:
  - {file}.g.dart

장점:
  - HTTP 메서드 어노테이션 (@GET, @POST 등)
  - 타입 안전한 API 호출
  - Dio와 통합
```

### 5. JsonSerializable
```yaml
용도: JSON 직렬화/역직렬화 코드 생성

생성 파일:
  - {file}.g.dart

장점:
  - fromJson() / toJson() 자동 생성
  - 타입 안전성
  - Freezed와 통합
```

---

## Feature 생성 템플릿

### 1. Entity 생성 템플릿
```dart
// lib/features/todo/domain/entities/todo_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';
part 'todo_entity.g.dart';

/// Todo 도메인 모델
///
/// 순수 비즈니스 로직 (Flutter 의존성 없음)
@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    required bool completed,
    required DateTime createdAt,
  }) = _TodoEntity;

  factory TodoEntity.fromJson(Map<String, dynamic> json) =>
      _$TodoEntityFromJson(json);
}
```

### 2. Model 생성 템플릿
```dart
// lib/features/todo/data/models/todo_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

/// Todo DTO (Data Transfer Object)
///
/// 서버 ↔ 앱 데이터 전송용
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    required bool completed,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

/// DTO → Entity 변환 확장
extension TodoModelX on TodoModel {
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      completed: completed,
      createdAt: createdAt,
    );
  }
}

/// Entity → DTO 변환 확장
extension TodoEntityX on TodoEntity {
  TodoModel toModel() {
    return TodoModel(
      id: id,
      title: title,
      completed: completed,
      createdAt: createdAt,
    );
  }
}
```

### 3. Repository Interface 템플릿
```dart
// lib/features/todo/domain/repositories/todo_repository.dart

/// Todo Repository 인터페이스
///
/// Data Layer에서 구현
abstract class TodoRepository {
  /// Todo 리스트 조회
  Future<List<TodoEntity>> getTodoList({bool? completed});

  /// Todo 생성
  Future<TodoEntity> createTodo(String title);

  /// Todo 수정
  Future<TodoEntity> updateTodo(TodoEntity todo);

  /// Todo 삭제
  Future<void> deleteTodo(String id);
}
```

### 4. Remote DataSource 템플릿 (Retrofit)
```dart
// lib/features/todo/data/datasources/todo_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/todo_model.dart';

part 'todo_remote_datasource.g.dart';

/// Todo API 클라이언트
///
/// Spring Boot REST API와 통신
@RestApi(baseUrl: '/api/v1/todos')
abstract class TodoRemoteDataSource {
  factory TodoRemoteDataSource(Dio dio, {String baseUrl}) =
      _TodoRemoteDataSource;

  /// Todo 리스트 조회
  @GET('')
  Future<List<TodoModel>> getTodoList({
    @Query('completed') bool? completed,
  });

  /// Todo 생성
  @POST('')
  Future<TodoModel> createTodo(@Body() CreateTodoRequest request);

  /// Todo 수정
  @PUT('/{id}')
  Future<TodoModel> updateTodo(
    @Path('id') String id,
    @Body() UpdateTodoRequest request,
  );

  /// Todo 삭제
  @DELETE('/{id}')
  Future<void> deleteTodo(@Path('id') String id);
}

/// Todo 생성 요청
@JsonSerializable()
class CreateTodoRequest {
  final String title;

  CreateTodoRequest({required this.title});

  Map<String, dynamic> toJson() => _$CreateTodoRequestToJson(this);
}

/// Todo 수정 요청
@JsonSerializable()
class UpdateTodoRequest {
  final String title;
  final bool completed;

  UpdateTodoRequest({required this.title, required this.completed});

  Map<String, dynamic> toJson() => _$UpdateTodoRequestToJson(this);
}
```

### 5. Local DataSource 템플릿 (Drift)
```dart
// lib/features/todo/data/datasources/todo_local_datasource.dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../models/todo_model.dart';

/// Todo 로컬 데이터 소스 (Drift)
///
/// SQLite DB와 통신
class TodoLocalDataSource {
  final AppDatabase _db;

  TodoLocalDataSource(this._db);

  /// Todo 리스트 조회
  Future<List<TodoModel>> getTodoList({bool? completed}) async {
    final query = _db.select(_db.todos);

    if (completed != null) {
      query.where((tbl) => tbl.completed.equals(completed));
    }

    final rows = await query.get();
    return rows.map((row) => _rowToModel(row)).toList();
  }

  /// Todo 저장 (캐시)
  Future<void> saveTodo(TodoModel model) async {
    await _db.into(_db.todos).insertOnConflictUpdate(
          TodosCompanion.insert(
            id: model.id,
            title: model.title,
            completed: model.completed,
            createdAt: model.createdAt,
          ),
        );
  }

  /// Todo 삭제
  Future<void> deleteTodo(String id) async {
    await (_db.delete(_db.todos)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Row → Model 변환
  TodoModel _rowToModel(Todo row) {
    return TodoModel(
      id: row.id,
      title: row.title,
      completed: row.completed,
      createdAt: row.createdAt,
    );
  }
}
```

### 6. Repository Implementation 템플릿
```dart
// lib/features/todo/data/repositories/todo_repository_impl.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

/// Todo Repository 구현체
///
/// Tier 1: Optimistic Updates 전략
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;

  TodoRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<TodoEntity>> getTodoList({bool? completed}) async {
    try {
      // 1. 서버에서 가져오기
      final models = await _remoteDataSource.getTodoList(completed: completed);

      // 2. 로컬 캐시 저장
      for (final model in models) {
        await _localDataSource.saveTodo(model);
      }

      // 3. Entity로 변환
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      debugPrint('❌ TodoRepository.getTodoList error: $e');

      // 4. 네트워크 에러 시 로컬 캐시 반환
      final cached = await _localDataSource.getTodoList(completed: completed);
      return cached.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<TodoEntity> createTodo(String title) async {
    // Optimistic: 로컬에 먼저 저장
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempModel = TodoModel(
      id: tempId,
      title: title,
      completed: false,
      createdAt: DateTime.now(),
    );

    await _localDataSource.saveTodo(tempModel);

    try {
      // 서버에 전송
      final request = CreateTodoRequest(title: title);
      final serverModel = await _remoteDataSource.createTodo(request);

      // 서버 ID로 교체
      await _localDataSource.deleteTodo(tempId);
      await _localDataSource.saveTodo(serverModel);

      return serverModel.toEntity();
    } catch (e) {
      debugPrint('❌ TodoRepository.createTodo error: $e');
      // 실패 시 임시 모델 반환 (동기화 큐에 추가 필요)
      return tempModel.toEntity();
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    final model = todo.toModel();

    // Optimistic: 로컬에 먼저 저장
    await _localDataSource.saveTodo(model);

    try {
      // 서버에 전송
      final request = UpdateTodoRequest(
        title: todo.title,
        completed: todo.completed,
      );
      final serverModel = await _remoteDataSource.updateTodo(todo.id, request);

      return serverModel.toEntity();
    } catch (e) {
      debugPrint('❌ TodoRepository.updateTodo error: $e');
      return model.toEntity();
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    // Optimistic: 로컬에서 먼저 삭제
    await _localDataSource.deleteTodo(id);

    try {
      // 서버에 전송
      await _remoteDataSource.deleteTodo(id);
    } catch (e) {
      debugPrint('❌ TodoRepository.deleteTodo error: $e');
      // 실패 시 동기화 큐에 추가 필요
    }
  }
}
```

### 7. UseCase 템플릿
```dart
// lib/features/todo/domain/usecases/get_todo_list_usecase.dart
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

/// Todo 리스트 조회 UseCase
///
/// 단일 책임: Todo 리스트를 가져오는 것만 담당
class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  /// 실행
  Future<List<TodoEntity>> execute({bool? completed}) async {
    return await _repository.getTodoList(completed: completed);
  }
}
```

### 8. Provider 템플릿
```dart
// lib/features/todo/presentation/providers/todo_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/dio/dio_client.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/create_todo_usecase.dart';
import '../../domain/usecases/get_todo_list_usecase.dart';

part 'todo_provider.g.dart';

/// Remote DataSource Provider
@riverpod
TodoRemoteDataSource todoRemoteDataSource(TodoRemoteDataSourceRef ref) {
  final dio = ref.read(dioProvider);
  return TodoRemoteDataSource(dio);
}

/// Local DataSource Provider
@riverpod
TodoLocalDataSource todoLocalDataSource(TodoLocalDataSourceRef ref) {
  final db = ref.read(appDatabaseProvider);
  return TodoLocalDataSource(db);
}

/// Repository Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final remote = ref.read(todoRemoteDataSourceProvider);
  final local = ref.read(todoLocalDataSourceProvider);
  return TodoRepositoryImpl(remote, local);
}

/// GetTodoList UseCase Provider
@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodoListUseCase(repository);
}

/// CreateTodo UseCase Provider
@riverpod
CreateTodoUseCase createTodoUseCase(CreateTodoUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return CreateTodoUseCase(repository);
}

/// Todo List StateNotifier Provider
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final useCase = ref.read(getTodoListUseCaseProvider);
    return useCase.execute();
  }

  /// Todo 추가
  Future<void> addTodo(String title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(createTodoUseCaseProvider);
      await useCase.execute(title);
      return ref.read(getTodoListUseCaseProvider).execute();
    });
  }

  /// Todo 토글
  Future<void> toggleTodo(TodoEntity todo) async {
    final updated = todo.copyWith(completed: !todo.completed);

    // Optimistic update
    state.whenData((todos) {
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        final newTodos = [...todos];
        newTodos[index] = updated;
        state = AsyncValue.data(newTodos);
      }
    });

    // 서버 전송
    try {
      final useCase = ref.read(updateTodoUseCaseProvider);
      await useCase.execute(updated);
    } catch (e) {
      // 실패 시 원래 상태로 되돌림
      ref.invalidateSelf();
    }
  }

  /// Todo 삭제
  Future<void> deleteTodo(String id) async {
    // Optimistic update
    state.whenData((todos) {
      final newTodos = todos.where((t) => t.id != id).toList();
      state = AsyncValue.data(newTodos);
    });

    // 서버 전송
    try {
      final useCase = ref.read(deleteTodoUseCaseProvider);
      await useCase.execute(id);
    } catch (e) {
      // 실패 시 원래 상태로 되돌림
      ref.invalidateSelf();
    }
  }
}
```

### 9. Screen 템플릿
```dart
// lib/features/todo/presentation/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';

/// Todo 리스트 화면
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: todosAsync.when(
        data: (todos) => _buildList(todos),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error.toString()),
      ),
      floatingActionButton: _buildFAB(context, ref),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('오늘의 미션'),
    );
  }

  Widget _buildList(List<TodoEntity> todos) {
    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoItem(
          key: Key(todos[index].id),
          todo: todos[index],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text('아직 할 일이 없어요', style: AppTextStyles.body1),
          Text('미션을 추가해보세요!', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.w, color: Colors.red),
          SizedBox(height: 16.h),
          Text('에러가 발생했어요', style: AppTextStyles.body1),
          Text(error, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddDialog(context, ref),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('미션 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '할 일을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(todoListNotifierProvider.notifier).addTodo(
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
```

---

## MVP 구현 순서

### Phase 1: Core Infrastructure (1-2일)
```yaml
목표: 기본 인프라 설정

작업:
  1. Dio Client 설정
     - lib/core/services/dio/dio_client.dart
     - AuthInterceptor, LoggingInterceptor

  2. Secure Storage 설정
     - lib/core/services/storage/secure_storage_service.dart

  3. Drift DB 설정
     - lib/core/database/app_database.dart
     - 테이블 정의 (Users, Todos, TimerSessions, Fuel, Locations 등)

  4. GoRouter 설정
     - lib/routes/app_router.dart
     - 라우트 정의

  5. Theme 설정
     - lib/core/theme/app_theme.dart
     - 우주 테마 색상, Material 3
```

### Phase 2: Auth Feature (2-3일)
```yaml
목표: Google 로그인 구현

작업 순서:
  1. Entity & Model
     - user_entity.dart
     - user_model.dart

  2. DataSource
     - auth_remote_datasource.dart (Retrofit)
     - auth_local_datasource.dart (Drift)

  3. Repository
     - auth_repository.dart (interface)
     - auth_repository_impl.dart

  4. UseCase
     - google_sign_in_usecase.dart
     - logout_usecase.dart
     - get_current_user_usecase.dart

  5. Provider
     - auth_provider.dart (@riverpod)

  6. UI
     - splash_screen.dart
     - login_screen.dart
     - google_sign_in_button.dart

테스트:
  - Google 로그인 → JWT 토큰 발급 확인
  - Secure Storage 저장 확인
  - 자동 로그인 확인
```

### Phase 3: Todo Feature (2-3일)
```yaml
목표: Todo CRUD 구현

작업 순서:
  1. Entity & Model
  2. DataSource
  3. Repository (Optimistic Updates)
  4. UseCase (4개: Get, Create, Update, Delete)
  5. Provider
  6. UI

테스트:
  - 오프라인 추가 → 온라인 동기화
  - 서버 에러 시 로컬 캐시 표시
```

### Phase 4: Timer Feature (3-4일)
```yaml
목표: 타이머 + 연료 획득

작업 순서:
  1. Timer Entity & Model
  2. Fuel Entity & Model
  3. DataSource (Timer, Fuel)
  4. Repository (Server-Validated)
  5. UseCase
  6. Provider (타이머 상태 관리)
  7. UI (타이머 화면, 우주선 애니메이션 준비)

테스트:
  - 타이머 시작/일시정지/종료
  - 서버 검증 (연료 계산)
  - 정각 보너스 확인
```

### Phase 5: Exploration Feature (2-3일)
```yaml
목표: 탐험 지도 + 장소 해금

작업 순서:
  1. Location Entity & Model
  2. DataSource
  3. Repository
  4. UseCase (Get Locations, Unlock Location)
  5. Provider
  6. UI (지도, 장소 카드, 해금 다이얼로그)

테스트:
  - 연료 차감 검증
  - 장소 해금 애니메이션
```

### Phase 6: Social Features (4-5일)
```yaml
목표: 친구 + 그룹 시스템

작업 순서:
  1. Friends
     - Entity, Model, DataSource, Repository, UseCase, Provider, UI

  2. Groups
     - Entity, Model, DataSource, Repository, UseCase, Provider, UI

테스트:
  - 친구 요청/수락/거절
  - 그룹 생성/참여
  - 초대 코드
```

### Phase 7: Ranking Feature (1-2일)
```yaml
목표: 랭킹 시스템

작업 순서:
  1. Entity, Model (Ranking)
  2. DataSource (Server-Only)
  3. Repository
  4. UseCase
  5. Provider
  6. UI (랭킹 탭)

테스트:
  - 전체/주간/친구/그룹 랭킹
  - 실시간 업데이트
```

### Phase 8: Integration & Polish (2-3일)
```yaml
목표: 통합 테스트 + UX 개선

작업:
  - 네비게이션 연결
  - 오프라인 동기화 큐 시스템
  - 에러 처리 개선
  - 로딩 상태 개선
  - 빈 상태 UI
  - 애니메이션 추가
```

---

## 공통 패턴

### 1. Dio Client 설정
```dart
// lib/core/services/dio/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.spacestudyship.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Interceptors
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LoggingInterceptor());

  return dio;
}
```

### 2. Auth Interceptor
```dart
// lib/core/services/dio/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import '../../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = _ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized → 로그아웃
    if (err.response?.statusCode == 401) {
      final storage = _ref.read(secureStorageServiceProvider);
      await storage.clearTokens();
      // TODO: 로그인 화면으로 이동
    }

    handler.next(err);
  }
}
```

---

## 자동화 스크립트

### Feature 생성 스크립트 (Bash)
```bash
#!/bin/bash
# scripts/create_feature.sh

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ./create_feature.sh <feature_name>"
  exit 1
fi

FEATURE_PATH="lib/features/$FEATURE_NAME"

# 디렉토리 생성
mkdir -p $FEATURE_PATH/{data,domain,presentation}/{datasources,models,repositories,entities,usecases,providers,screens,widgets}

# 파일 생성
touch $FEATURE_PATH/data/datasources/${FEATURE_NAME}_remote_datasource.dart
touch $FEATURE_PATH/data/datasources/${FEATURE_NAME}_local_datasource.dart
touch $FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart
touch $FEATURE_PATH/data/repositories/${FEATURE_NAME}_repository_impl.dart

touch $FEATURE_PATH/domain/entities/${FEATURE_NAME}_entity.dart
touch $FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart
touch $FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}_usecase.dart

touch $FEATURE_PATH/presentation/providers/${FEATURE_NAME}_provider.dart
touch $FEATURE_PATH/presentation/screens/${FEATURE_NAME}_screen.dart

echo "✅ Feature '$FEATURE_NAME' created successfully!"
echo "📁 Path: $FEATURE_PATH"
```

### 사용 예시
```bash
chmod +x scripts/create_feature.sh
./scripts/create_feature.sh mission
```

---

## 코드 생성 체크리스트

### ✅ 생성 전
```yaml
- [ ] Feature 이름 확정
- [ ] Entity 필드 정의
- [ ] API 엔드포인트 확인
- [ ] DB 테이블 스키마 확인
```

### ✅ 생성 중
```yaml
- [ ] Freezed 어노테이션 추가
- [ ] JsonSerializable 어노테이션 추가 (필요 시)
- [ ] @riverpod 어노테이션 추가
- [ ] part 파일 선언
- [ ] build_runner 실행
```

### ✅ 생성 후
```yaml
- [ ] 생성된 파일 커밋
- [ ] 컴파일 에러 없음
- [ ] Provider 의존성 확인
- [ ] 테스트 작성
```

---

## 참고 자료
- [Freezed Usage](https://pub.dev/packages/freezed)
- [Riverpod Generator](https://riverpod.dev/docs/concepts/about_code_generation)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Drift Tutorial](https://drift.simonbinder.eu/docs/getting-started/)
