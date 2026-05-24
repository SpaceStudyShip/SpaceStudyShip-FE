# Todo·Category API 백엔드 연동 Implementation Plan (#77)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Todo·Category 도메인 Data Layer 를 `docs/api-docs.json` 의 8 엔드포인트와 1:1 정렬하고 Auth 와 동일한 Remote+Cache 합성 구조로 전환한다.

**Architecture:** 인증 상태에 따라 `TodoRepositoryImpl` (Remote+Cache, server-first + cache fallback) 또는 `LocalTodoRepositoryImpl` (게스트) 가 주입된다. 도메인 코드 매핑은 공용 `DioExceptionHandler` 의 switch 에 case 4개를 추가하여 처리한다.

**Tech Stack:** Flutter 3.9 · Riverpod 2.6 (generator) · Freezed 2.5 · Dio 5.9 · Retrofit 4.7 · mocktail (테스트)

**Spec:** `docs/superpowers/specs/2026-05-23-todo-category-api-integration-design.md`

---

## File Structure

### 신규 파일

| 파일 | 책임 |
|---|---|
| `lib/features/todo/data/datasources/todo_remote_datasource.dart` | Retrofit 8 엔드포인트 인터페이스 |
| `lib/features/todo/data/models/todo_create_request_model.dart` | POST /api/todos 요청 DTO |
| `lib/features/todo/data/models/todo_update_request_model.dart` | PATCH /api/todos/{id} 요청 DTO (`includeIfNull: false`) |
| `lib/features/todo/data/models/category_create_request_model.dart` | POST /api/todo-categories 요청 DTO |
| `lib/features/todo/data/models/category_update_request_model.dart` | PATCH /api/todo-categories/{id} 요청 DTO (`includeIfNull: false`) |
| `lib/features/todo/data/repositories/todo_repository_impl.dart` | Remote+Cache 합성 Repository |
| `test/features/todo/data/models/*_test.dart` | DTO/Model 단위 테스트 (6개) |
| `test/features/todo/data/repositories/todo_repository_impl_test.dart` | Repository 단위 테스트 |
| `test/core/network/dio_exception_handler_test.dart` (기존, 보강) | 신규 4 case 테스트 추가 |

### 수정 파일

| 파일 | 변경 |
|---|---|
| `lib/core/constants/api_endpoints.dart` | Todo/Category 4 상수 + path helper 2 추가 |
| `lib/core/errors/app_exception.dart` | 신규 Exception 4 서브타입 추가 |
| `lib/core/network/dio_exception_handler.dart` | switch 에 case 4 추가 |
| `lib/features/todo/data/models/todo_model.dart` | JSON 키 camelCase 정렬 + snake→camel 마이그레이션 |
| `lib/features/todo/data/models/todo_category_model.dart` | 동일 |
| `lib/features/todo/domain/repositories/todo_repository.dart` | `getTodoList` 시그니처에 `date` 추가 |
| `lib/features/todo/domain/usecases/get_todo_list_usecase.dart` | `date` 옵션 전달 |
| `lib/features/todo/data/repositories/local_todo_repository_impl.dart` | 인터페이스 변경 반영 (`date` 시그니처) |
| `lib/features/todo/presentation/providers/todo_provider.dart` | `todoRemoteDataSourceProvider` 추가, `todoRepositoryProvider` 인증 분기 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | `isAuthenticatedProvider` 추가 |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | `signOut/withdraw` 끝에 `_localTodoDataSource.clearAll()` 호출 |
| `lib/features/auth/presentation/providers/auth_provider.dart` (다른 위치) | `AuthRepositoryImpl` 생성자에 `LocalTodoDataSource` 주입 |
| `docs/api-specs/02_todo.md` | 오류 코드/동기화 전략 문구 갱신 |

---

## Phase 0 — Base URL 확인 (변경 없음)

### Task 0.1: EnvConfig base URL 검증

**Files:**
- Read: `lib/core/config/env_config.dart`

- [ ] **Step 1: 현재 base URL 확인**

Run: `grep apiBaseUrl lib/core/config/env_config.dart`
Expected: `static const apiBaseUrl = 'http://suh-project.synology.me:8099'` 또는 동등 환경값. `api-docs.json` 의 production 서버와 일치하면 통과.

- [ ] **Step 2: 일치 시 변경 없이 다음 Phase 로**

불일치 시 EnvConfig 만 수정 (별도 Task 분리). 그 외 코드 변경 없음.

---

## Phase 1 — 인프라 (Endpoint + Exception + Handler)

### Task 1.1: `api_endpoints.dart` 에 Todo/Category 상수 추가

**Files:**
- Modify: `lib/core/constants/api_endpoints.dart`

- [ ] **Step 1: 상수 추가**

```dart
abstract class ApiEndpoints {
  // ... Auth (기존) ...

  // ============================================
  // Todo
  // ============================================

  /// 할 일 목록 / 생성
  static const todos = '/api/todos';

  /// 할 일 단건 (수정/삭제)
  static String todoById(String id) => '/api/todos/$id';

  // ============================================
  // Todo Category
  // ============================================

  /// 카테고리 목록 / 생성
  static const todoCategories = '/api/todo-categories';

  /// 카테고리 단건 (수정/삭제)
  static String todoCategoryById(String id) => '/api/todo-categories/$id';
}
```

- [ ] **Step 2: `flutter analyze` 통과 확인**

Run: `flutter analyze lib/core/constants/api_endpoints.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/constants/api_endpoints.dart
git commit -m "feat : Todo·Category endpoint 상수 추가 #77"
```

---

### Task 1.2: 신규 Exception 4종 추가

**Files:**
- Modify: `lib/core/errors/app_exception.dart`

- [ ] **Step 1: 4 Exception 클래스 추가** (`ValidationException` 정의 아래에 삽입)

```dart
/// 할 일 없음 (404 TODO_NOT_FOUND)
class TodoNotFoundException extends AppException {
  const TodoNotFoundException({String? message, super.originalException})
      : super(
          message: message ?? '해당 할 일을 찾을 수 없습니다.',
          code: 'TODO_NOT_FOUND',
        );
}

/// 할 일 ID 중복 (409 TODO_ALREADY_EXISTS)
class TodoAlreadyExistsException extends AppException {
  const TodoAlreadyExistsException({String? message, super.originalException})
      : super(
          message: message ?? '동일 ID의 할 일이 이미 존재합니다.',
          code: 'TODO_ALREADY_EXISTS',
        );
}

/// 카테고리 없음 (404 CATEGORY_NOT_FOUND)
///
/// 발생 컨텍스트 2종:
/// - `POST /api/todos` (categoryIds 에 존재하지 않는 카테고리 포함)
/// - `PATCH/DELETE /api/todo-categories/{id}` (해당 카테고리 부재)
class CategoryNotFoundException extends AppException {
  const CategoryNotFoundException({String? message, super.originalException})
      : super(
          message: message ?? '해당 카테고리를 찾을 수 없습니다.',
          code: 'CATEGORY_NOT_FOUND',
        );
}

/// 카테고리 ID 중복 (409 CATEGORY_ALREADY_EXISTS)
class CategoryAlreadyExistsException extends AppException {
  const CategoryAlreadyExistsException({
    String? message,
    super.originalException,
  }) : super(
          message: message ?? '동일 ID의 카테고리가 이미 존재합니다.',
          code: 'CATEGORY_ALREADY_EXISTS',
        );
}
```

