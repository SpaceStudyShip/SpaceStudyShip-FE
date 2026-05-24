# 할일·카테고리 API 백엔드 연동 (#77)

> 로컬 전용으로 동작하던 Todo·Category 도메인의 Data Layer 를 `docs/api-docs.json` 의 8개 엔드포인트와 1:1 로 정렬하고, Auth 흐름과 동일한 Remote+Cache 합성 구조로 전환한다.

| 항목 | 값 |
|---|---|
| 이슈 | [#77](https://github.com/SpaceStudyShip/SpaceStudyShip-FE/issues/77) ⚙️[기능추가][Todo] 할일·카테고리 API 백엔드 연동 |
| 작업 브랜치 | `20260523_#77_할일_및_카테고리_API_백엔드_연동` |
| 베이스 | `origin/main` (auth alignment 완료) |
| Ground truth | `docs/api-docs.json` (TodoCategory · Todo 태그 8 엔드포인트) |
| Out-of-scope | 동기화 큐(retry queue), 충돌 해결 정책, 새 UI 화면, Timer/Fuel 연동 |

---

## 1. 배경

Todo·Category 도메인은 이슈 #24 (할일·카테고리 도메인 구현) 시점에 `SharedPreferences` 기반 로컬 전용으로 만들어졌다. 그 동안 백엔드에 8개 엔드포인트(`/api/todos` 4 + `/api/todo-categories` 4)가 배포되어 `docs/api-docs.json` 에 반영됐지만, 클라이언트는 여전히 게스트용 로컬 저장 구조를 유지하고 있다. 동시에 `docs/api-specs/02_todo.md` 의 오류 코드 정의가 실제 OpenAPI 와 불일치한 상태로 남아있어, Auth alignment (#71) 와 동일한 정합화 사이클이 필요하다.

이번 작업은 **Data Layer 의 Remote 도입과 문서 정합화** 에 집중한다. 동기화 큐·충돌 해결 같은 Tier 1 Optimistic Updates 의 완전 구현은 다음 사이클로 분리한다.

---

## 2. 현황 vs Ground truth 차이

| 항목 | 현재 코드 | `api-docs.json` (ground truth) | Gap |
|---|---|---|---|
| `TodoRemoteDataSource` | 없음 | 8 엔드포인트 정의됨 | 🟢 신규 구현 |
| `TodoRepository` 구현체 | `LocalTodoRepositoryImpl` 단독 | server-first + cache fallback 합성체 필요 | 🔴 신규 + 기존 게스트 분기 |
| `TodoModel` JSON 키 | snake_case (`scheduled_dates`, `category_ids`, `created_at`...) | camelCase (`scheduledDates`, `categoryIds`, `createdAt`...) | 🔴 전면 키 교체 |
| `TodoCategoryModel` JSON 키 | snake_case (`icon_id`, `position_x`, `position_y`, `created_at`, `updated_at`) | camelCase | 🔴 전면 키 교체 |
| `TodoModel._migrateJson` 마이그레이션 | 단일 날짜·bool 형식 → 다중 날짜 형식 | 서버 응답은 항상 신형식 | 🟡 로컬 캐시 fromJson 경로에만 유지, 서버 응답 경로에서는 불필요 |
| `api_endpoints.dart` | Auth 6 상수만 | Todo/Category 4 base + ID path 4 | 🟢 상수 추가 |
| 오류 코드 매핑 | 없음 (모든 예외 `Exception('Todo not found: ...')` 텍스트) | `TODO_NOT_FOUND`, `CATEGORY_NOT_FOUND`, `TODO_ALREADY_EXISTS`, `CATEGORY_ALREADY_EXISTS`, `INVALID_INPUT_VALUE`, `UNAUTHENTICATED_REQUEST`, `INTERNAL_SERVER_ERROR` | 🟡 Exception 서브타입 도입 |
| `repository.getTodoList(categoryId)` | 카테고리 ID 단일 필터 (서버 미사용) | `?date=YYYY-MM-DD`, `?categoryId=...` 두 가지 필터 | 🟡 시그니처에 `date` 추가 |
| `repository.updateTodo(TodoEntity todo)` | 전체 엔티티 전달 → 로컬에서 fullsave | API 는 PATCH (변경 필드만 전송) | 🟡 변경 필드만 보내는 patch DTO 필요 |
| `repository.updateCategory(TodoCategoryEntity category)` | 동일 | 동일 PATCH | 🟡 동일 |
| 로그아웃·탈퇴 시 캐시 정리 | `LocalTodoDataSource.clearAll` 존재하지만 호출 안 됨 | — | 🟡 `AuthRepositoryImpl.signOut/withdraw` 에서 호출 |
| `docs/api-specs/02_todo.md` | `INVALID_TITLE`, `INVALID_DATE_FORMAT`, `403 FORBIDDEN` (구식) | `INVALID_INPUT_VALUE`, 404 통일 | 🟡 doc 동기화 |

---

## 3. 목표 · Out-of-scope

### 3.1 목표
1. `api-docs.json` 의 Todo/TodoCategory 태그 8 엔드포인트와 Data Layer 가 필드·메서드·시그니처 수준에서 1:1 일치.
2. Repository 합성 구조 — 서버를 source of truth 로 두고, 네트워크 실패 시 로컬 캐시를 폴백으로 사용. 게스트(미로그인) 모드는 기존 `LocalTodoRepositoryImpl` 유지.
3. 백엔드 에러 코드(`TODO_NOT_FOUND` 등)를 도메인 Exception 으로 매핑해 호출자가 텍스트 비교 없이 분기 가능.
4. 로그아웃·탈퇴 시 Todo 로컬 캐시도 함께 삭제 (auth alignment 와 대칭).
5. `flutter analyze` 0 issue, 신규/수정 코드 단위 테스트 ≥ 80%.
6. `docs/api-specs/02_todo.md` 가 `api-docs.json` 과 동일 계약을 가리킴.

### 3.2 Out of scope
- 동기화 큐 (sync_queue 테이블, 재시도 정책, exponential backoff) — Tier 1 Optimistic 의 완전 구현은 별도 spec
- 다중 디바이스 충돌 해결 (Last-Write-Wins 정책 등)
- Todo 화면의 UX 개선 (로딩 표시 위치, 에러 토스트 라이팅) — 본 spec 은 기존 화면이 동작하도록 contract 만 정렬
- Timer/Fuel API 연동 (백엔드 미구현)
- 게스트 데이터의 서버 마이그레이션 — 사용자 결정: 게스트 데이터는 로그아웃/탈퇴 시 함께 삭제로 충분

---

## 4. 결정 사항 (확정)

| ID | 결정 | 근거 |
|---|---|---|
| D-1 | Ground truth = `docs/api-docs.json` | Auth alignment 와 동일 원칙 |
| D-2 | 범위 = Todo/TodoCategory 8 API + 캐시 정리 + doc 동기화 | 이슈 #77 본문 명시 |
| D-3 | Repository 합성 = `TodoRepositoryImpl` (Remote+Cache) + `LocalTodoRepositoryImpl` (게스트) 병존 | 인증 상태에 따라 Provider 가 다른 구현체 주입 |
| D-4 | 동기화 전략 = server-first + cache fallback (단순) | 동기화 큐는 후속 사이클. 게스트 데이터는 마이그레이션 없이 폐기 |
| D-5 | 게스트 데이터 처리 = 로그아웃/탈퇴 시 `LocalTodoDataSource.clearAll` 호출 | 사용자 결정 — 게스트 데이터는 휘발 |
| D-6 | PATCH DTO = `TodoUpdateRequestModel`, `CategoryUpdateRequestModel` — nullable 필드 + `toJson` 에서 null 제외 | OpenAPI 의 partial update 의미 보존 |
| D-7 | 에러 매핑 위치 = 공용 `DioExceptionHandler.handle()` 의 switch 에 4 code 추가 (Auth 와 동일 패턴) | 이미 5개 code (`UNAUTHENTICATED_REQUEST`, `INVALID_INPUT_VALUE` 등) 가 공용 핸들러에서 매핑됨. 별도 `TodoExceptionMapper` 클래스는 불필요한 분기 |
| D-7-1 | `InvalidInputValueException` 은 공용 클래스 재사용 (`app_exception.dart:110`) | Todo 전용 InputException 신설은 중복. Auth 와 동일하게 공용 사용 |
| D-7-2 | Repository 생성자 = named parameter (`{required this.remote, required this.cache}`) | `AuthRepositoryImpl` 와 일관 |
| D-8 | Model 마이그레이션 코드 (`_migrateJson`) = 로컬 캐시 fromJson 경로에만 유지, 서버 응답 경로에서는 미적용 | 서버는 항상 신형식. 로컬 캐시는 구버전 사용자 호환을 위해 유지 |
| D-9 | `getTodoList` 시그니처 = `getTodoList({DateTime? date, String? categoryId})` | API 와 1:1, 기존 `categoryId` 단일 인자에서 옵셔널 `date` 추가 |
| D-10 | doc 동기화 = 본 spec 의 마지막 phase | Auth alignment 와 동일 패턴 (P6) |
| D-11 | "네트워크 실패" 판정 = `DioExceptionType.connectionTimeout`, `receiveTimeout`, `sendTimeout`, `connectionError`, `unknown` | 그 외(`badResponse`, `badCertificate`, `cancel`) 는 도메인 예외로 매핑 |

---

## 5. 아키텍처

### 5.1 의존성 흐름

```
Presentation (Notifier × 2)
         │
         ▼
Domain (UseCase × 8) → Domain (TodoRepository iface)
                              ▲
                ┌─────────────┴─────────────┐
        Data (TodoRepositoryImpl)   Data (LocalTodoRepositoryImpl)
        ├ Remote: TodoRemoteDataSource (Retrofit)        │
        └ Local : LocalTodoDataSource (SharedPreferences, 캐시)   │
                                                                  │
                                  (인증 상태 = 게스트인 경우 활용)
```

Provider 가 인증 상태에 따라 두 구현체 중 하나를 주입한다:

```dart
@riverpod
TodoRepository todoRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);  // 기존 auth provider
  if (isAuthenticated) {
    return TodoRepositoryImpl(
      ref.watch(todoRemoteDataSourceProvider),
      ref.watch(localTodoDataSourceProvider),
    );
  }
  return LocalTodoRepositoryImpl(ref.watch(localTodoDataSourceProvider));
}
```

### 5.2 새 Exception 계층

기존 `lib/core/errors/app_exception.dart` 에 4 신규 서브타입을 추가한다 (Auth 패턴 — 도메인별 베이스 없이 `AppException` 의 직접 자식):

```
AppException (core)
├─ ValidationException ─ InvalidInputValueException  ← 이미 존재, Todo 도 재사용
├─ AuthException 및 자식들  ← 이미 존재
└─ (신규 4종, Todo·Category 도메인)
   ├─ TodoNotFoundException          (404 TODO_NOT_FOUND)
   ├─ TodoAlreadyExistsException     (409 TODO_ALREADY_EXISTS)
   ├─ CategoryNotFoundException      (404 CATEGORY_NOT_FOUND)
   └─ CategoryAlreadyExistsException (409 CATEGORY_ALREADY_EXISTS)
```

매핑은 공용 `DioExceptionHandler.handle()` 의 switch 에 case 4개를 추가하여 처리한다 (Auth 의 `DUPLICATED_NICKNAME`, `SOCIAL_LOGIN_FAILED` 추가 패턴과 동일). Repository 는 `try/catch` 후 `throw DioExceptionHandler.handle(e)` 만 호출.

`INVALID_INPUT_VALUE`, `UNAUTHENTICATED_REQUEST`, `INTERNAL_SERVER_ERROR` 는 공통 핸들러가 이미 처리하므로 추가 작업 없음.

#### CategoryNotFoundException 발생 컨텍스트 2종

`api-docs.json` 의 `POST /api/todos` description 에 따르면, 카테고리 존재 검증은 **Todo 생성 시점** 에도 수행된다:

| 호출 | 발생 상황 | 호출자 권장 UX |
|---|---|---|
| `POST /api/todos` (`categoryIds` 에 없는 카테고리 포함) | 다른 디바이스에서 카테고리가 먼저 삭제됨 | "카테고리가 삭제되었습니다. 카테고리를 다시 선택해 주세요" 안내 + 카테고리 목록 invalidate |
| `PATCH /api/todo-categories/{id}` | 카테고리가 이미 삭제됨 | "이미 삭제된 카테고리입니다" 안내 + 카테고리 목록 invalidate |
| `DELETE /api/todo-categories/{id}` | 동일 | 무음 처리 (이미 삭제 = 의도된 결과) 가능 |

→ Mapper 는 동일 예외(`CategoryNotFoundException`)로 변환하고, **메시지 분기는 호출자(Notifier)** 가 담당. UI 작업은 본 spec out-of-scope 이므로, 본 사이클에서는 예외 클래스만 제공하고 메시지 처리는 다음 사이클로 위임.

### 5.3 캐시 정합

| 상황 | Remote 호출 | 캐시 동작 |
|---|---|---|
| 조회 성공 | 200 응답 수신 | 응답 전체로 로컬 덮어쓰기 (`saveTodos`/`saveCategories`) |
| 조회 네트워크 실패 | DioException (timeout/no-network) | 로컬 캐시 반환, 상위에 예외 전파 X |
| 조회 도메인 에러 (401/500) | DioException with code | 매핑된 예외 throw, 캐시 미사용 |
| 생성/수정/삭제 성공 | 응답 수신 | 로컬 캐시에서 해당 항목 갱신/제거 |
| 생성/수정/삭제 실패 | 모든 예외 | 매핑된 예외 throw, 로컬 캐시 변경 없음 |

→ "서버 응답이 항상 최신" 원칙. 로컬은 읽기 폴백 + 다음 fetch 까지의 캐시.

---

## 6. Data Layer 작업 상세

### 6.1 `api_endpoints.dart` 확장

```dart
// Todo
static const todos = '/api/todos';
static String todoById(String id) => '/api/todos/$id';

// Category
static const todoCategories = '/api/todo-categories';
static String todoCategoryById(String id) => '/api/todo-categories/$id';
```

### 6.2 `TodoModel` / `TodoCategoryModel` JSON 정렬

- `@JsonKey(name: 'scheduled_dates')` 같은 매핑을 제거 — 필드명이 곧 JSON 키 (camelCase)
- 기존 SharedPreferences 캐시는 snake_case 로 저장되어 있을 수 있으므로, `_migrateJson` 에 snake_case → camelCase 키 변환 로직을 추가 (구버전 캐시 호환 1회용)
- 새 캐시는 camelCase 로 저장됨

### 6.3 `TodoRemoteDataSource` (Retrofit) — 8 메서드

```dart
@RestApi()
abstract class TodoRemoteDataSource {
  factory TodoRemoteDataSource(Dio dio, {String baseUrl}) = _TodoRemoteDataSource;

  // Todo
  @GET(ApiEndpoints.todos)
  Future<List<TodoModel>> getTodos({
    @Query('date') String? date,         // YYYY-MM-DD
    @Query('categoryId') String? categoryId,
  });

  @POST(ApiEndpoints.todos)
  Future<TodoModel> createTodo(@Body() TodoCreateRequestModel request);

  @PATCH('${ApiEndpoints.todos}/{todoId}')
  Future<TodoModel> updateTodo(
    @Path('todoId') String todoId,
    @Body() TodoUpdateRequestModel request,
  );

  @DELETE('${ApiEndpoints.todos}/{todoId}')
  Future<void> deleteTodo(@Path('todoId') String todoId);

  // Category
  @GET(ApiEndpoints.todoCategories)
  Future<List<TodoCategoryModel>> getCategories();

  @POST(ApiEndpoints.todoCategories)
  Future<TodoCategoryModel> createCategory(@Body() CategoryCreateRequestModel request);

  @PATCH('${ApiEndpoints.todoCategories}/{categoryId}')
  Future<TodoCategoryModel> updateCategory(
    @Path('categoryId') String categoryId,
    @Body() CategoryUpdateRequestModel request,
  );

  @DELETE('${ApiEndpoints.todoCategories}/{categoryId}')
  Future<void> deleteCategory(@Path('categoryId') String categoryId);
}
```

### 6.4 Request DTO

| DTO | 필드 (모두 nullable except *) | 비고 |
|---|---|---|
| `TodoCreateRequestModel` | `id?`, `title*`, `categoryIds?`, `estimatedMinutes?`, `scheduledDates?` | 서버 UUID 생성 허용 |
| `TodoUpdateRequestModel` | `title?`, `scheduledDates?`, `completedDates?`, `categoryIds?`, `estimatedMinutes?`, `actualMinutes?` | `toJson` 에서 null 제외하여 PATCH semantics 보존 (`includeIfNull: false`) |
| `CategoryCreateRequestModel` | `id?`, `name*`, `iconId?`, `positionX?`, `positionY?` | 동일 |
| `CategoryUpdateRequestModel` | `name?`, `iconId?`, `positionX?`, `positionY?` | 동일 |

날짜 직렬화: `scheduledDates`/`completedDates` 는 OpenAPI 상 `string` 배열이고 패턴이 `YYYY-MM-DD` 다. 직렬화 시 `DateFormat('yyyy-MM-dd').format()` 사용, 역직렬화는 `DateTime.parse` (UTC 처리).

### 6.5 `TodoRepositoryImpl`

```dart
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remote;
  final LocalTodoDataSource cache;

  TodoRepositoryImpl({required this.remote, required this.cache});

  @override
  Future<List<TodoEntity>> getTodoList({DateTime? date, String? categoryId}) async {
    try {
      final models = await remote.getTodos(
        date: date != null ? DateFormat('yyyy-MM-dd').format(date) : null,
        categoryId: categoryId,
      );
      await cache.saveTodos(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {  // D-11 의 5종 DioExceptionType
        // 캐시 폴백
        return cache.getTodos().map((m) => m.toEntity()).toList();
      }
      throw DioExceptionHandler.handle(e);  // 도메인 코드 매핑 위임
    }
  }

  // create/update/delete 도 동일 패턴: 서버 성공 → 캐시 갱신, 실패 → DioExceptionHandler.handle throw
}
```

`Repository.updateTodo(TodoEntity todo)` 는 PATCH 본문에 **전체 필드** 를 채워 보내는 단순 구현으로 시작 (현재 호출부도 항상 전체 엔티티를 전달). 다음 사이클에서 변경 필드만 추적하는 diff 기반 patch 로 진화 가능.

### 6.6 공용 `DioExceptionHandler` 확장

`lib/core/network/dio_exception_handler.dart` 의 `code` 기반 switch 에 4 case 추가:

```dart
case 'TODO_NOT_FOUND':
  return TodoNotFoundException(message: apiError.message, originalException: e);
case 'TODO_ALREADY_EXISTS':
  return TodoAlreadyExistsException(message: apiError.message, originalException: e);
case 'CATEGORY_NOT_FOUND':
  return CategoryNotFoundException(message: apiError.message, originalException: e);
case 'CATEGORY_ALREADY_EXISTS':
  return CategoryAlreadyExistsException(message: apiError.message, originalException: e);
```

→ 모든 Repository 가 `throw DioExceptionHandler.handle(e)` 한 줄로 통일된 예외를 받는다. Todo feature 내부에 별도 Mapper 클래스 불필요.

---

## 7. Provider 체인 변경

`lib/features/todo/presentation/providers/todo_provider.dart`:

- `todoRemoteDataSourceProvider` 신규 — `Dio` 주입
- `todoRepositoryProvider` 변경 — 인증 상태에 따라 `TodoRepositoryImpl` 또는 `LocalTodoRepositoryImpl` 반환
- UseCase·Notifier 는 변경 없음 (의존성 흐름이 인터페이스에 묶여 있음)

기존 `TodoListNotifier`·`CategoryListNotifier` 의 optimistic UI 업데이트(`previousState` 롤백 패턴) 는 그대로 유지 — 서버 실패 시 자동으로 이전 상태 복원되어 UX 일관성 보장.

---

## 8. 로그아웃·탈퇴 시 캐시 정리

`AuthRepositoryImpl.signOut()` 및 `withdraw()` 의 token clear 직후 한 줄 추가:

```dart
await _tokenStorage.clearTokens();
await _localTodoDataSource.clearAll();   // 추가
```

또는 더 깨끗하게 — `AuthRepositoryImpl` 가 `LocalTodoDataSource` 를 직접 의존하지 않도록, `_clearLocalDomainCaches` 콜백을 주입받아 호출. 단순함 우선이라면 직접 의존도 허용 (auth 와 todo 가 한 PR 에서 함께 변경).

게스트 데이터는 이 시점에 사라지고, 다음 로그인 시 빈 서버 상태에서 시작한다.

---

## 9. 테스트 계획

### 9.1 단위 테스트
- `TodoModel.fromJson` — camelCase 키, 누락 필드 default, ISO8601 UTC 파싱
- `TodoModel._migrateJson` — snake_case 키 → camelCase 키 변환 (구버전 캐시 호환)
- `TodoUpdateRequestModel.toJson` — null 필드 제외 검증
- `TodoExceptionMapper.map` — 각 에러 코드 → 도메인 예외 매핑
- `TodoRepositoryImpl.getTodoList` — 서버 성공/네트워크 실패(캐시 폴백)/도메인 에러 3 시나리오
- `TodoRepositoryImpl.createTodo` — 서버 성공 시 캐시 add, 실패 시 캐시 미변경

### 9.2 통합/Provider 테스트
- `todoRepositoryProvider` — 인증 상태에 따라 다른 구현체 반환
- `TodoListNotifier.toggleTodoForDate` — 서버 실패 시 previousState 롤백 확인
- 로그아웃 후 `LocalTodoDataSource.getTodos()` 가 빈 배열 반환

### 9.3 회귀 확인 (수동 / `flutter analyze`)
- 기존 화면 (`category_map_screen`, `todo_add_bottom_sheet`, `category_add_bottom_sheet`, `category_select_bottom_sheet`) 가 그대로 동작
- 게스트 모드 (로그아웃 상태) 에서 Todo 추가/삭제가 로컬에만 영향

---

## 10. 문서 동기화 (`docs/api-specs/02_todo.md`)

| 항목 | 현재 | 변경 후 |
|---|---|---|
| 동기화 전략 설명 | "Tier 1 Optimistic Updates" 명시 | "서버 source of truth + 로컬 캐시 폴백. 동기화 큐는 별도 사이클" 로 갱신 |
| 오류 코드 표 | `INVALID_TITLE`, `INVALID_DATE_FORMAT`, `403 FORBIDDEN` | `INVALID_INPUT_VALUE`, 404 통일 (`api-docs.json` 그대로) |
| Todo 생성 Request 필드 | 변경 없음 | 변경 없음 |
| 카테고리 삭제 SQL 예시 | 유지 | 유지 (서버 책임 명세) |

---

## 11. 작업 단계 (Phase)

| Phase | 내용 | 산출물 |
|---|---|---|
| P0 | base URL 확인 — `EnvConfig.apiBaseUrl` 이 `api-docs.json` production 서버 (`http://suh-project.synology.me:8099`) 와 일치하는지 대조. 기존 Auth 호출이 정상이라면 그대로 통과. | 변경 없음 (확인만) |
| P1 | `api_endpoints.dart` 확장 + 신규 Exception 4종을 `lib/core/errors/app_exception.dart` 에 추가 + `DioExceptionHandler.handle` 의 switch 에 4 case 추가 | endpoint 상수 4 + Exception 4 서브타입 + 핸들러 case 4 |
| P2 | Model camelCase 정렬 + 마이그레이션 코드 보강 | `TodoModel`, `TodoCategoryModel` + 단위 테스트 |
| P3 | Request DTO 신설 (`TodoCreateRequest`, `TodoUpdateRequest`, `CategoryCreateRequest`, `CategoryUpdateRequest`) | DTO 4종 + 단위 테스트 |
| P4 | `TodoRemoteDataSource` 정의 + build_runner | Retrofit + `.g.dart` |
| P5 | `TodoRepositoryImpl` 합성 (Remote+Cache, named ctor) | 새 Repository + 단위 테스트 |
| P6 | Provider 체인 갱신 (인증 분기) + Notifier 회귀 테스트 | `todo_provider.dart` 수정 + Provider 테스트 |
| P7 | Auth 흐름에 캐시 정리 hook 추가 | `AuthRepositoryImpl.signOut/withdraw` 수정 |
| P8 | `docs/api-specs/02_todo.md` 동기화 | 문서 갱신 |
| P9 | 통합 검증 — `flutter analyze` / `flutter test` / 화면 회귀 | 모두 green |

---

## 12. 위험 · 완화

| 위험 | 영향 | 완화 |
|---|---|---|
| 기존 SharedPreferences 캐시가 snake_case 라서 첫 fetch 전까지 디시리얼라이즈 실패 | 게스트→로그인 전환 시 일시적 빈 화면 | `_migrateJson` 에 snake→camel 키 변환을 추가, 그래도 실패하면 기존 동작대로 캐시 폐기 (`try-catch` 안에서 `_prefs.remove`) |
| 서버 응답이 ISO8601 with timezone (Z), 로컬은 시스템 timezone 으로 표시 | 날짜 경계 케이스에서 todo 가 다른 날에 표시 | `scheduledDates` 직렬화는 `yyyy-MM-dd` 로컬 기준, 응답 파싱도 `DateTime.parse` 후 `normalizeDate` 로 일관 처리 |
| PATCH 본문에서 빈 배열을 보낼 때 OpenAPI 해석이 모호함 | `categoryIds: []` 가 "모두 제거" 인지 "변경 없음" 인지 불명확 | `02_todo.md` 에 "빈 배열은 명시적 모두 제거" 명시 (`api-docs.json` 동일 의미). 단위 테스트로 보장 |
| 인증 상태 변화에 따라 Provider 가 재구성되지 않는 경우 | 로그인 직후에도 로컬 repository 가 쓰이는 잔여 상태 | `todoRepositoryProvider` 가 `isAuthenticatedProvider` 를 `watch` 하도록 보장. 인증 상태 변경 시 `ref.invalidate(todoListNotifierProvider)` 명시적 호출 |
| 캐시 정리 hook 이 Auth feature 가 Todo feature 를 의존하게 만드는 역방향 의존 | 의존 그래프 오염 | `AuthRepositoryImpl` 가 `LocalTodoDataSource` 만 의존 (Todo feature 의 가장 안쪽 layer). Provider 주입으로 처리. 추후 더 많은 feature 가 추가되면 `LocalDomainCacheRegistry` 같은 공통 점으로 리팩터 검토 |
| `updatedAt` 필드 nullable 처리 — OpenAPI 3.1 + required 배열 미사용으로 모든 응답 필드가 사실상 optional 로 해석될 수 있음 | DTO 디시리얼라이즈 시 null 에서 throw | `TodoResponse.updatedAt` 은 description "마지막 수정 시각" 으로 항상 존재 가정 (서버 contract), `CategoryResponse.updatedAt` 은 nullable 로 유지. 단위 테스트에 `updatedAt` 없는 케이스 추가하여 모델이 견고히 처리하는지 확인 |

---

## 13. 완료 조건 (Definition of Done)

- [ ] `flutter analyze` 0 issue
- [ ] 신규/수정 코드 단위 테스트 통과, 80% 이상 라인 커버리지
- [ ] 인증 상태 토글 시 `todoRepositoryProvider` 가 올바른 구현체 반환 (Provider 테스트)
- [ ] 로그아웃 후 SharedPreferences 의 `guest_todos`/`guest_todo_categories` 키 부재
- [ ] `category_map_screen` 진입 시 서버 fetch → 카테고리 5개 표시 (수동 회귀)
- [ ] `docs/api-specs/02_todo.md` 의 오류 코드 표가 `api-docs.json` 과 동일
- [ ] 커밋 메시지가 `feat/fix/docs/test/refactor : <한글 설명> #77` 형식