- [ ] **Step 2: `flutter analyze` 통과 확인**

Run: `flutter analyze lib/core/errors/app_exception.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/errors/app_exception.dart
git commit -m "feat : Todo·Category 도메인 Exception 4종 추가 #77"
```

---

### Task 1.3: `DioExceptionHandler` 의 switch 에 4 case 추가 (TDD)

**Files:**
- Modify: `lib/core/network/dio_exception_handler.dart`
- Test: `test/core/network/dio_exception_handler_test.dart`

- [ ] **Step 1: 실패 테스트 4개 추가**

```dart
// test/core/network/dio_exception_handler_test.dart 의 group(...) 안에 추가
test('TODO_NOT_FOUND code → TodoNotFoundException', () {
  final req = RequestOptions(path: '/api/todos/abc');
  final exc = DioExceptionHandler.handle(DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: 404,
      data: {'code': 'TODO_NOT_FOUND', 'message': '해당 할 일을 찾을 수 없습니다.'},
    ),
    type: DioExceptionType.badResponse,
  ));
  expect(exc, isA<TodoNotFoundException>());
  expect(exc.code, 'TODO_NOT_FOUND');
});

test('TODO_ALREADY_EXISTS code → TodoAlreadyExistsException', () {
  final req = RequestOptions(path: '/api/todos');
  final exc = DioExceptionHandler.handle(DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: 409,
      data: {'code': 'TODO_ALREADY_EXISTS', 'message': '동일 ID의 할 일이 이미 존재합니다.'},
    ),
    type: DioExceptionType.badResponse,
  ));
  expect(exc, isA<TodoAlreadyExistsException>());
});

test('CATEGORY_NOT_FOUND code → CategoryNotFoundException', () {
  final req = RequestOptions(path: '/api/todo-categories/abc');
  final exc = DioExceptionHandler.handle(DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: 404,
      data: {'code': 'CATEGORY_NOT_FOUND', 'message': '해당 카테고리를 찾을 수 없습니다.'},
    ),
    type: DioExceptionType.badResponse,
  ));
  expect(exc, isA<CategoryNotFoundException>());
});

test('CATEGORY_ALREADY_EXISTS code → CategoryAlreadyExistsException', () {
  final req = RequestOptions(path: '/api/todo-categories');
  final exc = DioExceptionHandler.handle(DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: 409,
      data: {'code': 'CATEGORY_ALREADY_EXISTS', 'message': '동일 ID의 카테고리가 이미 존재합니다.'},
    ),
    type: DioExceptionType.badResponse,
  ));
  expect(exc, isA<CategoryAlreadyExistsException>());
});
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/core/network/dio_exception_handler_test.dart`
Expected: 4개 신규 테스트 실패 — `Expected: <Instance of 'TodoNotFoundException'>` 등.

- [ ] **Step 3: handler 의 switch 에 4 case 추가**

`lib/core/network/dio_exception_handler.dart` 의 `case 'INTERNAL_SERVER_ERROR':` 아래에 삽입:

```dart
case 'TODO_NOT_FOUND':
  return TodoNotFoundException(
    message: apiError.message,
    originalException: e,
  );
case 'TODO_ALREADY_EXISTS':
  return TodoAlreadyExistsException(
    message: apiError.message,
    originalException: e,
  );
case 'CATEGORY_NOT_FOUND':
  return CategoryNotFoundException(
    message: apiError.message,
    originalException: e,
  );
case 'CATEGORY_ALREADY_EXISTS':
  return CategoryAlreadyExistsException(
    message: apiError.message,
    originalException: e,
  );
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/core/network/dio_exception_handler_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/network/dio_exception_handler.dart test/core/network/dio_exception_handler_test.dart
git commit -m "feat : DioExceptionHandler 에 Todo·Category code 4 case 매핑 #77"
```

---

## Phase 2 — Model camelCase 정렬

### Task 2.1: `TodoModel` JSON 키 camelCase 전환 + snake→camel 마이그레이션 (TDD)

**Files:**
- Modify: `lib/features/todo/data/models/todo_model.dart`
- Test: `test/features/todo/data/models/todo_model_test.dart` (신규)

- [ ] **Step 1: 테스트 파일 신규 + 실패 테스트 작성**

```dart
// test/features/todo/data/models/todo_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_model.dart';

void main() {
  group('TodoModel.fromJson (camelCase)', () {
    test('camelCase JSON 을 파싱한다', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'title': '수학 문제 풀기',
        'scheduledDates': ['2026-04-16'],
        'completedDates': ['2026-04-16'],
        'categoryIds': ['cat-1'],
        'estimatedMinutes': 60,
        'actualMinutes': 45,
        'createdAt': '2026-04-15T10:00:00Z',
        'updatedAt': '2026-04-16T09:30:00Z',
      };

      final model = TodoModel.fromJson(json);

      expect(model.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(model.title, '수학 문제 풀기');
      expect(model.scheduledDates.first, DateTime.parse('2026-04-16'));
      expect(model.completedDates.first, DateTime.parse('2026-04-16'));
      expect(model.categoryIds, ['cat-1']);
      expect(model.estimatedMinutes, 60);
      expect(model.actualMinutes, 45);
    });

    test('toJson 결과가 camelCase 키를 사용한다', () {
      final model = TodoModel(
        id: 'id-1',
        title: 't',
        scheduledDates: const [],
        completedDates: const [],
        categoryIds: const [],
        createdAt: DateTime.parse('2026-04-15T10:00:00Z'),
        updatedAt: DateTime.parse('2026-04-15T10:00:00Z'),
      );

      final json = model.toJson();

      expect(json.keys, containsAll([
        'id',
        'title',
        'scheduledDates',
        'completedDates',
        'categoryIds',
        'createdAt',
        'updatedAt',
      ]));
      expect(json.containsKey('scheduled_dates'), isFalse);
      expect(json.containsKey('category_ids'), isFalse);
    });
  });

  group('TodoModel._migrateJson (구버전 snake_case 캐시 호환)', () {
    test('snake_case 키 → camelCase 키 변환', () {
      final oldJson = {
        'id': 'id-1',
        'title': 't',
        'scheduled_dates': ['2026-04-16'],
        'completed_dates': [],
        'category_ids': ['cat-1'],
        'estimated_minutes': 30,
        'actual_minutes': null,
        'created_at': '2026-04-15T10:00:00Z',
        'updated_at': '2026-04-15T10:00:00Z',
      };

      final model = TodoModel.fromJson(oldJson);

      expect(model.scheduledDates, isNotEmpty);
      expect(model.categoryIds, ['cat-1']);
      expect(model.estimatedMinutes, 30);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/todo/data/models/todo_model_test.dart`
Expected: `toJson 결과가 camelCase 키를 사용한다` FAIL — 현재는 snake_case.

- [ ] **Step 3: `TodoModel` 의 `@JsonKey` 제거 (camelCase 가 곧 JSON 키)**

```dart
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    @Default([]) List<DateTime> scheduledDates,
    @Default([]) List<DateTime> completedDates,
    @Default([]) List<String> categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(_migrateJson(json));

  // _migrateJson 은 다음 step 에서 보강
}
```

- [ ] **Step 4: `_migrateJson` 에 snake→camel 변환 추가**

기존 마이그레이션(단일 날짜·bool 형식) 위에 snake→camel 키 변환을 먼저 수행:

```dart
static Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
  final migrated = Map<String, dynamic>.from(json);

  // 0) snake_case → camelCase 키 변환 (구버전 SharedPreferences 캐시 호환)
  const renames = {
    'scheduled_dates': 'scheduledDates',
    'completed_dates': 'completedDates',
    'category_ids': 'categoryIds',
    'estimated_minutes': 'estimatedMinutes',
    'actual_minutes': 'actualMinutes',
    'created_at': 'createdAt',
    'updated_at': 'updatedAt',
    'scheduled_date': 'scheduledDate',  // 더 옛 형식
    'category_id': 'categoryId',
  };
  for (final entry in renames.entries) {
    if (migrated.containsKey(entry.key) && !migrated.containsKey(entry.value)) {
      migrated[entry.value] = migrated[entry.key];
      migrated.remove(entry.key);
    }
  }

  // 1) scheduledDate (단일) → scheduledDates (배열)
  if (!migrated.containsKey('scheduledDates') &&
      migrated.containsKey('scheduledDate')) {
    final oldDate = migrated['scheduledDate'];
    migrated['scheduledDates'] = oldDate != null ? [oldDate] : [];
    migrated.remove('scheduledDate');
  }

  // 2) completed (bool) → completedDates (배열)
  if (!migrated.containsKey('completedDates') &&
      migrated.containsKey('completed')) {
    final wasCompleted = migrated['completed'] as bool? ?? false;
    if (wasCompleted) {
      final scheduledDates = migrated['scheduledDates'] as List<dynamic>?;
      if (scheduledDates != null && scheduledDates.isNotEmpty) {
        migrated['completedDates'] = List<dynamic>.from(scheduledDates);
      } else {
        migrated['completedDates'] = [
          migrated['updatedAt'] ?? DateTime.now().toIso8601String(),
        ];
      }
    } else {
      migrated['completedDates'] = [];
    }
    migrated.remove('completed');
  }

  // 3) categoryId (단일) → categoryIds (배열)
  if (!migrated.containsKey('categoryIds') &&
      migrated.containsKey('categoryId')) {
    final oldId = migrated['categoryId'] as String?;
    migrated['categoryIds'] = oldId != null ? [oldId] : <String>[];
    migrated.remove('categoryId');
  }

  return migrated;
}
```

- [ ] **Step 5: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `todo_model.freezed.dart`, `todo_model.g.dart` 재생성. 성공 메시지.

- [ ] **Step 6: 테스트 통과 확인**

Run: `flutter test test/features/todo/data/models/todo_model_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 7: 커밋**

```bash
git add lib/features/todo/data/models/todo_model.dart lib/features/todo/data/models/todo_model.g.dart lib/features/todo/data/models/todo_model.freezed.dart test/features/todo/data/models/todo_model_test.dart
git commit -m "feat : TodoModel JSON 키 camelCase 정렬 + 구버전 캐시 마이그레이션 #77"
```

---

### Task 2.2: `TodoCategoryModel` JSON 키 camelCase 전환 (TDD)

**Files:**
- Modify: `lib/features/todo/data/models/todo_category_model.dart`
- Test: `test/features/todo/data/models/todo_category_model_test.dart` (신규)

- [ ] **Step 1: 테스트 파일 신규 + 실패 테스트 작성**

```dart
// test/features/todo/data/models/todo_category_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_category_model.dart';

void main() {
  group('TodoCategoryModel.fromJson (camelCase)', () {
    test('camelCase JSON 을 파싱한다', () {
      final json = {
        'id': 'cat-1',
        'name': '수학',
        'iconId': 'math_icon',
        'positionX': 0.3,
        'positionY': 0.5,
        'createdAt': '2026-04-01T00:00:00Z',
        'updatedAt': null,
      };

      final model = TodoCategoryModel.fromJson(json);

      expect(model.id, 'cat-1');
      expect(model.name, '수학');
      expect(model.iconId, 'math_icon');
      expect(model.positionX, 0.3);
      expect(model.positionY, 0.5);
      expect(model.updatedAt, isNull);
    });

    test('toJson 결과가 camelCase 키를 사용한다', () {
      final model = TodoCategoryModel(
        id: 'cat-1',
        name: '수학',
        createdAt: DateTime.parse('2026-04-01T00:00:00Z'),
      );

      final json = model.toJson();

      expect(json.keys, containsAll(['id', 'name', 'createdAt']));
      expect(json.containsKey('icon_id'), isFalse);
      expect(json.containsKey('position_x'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });
  });

  group('TodoCategoryModel snake_case 캐시 마이그레이션', () {
    test('snake_case 키 → camelCase 키 변환', () {
      final oldJson = {
        'id': 'cat-1',
        'name': '수학',
        'icon_id': 'math_icon',
        'position_x': 0.3,
        'position_y': 0.5,
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': null,
      };

      final model = TodoCategoryModel.fromJson(oldJson);

      expect(model.iconId, 'math_icon');
      expect(model.positionX, 0.3);
      expect(model.updatedAt, isNull);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/todo/data/models/todo_category_model_test.dart`
Expected: `toJson 결과가 camelCase 키를 사용한다` FAIL.

- [ ] **Step 3: 모델 수정 — `@JsonKey` 제거 + 마이그레이션 헬퍼 추가**

```dart
@freezed
class TodoCategoryModel with _$TodoCategoryModel {
  const factory TodoCategoryModel({
    required String id,
    required String name,
    String? iconId,
    double? positionX,
    double? positionY,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TodoCategoryModelFromJson(_migrateJson(json));

  static Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
    final migrated = Map<String, dynamic>.from(json);
    const renames = {
      'icon_id': 'iconId',
      'position_x': 'positionX',
      'position_y': 'positionY',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
    };
    for (final entry in renames.entries) {
      if (migrated.containsKey(entry.key) && !migrated.containsKey(entry.value)) {
        migrated[entry.value] = migrated[entry.key];
        migrated.remove(entry.key);
      }
    }
    return migrated;
  }
}
```

- [ ] **Step 4: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `todo_category_model.freezed.dart`, `todo_category_model.g.dart` 재생성.

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/todo/data/models/todo_category_model_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 6: 커밋**

```bash
git add lib/features/todo/data/models/todo_category_model.dart lib/features/todo/data/models/todo_category_model.g.dart lib/features/todo/data/models/todo_category_model.freezed.dart test/features/todo/data/models/todo_category_model_test.dart
git commit -m "feat : TodoCategoryModel JSON 키 camelCase 정렬 + 구버전 캐시 마이그레이션 #77"
```

---

## Phase 3 — Request DTO 4종

### Task 3.1: `TodoCreateRequestModel` (TDD)

**Files:**
- Create: `lib/features/todo/data/models/todo_create_request_model.dart`
- Test: `test/features/todo/data/models/todo_create_request_model_test.dart`

- [ ] **Step 1: 테스트 작성 (실패)**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_create_request_model.dart';

void main() {
  group('TodoCreateRequestModel', () {
    test('필수 필드(title) 포함 직렬화', () {
      const model = TodoCreateRequestModel(title: '수학');
      final json = model.toJson();
      expect(json['title'], '수학');
      expect(json.containsKey('id'), isFalse);  // null 제외
    });

    test('전체 필드 직렬화', () {
      final model = TodoCreateRequestModel(
        id: 'id-1',
        title: '수학',
        categoryIds: const ['cat-1'],
        estimatedMinutes: 60,
        scheduledDates: const ['2026-04-16'],
      );
      final json = model.toJson();
      expect(json['id'], 'id-1');
      expect(json['categoryIds'], ['cat-1']);
      expect(json['estimatedMinutes'], 60);
      expect(json['scheduledDates'], ['2026-04-16']);
    });
  });
}
```

- [ ] **Step 2: 모델 파일 작성**

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_create_request_model.freezed.dart';
part 'todo_create_request_model.g.dart';

@Freezed(toJson: true, fromJson: false)
class TodoCreateRequestModel with _$TodoCreateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory TodoCreateRequestModel({
    String? id,
    required String title,
    List<String>? categoryIds,
    int? estimatedMinutes,
    List<String>? scheduledDates,  // YYYY-MM-DD
  }) = _TodoCreateRequestModel;
}
```

- [ ] **Step 3: build_runner 실행 + 테스트 통과**

Run: `flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/todo/data/models/todo_create_request_model_test.dart`
Expected: 생성 성공 + 모든 테스트 PASS.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/data/models/todo_create_request_model.dart lib/features/todo/data/models/todo_create_request_model.g.dart lib/features/todo/data/models/todo_create_request_model.freezed.dart test/features/todo/data/models/todo_create_request_model_test.dart
git commit -m "feat : TodoCreateRequestModel DTO 추가 #77"
```

---

### Task 3.2: `TodoUpdateRequestModel` (`includeIfNull: false`) (TDD)

**Files:**
- Create: `lib/features/todo/data/models/todo_update_request_model.dart`
- Test: `test/features/todo/data/models/todo_update_request_model_test.dart`

- [ ] **Step 1: 테스트 작성 (실패)**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_update_request_model.dart';

void main() {
  group('TodoUpdateRequestModel', () {
    test('빈 객체 직렬화 → 빈 JSON', () {
      const model = TodoUpdateRequestModel();
      expect(model.toJson(), isEmpty);
    });

    test('title 만 변경 — null 필드 제외 (PATCH semantics)', () {
      const model = TodoUpdateRequestModel(title: '새 제목');
      final json = model.toJson();
      expect(json, {'title': '새 제목'});
      expect(json.containsKey('completedDates'), isFalse);
      expect(json.containsKey('estimatedMinutes'), isFalse);
    });

    test('completedDates 를 빈 배열로 전송 → 명시적 모두 제거', () {
      const model = TodoUpdateRequestModel(completedDates: []);
      final json = model.toJson();
      expect(json, {'completedDates': <String>[]});  // 빈 배열도 명시
    });

    test('전체 필드 직렬화', () {
      const model = TodoUpdateRequestModel(
        title: 't',
        scheduledDates: ['2026-04-16'],
        completedDates: ['2026-04-16'],
        categoryIds: ['cat-1'],
        estimatedMinutes: 30,
        actualMinutes: 25,
      );
      final json = model.toJson();
      expect(json.keys, hasLength(6));
    });
  });
}
```

- [ ] **Step 2: 모델 파일 작성**

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_update_request_model.freezed.dart';
part 'todo_update_request_model.g.dart';

/// PATCH /api/todos/{todoId} 요청 본문
///
/// 전송하지 않은 필드는 기존 값 유지, 빈 배열은 명시적 모두 제거.
@Freezed(toJson: true, fromJson: false)
class TodoUpdateRequestModel with _$TodoUpdateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory TodoUpdateRequestModel({
    String? title,
    List<String>? scheduledDates,
    List<String>? completedDates,
    List<String>? categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
  }) = _TodoUpdateRequestModel;
}
```

- [ ] **Step 3: build_runner 실행 + 테스트 통과**

Run: `flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/todo/data/models/todo_update_request_model_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/data/models/todo_update_request_model.dart lib/features/todo/data/models/todo_update_request_model.g.dart lib/features/todo/data/models/todo_update_request_model.freezed.dart test/features/todo/data/models/todo_update_request_model_test.dart
git commit -m "feat : TodoUpdateRequestModel DTO 추가 (PATCH semantics) #77"
```

---

### Task 3.3: `CategoryCreateRequestModel` (TDD)

**Files:**
- Create: `lib/features/todo/data/models/category_create_request_model.dart`
- Test: `test/features/todo/data/models/category_create_request_model_test.dart`

- [ ] **Step 1: 테스트 작성**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/category_create_request_model.dart';

void main() {
  group('CategoryCreateRequestModel', () {
    test('필수 필드(name) 포함 직렬화', () {
      const model = CategoryCreateRequestModel(name: '수학');
      final json = model.toJson();
      expect(json, {'name': '수학'});
    });

    test('전체 필드 직렬화', () {
      const model = CategoryCreateRequestModel(
        id: 'cat-1',
        name: '수학',
        iconId: 'math_icon',
        positionX: 0.3,
        positionY: 0.5,
      );
      final json = model.toJson();
      expect(json['iconId'], 'math_icon');
      expect(json['positionX'], 0.3);
      expect(json['positionY'], 0.5);
    });
  });
}
```

- [ ] **Step 2: 모델 파일 작성**

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_create_request_model.freezed.dart';
part 'category_create_request_model.g.dart';

@Freezed(toJson: true, fromJson: false)
class CategoryCreateRequestModel with _$CategoryCreateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CategoryCreateRequestModel({
    String? id,
    required String name,
    String? iconId,
    double? positionX,
    double? positionY,
  }) = _CategoryCreateRequestModel;
}
```

- [ ] **Step 3: build_runner 실행 + 테스트 통과**

Run: `flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/todo/data/models/category_create_request_model_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/data/models/category_create_request_model.dart lib/features/todo/data/models/category_create_request_model.g.dart lib/features/todo/data/models/category_create_request_model.freezed.dart test/features/todo/data/models/category_create_request_model_test.dart
git commit -m "feat : CategoryCreateRequestModel DTO 추가 #77"
```

---

### Task 3.4: `CategoryUpdateRequestModel` (TDD)

**Files:**
- Create: `lib/features/todo/data/models/category_update_request_model.dart`
- Test: `test/features/todo/data/models/category_update_request_model_test.dart`

- [ ] **Step 1: 테스트 작성**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/category_update_request_model.dart';

void main() {
  group('CategoryUpdateRequestModel', () {
    test('빈 객체 → 빈 JSON', () {
      const model = CategoryUpdateRequestModel();
      expect(model.toJson(), isEmpty);
    });

    test('name 만 변경 — null 필드 제외', () {
      const model = CategoryUpdateRequestModel(name: '수학(심화)');
      expect(model.toJson(), {'name': '수학(심화)'});
    });

    test('positionX/Y 만 변경 — 드래그앤드롭 케이스', () {
      const model = CategoryUpdateRequestModel(positionX: 0.4, positionY: 0.6);
      final json = model.toJson();
      expect(json, {'positionX': 0.4, 'positionY': 0.6});
    });
  });
}
```

- [ ] **Step 2: 모델 파일 작성**

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_update_request_model.freezed.dart';
part 'category_update_request_model.g.dart';

@Freezed(toJson: true, fromJson: false)
class CategoryUpdateRequestModel with _$CategoryUpdateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CategoryUpdateRequestModel({
    String? name,
    String? iconId,
    double? positionX,
    double? positionY,
  }) = _CategoryUpdateRequestModel;
}
```

- [ ] **Step 3: build_runner 실행 + 테스트 통과**

Run: `flutter pub run build_runner build --delete-conflicting-outputs && flutter test test/features/todo/data/models/category_update_request_model_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/data/models/category_update_request_model.dart lib/features/todo/data/models/category_update_request_model.g.dart lib/features/todo/data/models/category_update_request_model.freezed.dart test/features/todo/data/models/category_update_request_model_test.dart
git commit -m "feat : CategoryUpdateRequestModel DTO 추가 #77"
```

---

## Phase 4 — Retrofit DataSource

### Task 4.1: `TodoRemoteDataSource` 정의 (8 엔드포인트)

**Files:**
- Create: `lib/features/todo/data/datasources/todo_remote_datasource.dart`

> **TDD 노트**: Retrofit 인터페이스 자체는 코드 생성으로 만들어지는 클래스라 단독 단위 테스트가 무의미하다. 동작 검증은 Task 5.2 의 Repository 테스트에서 mocktail 로 인터페이스를 mock 하여 수행.

- [ ] **Step 1: 파일 작성**

```dart
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
```

- [ ] **Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `todo_remote_datasource.g.dart` 생성 성공.

- [ ] **Step 3: `flutter analyze` 통과**

Run: `flutter analyze lib/features/todo/data/datasources/`
Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/data/datasources/todo_remote_datasource.dart lib/features/todo/data/datasources/todo_remote_datasource.g.dart
git commit -m "feat : TodoRemoteDataSource (Retrofit 8 엔드포인트) 추가 #77"
```

---

## Phase 5 — Repository 합성

### Task 5.1: `TodoRepository.getTodoList` 시그니처에 `date` 추가

**Files:**
- Modify: `lib/features/todo/domain/repositories/todo_repository.dart`
- Modify: `lib/features/todo/domain/usecases/get_todo_list_usecase.dart`
- Modify: `lib/features/todo/data/repositories/local_todo_repository_impl.dart`

> **TDD 노트**: 시그니처 변경은 컴파일러가 검증한다. 단독 테스트는 Task 5.2 에서 함께.

- [ ] **Step 1: `TodoRepository` 인터페이스 갱신**

```dart
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodoList({DateTime? date, String? categoryId});

  // 이하 변경 없음
  Future<TodoEntity> createTodo({
    required String title,
    List<String> categoryIds = const [],
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  });
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);

  Future<List<TodoCategoryEntity>> getCategories();
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? iconId,
  });
  Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category);
  Future<void> deleteCategory(String id);

  Future<void> clearAll();
}
```

- [ ] **Step 2: `GetTodoListUseCase.execute` 시그니처 갱신**

```dart
class GetTodoListUseCase {
  final TodoRepository _repository;
  GetTodoListUseCase(this._repository);

  Future<List<TodoEntity>> execute({DateTime? date, String? categoryId}) {
    return _repository.getTodoList(date: date, categoryId: categoryId);
  }
}
```

- [ ] **Step 3: `LocalTodoRepositoryImpl.getTodoList` 갱신 (date 무시, 메모리 필터)**

```dart
@override
Future<List<TodoEntity>> getTodoList({DateTime? date, String? categoryId}) async {
  final models = _dataSource.getTodos();
  var filtered = models;
  if (categoryId != null) {
    filtered = filtered.where((m) => m.categoryIds.contains(categoryId)).toList();
  }
  if (date != null) {
    final normalized = DateTime(date.year, date.month, date.day);
    filtered = filtered.where((m) =>
      m.scheduledDates.any((d) =>
        DateTime(d.year, d.month, d.day) == normalized)).toList();
  }
  return filtered.map((m) => m.toEntity()).toList();
}
```

- [ ] **Step 4: `flutter analyze` 통과**

Run: `flutter analyze lib/features/todo/`
Expected: `No issues found!`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/todo/domain/repositories/todo_repository.dart lib/features/todo/domain/usecases/get_todo_list_usecase.dart lib/features/todo/data/repositories/local_todo_repository_impl.dart
git commit -m "refactor : TodoRepository.getTodoList 에 date 필터 추가 #77"
```

---

### Task 5.2: `TodoRepositoryImpl` (Remote+Cache) 신설 (TDD)

**Files:**
- Create: `lib/features/todo/data/repositories/todo_repository_impl.dart`
- Test: `test/features/todo/data/repositories/todo_repository_impl_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (실패)**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/todo/data/datasources/local_todo_datasource.dart';
import 'package:space_study_ship/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:space_study_ship/features/todo/data/models/todo_create_request_model.dart';
import 'package:space_study_ship/features/todo/data/models/todo_model.dart';
import 'package:space_study_ship/features/todo/data/models/todo_update_request_model.dart';
import 'package:space_study_ship/features/todo/data/repositories/todo_repository_impl.dart';

class _MockRemote extends Mock implements TodoRemoteDataSource {}

class _MockCache extends Mock implements LocalTodoDataSource {}

class _FakeCreateReq extends Fake implements TodoCreateRequestModel {}

class _FakeUpdateReq extends Fake implements TodoUpdateRequestModel {}

TodoModel _sampleModel({String id = 'id-1'}) => TodoModel(
      id: id,
      title: '수학',
      createdAt: DateTime.parse('2026-05-23T00:00:00Z'),
      updatedAt: DateTime.parse('2026-05-23T00:00:00Z'),
    );

DioException _networkError(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
    );

DioException _domainError(String path, int status, String code) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: status,
      data: {'code': code, 'message': 'msg'},
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late TodoRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeCreateReq());
    registerFallbackValue(_FakeUpdateReq());
  });

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    repo = TodoRepositoryImpl(remote: remote, cache: cache);

    when(() => cache.saveTodos(any())).thenAnswer((_) async {});
    when(() => cache.saveCategories(any())).thenAnswer((_) async {});
    when(() => cache.getTodos()).thenReturn([]);
    when(() => cache.getCategories()).thenReturn([]);
  });

  group('getTodoList', () {
    test('서버 성공 → 캐시 갱신 + Entity 반환', () async {
      final models = [_sampleModel()];
      when(() => remote.getTodos(date: any(named: 'date'), categoryId: any(named: 'categoryId')))
          .thenAnswer((_) async => models);

      final result = await repo.getTodoList();

      expect(result, hasLength(1));
      verify(() => cache.saveTodos(models)).called(1);
    });

    test('네트워크 실패 → 캐시 폴백', () async {
      when(() => remote.getTodos(date: any(named: 'date'), categoryId: any(named: 'categoryId')))
          .thenThrow(_networkError('/api/todos'));
      when(() => cache.getTodos()).thenReturn([_sampleModel()]);

      final result = await repo.getTodoList();

      expect(result, hasLength(1));
      verifyNever(() => cache.saveTodos(any()));
    });

    test('도메인 에러 (401) → AuthException throw', () async {
      when(() => remote.getTodos(date: any(named: 'date'), categoryId: any(named: 'categoryId')))
          .thenThrow(_domainError('/api/todos', 401, 'UNAUTHENTICATED_REQUEST'));

      expect(() => repo.getTodoList(), throwsA(isA<UnauthenticatedRequestException>()));
    });
  });

  group('createTodo', () {
    test('서버 성공 → 캐시에 추가', () async {
      final created = _sampleModel(id: 'new-1');
      when(() => remote.createTodo(any())).thenAnswer((_) async => created);

      final entity = await repo.createTodo(title: '수학');

      expect(entity.id, 'new-1');
      verify(() => cache.saveTodos([created])).called(1);
    });

    test('CATEGORY_NOT_FOUND (404) → CategoryNotFoundException', () async {
      when(() => remote.createTodo(any()))
          .thenThrow(_domainError('/api/todos', 404, 'CATEGORY_NOT_FOUND'));

      expect(
        () => repo.createTodo(title: '수학', categoryIds: ['missing']),
        throwsA(isA<CategoryNotFoundException>()),
      );
      verifyNever(() => cache.saveTodos(any()));
    });
  });

  group('deleteTodo', () {
    test('서버 성공 → 캐시에서 제거', () async {
      when(() => cache.getTodos()).thenReturn([_sampleModel(id: 'a'), _sampleModel(id: 'b')]);
      when(() => remote.deleteTodo('a')).thenAnswer((_) async {});

      await repo.deleteTodo('a');

      final captured = verify(() => cache.saveTodos(captureAny())).captured.single
          as List<TodoModel>;
      expect(captured.map((m) => m.id), ['b']);
    });

    test('TODO_NOT_FOUND (404) → TodoNotFoundException', () async {
      when(() => remote.deleteTodo('a'))
          .thenThrow(_domainError('/api/todos/a', 404, 'TODO_NOT_FOUND'));

      expect(() => repo.deleteTodo('a'), throwsA(isA<TodoNotFoundException>()));
    });
  });

  group('getCategories', () {
    test('서버 성공 → 캐시 갱신', () async {
      when(() => remote.getCategories()).thenAnswer((_) async => []);
      final result = await repo.getCategories();
      expect(result, isEmpty);
      verify(() => cache.saveCategories(any())).called(1);
    });

    test('네트워크 실패 → 캐시 폴백', () async {
      when(() => remote.getCategories()).thenThrow(_networkError('/api/todo-categories'));
      final result = await repo.getCategories();
      expect(result, isEmpty);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/todo/data/repositories/todo_repository_impl_test.dart`
Expected: 파일 없음 또는 컴파일 에러.

- [ ] **Step 3: `TodoRepositoryImpl` 구현**

```dart
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_todo_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/category_create_request_model.dart';
import '../models/category_update_request_model.dart';
import '../models/todo_category_model.dart';
import '../models/todo_create_request_model.dart';
import '../models/todo_model.dart';
import '../models/todo_update_request_model.dart';

/// 서버 source of truth + 로컬 캐시 폴백
///
/// 동기화 큐·재시도는 후속 사이클.
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remote;
  final LocalTodoDataSource cache;
  final Uuid _uuid;

  TodoRepositoryImpl({
    required this.remote,
    required this.cache,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  // === Todos ===

  @override
  Future<List<TodoEntity>> getTodoList({DateTime? date, String? categoryId}) async {
    try {
      final models = await remote.getTodos(
        date: date != null ? _dateFmt.format(date) : null,
        categoryId: categoryId,
      );
      await cache.saveTodos(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getTodos().map((m) => m.toEntity()).toList();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    List<String> categoryIds = const [],
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  }) async {
    try {
      final request = TodoCreateRequestModel(
        id: _uuid.v4(),
        title: title,
        categoryIds: categoryIds.isEmpty ? null : categoryIds,
        estimatedMinutes: estimatedMinutes,
        scheduledDates: scheduledDates?.map(_dateFmt.format).toList(),
      );
      final created = await remote.createTodo(request);
      final updated = [...cache.getTodos(), created];
      await cache.saveTodos(updated);
      return created.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    try {
      final request = TodoUpdateRequestModel(
        title: todo.title,
        scheduledDates: todo.scheduledDates.map(_dateFmt.format).toList(),
        completedDates: todo.completedDates.map(_dateFmt.format).toList(),
        categoryIds: todo.categoryIds,
        estimatedMinutes: todo.estimatedMinutes,
        actualMinutes: todo.actualMinutes,
      );
      final updated = await remote.updateTodo(todo.id, request);
      final cached = cache.getTodos();
      final replaced = cached.map((m) => m.id == updated.id ? updated : m).toList();
      await cache.saveTodos(replaced);
      return updated.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await remote.deleteTodo(id);
      final cached = cache.getTodos();
      await cache.saveTodos(cached.where((m) => m.id != id).toList());
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  // === Categories ===

  @override
  Future<List<TodoCategoryEntity>> getCategories() async {
    try {
      final models = await remote.getCategories();
      await cache.saveCategories(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getCategories().map((m) => m.toEntity()).toList();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? iconId,
  }) async {
    try {
      final request = CategoryCreateRequestModel(
        id: _uuid.v4(),
        name: name,
        iconId: iconId,
      );
      final created = await remote.createCategory(request);
      await cache.saveCategories([...cache.getCategories(), created]);
      return created.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category) async {
    try {
      final request = CategoryUpdateRequestModel(
        name: category.name,
        iconId: category.iconId,
        positionX: category.positionX,
        positionY: category.positionY,
      );
      final updated = await remote.updateCategory(category.id, request);
      final cached = cache.getCategories();
      await cache.saveCategories(
        cached.map((c) => c.id == updated.id ? updated : c).toList(),
      );
      return updated.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await remote.deleteCategory(id);
      // 서버가 연관 Todo 의 categoryIds 자동 제거. 로컬 캐시도 동일 정리.
      final cachedTodos = cache.getTodos().map((t) {
        if (t.categoryIds.contains(id)) {
          return t.copyWith(
            categoryIds: t.categoryIds.where((cid) => cid != id).toList(),
          );
        }
        return t;
      }).toList();
      await cache.saveTodos(cachedTodos);
      await cache.saveCategories(
        cache.getCategories().where((c) => c.id != id).toList(),
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> clearAll() async {
    await cache.clearAll();
  }

  // === Helpers ===

  /// 네트워크 실패 판정 (D-11): timeout/connection/unknown 만 폴백 대상
  static bool _isNetworkFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/todo/data/repositories/todo_repository_impl_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/todo/data/repositories/todo_repository_impl.dart test/features/todo/data/repositories/todo_repository_impl_test.dart
git commit -m "feat : TodoRepositoryImpl (Remote+Cache, server-first 폴백) 추가 #77"
```

---

## Phase 6 — Provider 체인 갱신

### Task 6.1: `isAuthenticatedProvider` 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

- [ ] **Step 1: Provider 추가** (`authNotifierProvider` 정의 근처에 추가)

```dart
/// 현재 사용자가 인증되어 있는지 여부 — Todo Provider 등의 분기에 사용
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authNotifierProvider).valueOrNull != null;
}
```

- [ ] **Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `auth_provider.g.dart` 재생성 — `isAuthenticatedProvider` 노출.

- [ ] **Step 3: `flutter analyze` 통과**

Run: `flutter analyze lib/features/auth/`
Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart lib/features/auth/presentation/providers/auth_provider.g.dart
git commit -m "feat : isAuthenticatedProvider 추가 #77"
```

---

### Task 6.2: `todoRemoteDataSourceProvider` + 인증 분기 `todoRepositoryProvider`

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

- [ ] **Step 1: import 추가**

```dart
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
```

- [ ] **Step 2: `todoRemoteDataSourceProvider` 추가, `todoRepositoryProvider` 변경**

```dart
// === DataSource ===

@riverpod
LocalTodoDataSource localTodoDataSource(Ref ref) {
  throw StateError(
    'LocalTodoDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
TodoRemoteDataSource todoRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return TodoRemoteDataSource(dio);
}

// === Repository (인증 상태에 따라 분기) ===

@riverpod
TodoRepository todoRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final cache = ref.watch(localTodoDataSourceProvider);

  if (isAuthenticated) {
    return TodoRepositoryImpl(
      remote: ref.watch(todoRemoteDataSourceProvider),
      cache: cache,
    );
  }
  return LocalTodoRepositoryImpl(cache);
}
```

- [ ] **Step 3: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `todo_provider.g.dart` 재생성 — `todoRemoteDataSourceProvider` 노출.

- [ ] **Step 4: `flutter analyze` 통과**

Run: `flutter analyze lib/features/todo/`
Expected: `No issues found!`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart lib/features/todo/presentation/providers/todo_provider.g.dart
git commit -m "feat : todoRepositoryProvider 인증 상태에 따라 Remote/Local 분기 #77"
```

---

### Task 6.3: `todoRepositoryProvider` 분기 회귀 테스트 (TDD)

**Files:**
- Test: `test/features/todo/presentation/providers/todo_provider_test.dart` (신규)

- [ ] **Step 1: 테스트 작성**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/todo/data/datasources/local_todo_datasource.dart';
import 'package:space_study_ship/features/todo/data/repositories/local_todo_repository_impl.dart';
import 'package:space_study_ship/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:space_study_ship/features/todo/presentation/providers/todo_provider.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => container.dispose());

  group('todoRepositoryProvider 분기', () {
    test('미인증 상태 → LocalTodoRepositoryImpl 반환', () {
      container = ProviderContainer(
        overrides: [
          localTodoDataSourceProvider.overrideWithValue(LocalTodoDataSource(prefs)),
          authNotifierProvider.overrideWith(_FakeAuth(null).build),
        ],
      );

      final repo = container.read(todoRepositoryProvider);

      expect(repo, isA<LocalTodoRepositoryImpl>());
    });

    test('인증 상태 → TodoRepositoryImpl 반환', () {
      container = ProviderContainer(
        overrides: [
          localTodoDataSourceProvider.overrideWithValue(LocalTodoDataSource(prefs)),
          authNotifierProvider.overrideWith(_FakeAuth(_dummyResult()).build),
        ],
      );

      final repo = container.read(todoRepositoryProvider);

      expect(repo, isA<TodoRepositoryImpl>());
    });
  });
}

AuthResultEntity _dummyResult() => const AuthResultEntity(
      memberId: 1,
      nickname: 'tester',
      isNewMember: false,
    );

class _FakeAuth extends AuthNotifier {
  _FakeAuth(this._initial);
  final AuthResultEntity? _initial;

  @override
  Future<AuthResultEntity?> build() async => _initial;
}
```

- [ ] **Step 2: 테스트 실패 확인 → 통과 확인 (구현은 Task 6.2 에서 이미 완료)**

Run: `flutter test test/features/todo/presentation/providers/todo_provider_test.dart`
Expected: 두 테스트 모두 PASS.

> ⚠️ `AuthNotifier` override 가 build() 의 부수효과(`forceLogoutCallback 등록` 등) 때문에 깨질 가능성이 있다. 그럴 경우 `authNotifierProvider` 대신 `isAuthenticatedProvider` 자체를 override 하는 더 단순한 방식으로 전환:
> ```dart
> isAuthenticatedProvider.overrideWith((ref) => true),
> ```
> Task 6.1 이후 `isAuthenticatedProvider` 가 노출되므로 가능.

- [ ] **Step 3: 커밋**

```bash
git add test/features/todo/presentation/providers/todo_provider_test.dart
git commit -m "test : todoRepositoryProvider 인증 분기 회귀 테스트 #77"
```

---

## Phase 7 — Auth Hook (로그아웃·탈퇴 시 Todo 캐시 정리)

### Task 7.1: `AuthRepositoryImpl.signOut/withdraw` 끝에 `LocalTodoDataSource.clearAll()` 호출 (TDD)

**Files:**
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart` (DI 주입)
- Modify: `test/features/auth/data/repositories/auth_repository_impl_test.dart`

- [ ] **Step 1: 기존 auth_repository_impl_test 에 실패 테스트 추가**

```dart
// 기존 group(...) 옆에 새 group 추가
class _MockLocalTodo extends Mock implements LocalTodoDataSource {}

// setUp 변경:
//   late _MockLocalTodo localTodo;
//   ... 등록 + repo 생성자에 주입

group('Todo 캐시 정리', () {
  test('signOut 성공 시 LocalTodoDataSource.clearAll 호출', () async {
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'rt');
    when(() => remote.logout(any())).thenAnswer((_) async {});
    when(() => firebase.signOut()).thenAnswer((_) async {});
    when(() => storage.clearTokens()).thenAnswer((_) async {});
    when(() => localTodo.clearAll()).thenAnswer((_) async {});

    await repo.signOut();

    verify(() => localTodo.clearAll()).called(1);
  });

  test('withdraw 성공 시 LocalTodoDataSource.clearAll 호출', () async {
    when(() => remote.withdraw()).thenAnswer((_) async {});
    when(() => firebase.signOut()).thenAnswer((_) async {});
    when(() => storage.clearTokens()).thenAnswer((_) async {});
    when(() => localTodo.clearAll()).thenAnswer((_) async {});

    await repo.withdraw();

    verify(() => localTodo.clearAll()).called(1);
  });
});
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart`
Expected: 두 신규 테스트 실패 — `_MockLocalTodo` 미주입.

- [ ] **Step 3: `AuthRepositoryImpl` 에 `LocalTodoDataSource` 주입 + clearAll 호출**

`lib/features/auth/data/repositories/auth_repository_impl.dart`:

```dart
// import 추가
import '../../../todo/data/datasources/local_todo_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  // ... 기존 필드 ...
  final LocalTodoDataSource _localTodoDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource firebaseAuthDataSource,
    required AuthRemoteDataSource authRemoteDataSource,
    required SecureTokenStorage tokenStorage,
    required LocalTodoDataSource localTodoDataSource,
    // ... 기존 named param ...
  })  : _firebaseAuthDataSource = firebaseAuthDataSource,
        _authRemoteDataSource = authRemoteDataSource,
        _tokenStorage = tokenStorage,
        _localTodoDataSource = localTodoDataSource;
```

`signOut()` 마지막 (token clear 직후) 에 추가:

```dart
await _tokenStorage.clearTokens();
await _clearLocalDomainCaches();
```

`withdraw()` 마지막 (token clear 직후) 에 동일 추가.

```dart
Future<void> _clearLocalDomainCaches() async {
  try {
    await _localTodoDataSource.clearAll();
  } catch (e) {
    if (kDebugMode) debugPrint('Todo 캐시 정리 실패 (무시): $e');
  }
}
```

- [ ] **Step 4: `authRepositoryProvider` 갱신 — `LocalTodoDataSource` 주입**

`lib/features/auth/presentation/providers/auth_provider.dart`:

```dart
import '../../../todo/presentation/providers/todo_provider.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    firebaseAuthDataSource: ref.watch(firebaseAuthDataSourceProvider),
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    localTodoDataSource: ref.watch(localTodoDataSourceProvider),
  );
}
```

- [ ] **Step 5: 테스트 보강 — setUp 에 `_MockLocalTodo` 추가**

```dart
late _MockLocalTodo localTodo;

setUp(() {
  firebase = _MockFirebase();
  remote = _MockRemote();
  storage = _MockStorage();
  localTodo = _MockLocalTodo();
  repo = AuthRepositoryImpl(
    firebaseAuthDataSource: firebase,
    authRemoteDataSource: remote,
    tokenStorage: storage,
    localTodoDataSource: localTodo,
  );
});
```

(기존 다른 테스트들도 `clearAll` 가 호출되므로 기본 stub 필요)

```dart
setUp(() {
  // ... 기존 ...
  when(() => localTodo.clearAll()).thenAnswer((_) async {});
});
```

- [ ] **Step 6: 테스트 통과 확인**

Run: `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart`
Expected: 모든 테스트 PASS.

- [ ] **Step 7: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `auth_provider.g.dart` 재생성.

- [ ] **Step 8: 커밋**

```bash
git add lib/features/auth/data/repositories/auth_repository_impl.dart lib/features/auth/presentation/providers/auth_provider.dart lib/features/auth/presentation/providers/auth_provider.g.dart test/features/auth/data/repositories/auth_repository_impl_test.dart
git commit -m "feat : 로그아웃·탈퇴 시 Todo 로컬 캐시 정리 #77"
```

---

## Phase 8 — 문서 동기화

### Task 8.1: `docs/api-specs/02_todo.md` 갱신

**Files:**
- Modify: `docs/api-specs/02_todo.md`

- [ ] **Step 1: "동기화 전략" 섹션 수정**

기존:
```
> 동기화: **Tier 1 (Optimistic Updates)**
```

→ 변경:
```
> 동기화: **서버 source of truth + 로컬 캐시 폴백**
> (Tier 1 Optimistic Updates 의 완전 구현 — 동기화 큐·재시도 정책 — 은 별도 사이클)
```

해당 섹션의 본문도 server-first + cache fallback 흐름 설명으로 교체.

- [ ] **Step 2: Error 표 갱신 (Todo 생성 / Todo 수정 / 카테고리 생성·수정)**

기존 `INVALID_TITLE`, `INVALID_DATE_FORMAT`, `403 FORBIDDEN` 을 다음으로 치환:

| Status | code | 상황 |
|--------|------|------|
| 400 | `INVALID_INPUT_VALUE` | 제목 길이 초과, scheduledDates 형식 오류 등 |
| 404 | `CATEGORY_NOT_FOUND` | categoryIds 에 존재하지 않는 카테고리 |
| 409 | `TODO_ALREADY_EXISTS` | 동일 ID 의 Todo 가 이미 존재 |

Todo 수정/삭제 표에서 `403 FORBIDDEN` 행 제거, `404 TODO_NOT_FOUND` 설명에 "다른 사용자 소유 포함" 추가.

카테고리 생성 표의 `INVALID_CATEGORY_NAME` 을 `INVALID_INPUT_VALUE` 로 변경.

- [ ] **Step 3: PATCH 시멘틱 명시 — "빈 배열은 명시적 모두 제거"**

`3. Todo 수정` / `7. 카테고리 수정` 섹션에 한 줄 추가:

```
> 빈 배열(`[]`)은 명시적 모두 제거를 의미합니다. 변경하지 않을 필드는 본문에서 생략하세요.
```

- [ ] **Step 4: 커밋**

```bash
git add docs/api-specs/02_todo.md
git commit -m "docs : 02_todo.md 를 api-docs.json 계약과 정렬 #77"
```

---

## Phase 9 — 통합 검증

### Task 9.1: 전체 정적 분석

- [ ] **Step 1: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: `No issues found!` (0 issue).

- [ ] **Step 2: 실패 시 차례로 수정 후 작은 커밋**

---

### Task 9.2: 전체 테스트 실행

- [ ] **Step 1: `flutter test` 실행**

Run: `flutter test`
Expected: 모든 기존 + 신규 테스트 PASS. 커버리지 80% 이상 (P3~P5, P7 단위 테스트 누락 없음).

- [ ] **Step 2: 실패 시 차례로 수정 후 작은 커밋**

---

### Task 9.3: 수동 회귀 — 인증 모드

- [ ] **Step 1: 백엔드 실행 확인**

`http://suh-project.synology.me:8099/api/todos` 접근 가능 여부 확인 (curl/포스트맨).

- [ ] **Step 2: 로그인 후 `category_map_screen` 진입**

기대: 서버 GET /api/todo-categories 요청 → 화면에 카테고리 표시. 빈 상태면 새 카테고리 생성 → POST /api/todo-categories 호출 → 화면 갱신.

- [ ] **Step 3: Todo 추가 → POST /api/todos**

기대: 201 응답 → 화면 즉시 반영 → DB 에 저장됨 (백엔드 직접 확인).

- [ ] **Step 4: Todo 완료 토글 → PATCH /api/todos/{id}**

기대: 200 응답 + 화면 체크 상태 반영.

- [ ] **Step 5: Todo 삭제 → DELETE /api/todos/{id}**

기대: 204 응답 + 화면에서 제거.

---

### Task 9.4: 수동 회귀 — 게스트 모드 + 캐시 정리

- [ ] **Step 1: 로그아웃 후 게스트 모드에서 Todo 추가**

기대: 네트워크 호출 없이 SharedPreferences 에만 저장.

- [ ] **Step 2: 로그인 → 게스트 데이터가 사라지고 서버 데이터로 교체**

> ⚠️ Phase 7 에서 로그아웃 시 캐시를 정리하므로, 게스트 모드 → 로그인 흐름에서 게스트 데이터는 사라진다. 사용자 결정에 부합.

기대: 빈 서버 상태에서 시작 (혹은 기존 서버 데이터 표시).

- [ ] **Step 3: 다시 로그아웃 → 캐시 키 확인**

Run: 로그아웃 직후 디버거에서
```dart
final prefs = await SharedPreferences.getInstance();
print(prefs.getString('guest_todos'));  // null 기대
print(prefs.getString('guest_todo_categories'));  // null 기대
```

기대: 모두 `null`.

---

## 완료 후 정리

- [ ] **Step 1: spec 의 Definition of Done 체크리스트 모두 통과 확인**

`docs/superpowers/specs/2026-05-23-todo-category-api-integration-design.md` §13 항목 모두 ✅.

- [ ] **Step 2: 최종 커밋 로그 확인**

```bash
git log --oneline main..HEAD
```

기대: 약 13~15개 커밋, 모두 `feat/refactor/docs/test : ... #77` 형식.

- [ ] **Step 3: PR 생성 준비** (사용자가 직접 진행하거나 cassiiopeia:github 등으로 자동화)
