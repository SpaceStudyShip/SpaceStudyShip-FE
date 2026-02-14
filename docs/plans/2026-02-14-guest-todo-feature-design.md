# 게스트 모드 Todo 기능 설계

**날짜**: 2026-02-14
**상태**: 승인됨

## 개요

게스트 모드에서 할일(Todo) 기능을 로컬 저장소(SharedPreferences)로 구현한다.
- 게스트 세션 동안 앱 종료/재시작해도 데이터 유지
- 로그아웃 시 기존 캐시 삭제 로직에서 함께 정리
- 카테고리(폴더) 기능으로 할일 분류 지원
- 향후 타이머 연동 및 백엔드 API 확장 고려

## 아키텍처

Clean Architecture 3-Layer + SharedPreferences 방식.

```
TodoEntity (Domain) ← TodoRepository (Interface)
                        ├── LocalTodoRepositoryImpl (SharedPreferences, 게스트용)
                        └── RemoteTodoRepositoryImpl (Retrofit, 로그인용 - 추후)
```

Provider에서 `isGuest`를 확인하여 적절한 구현체를 주입한다.

## 도메인 레이어

### TodoEntity

```dart
@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,            // UUID
    required String title,         // 할일 제목
    @Default(false) bool completed,
    String? categoryId,            // 카테고리 연결 (null = 미분류)
    int? estimatedMinutes,         // 예상 시간 (타이머 연동용)
    int? actualMinutes,            // 실제 소요 시간 (타이머 기록용)
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;
}
```

### TodoCategoryEntity

```dart
@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,          // "수학", "영어" 등
    String? emoji,                 // 폴더 아이콘 (선택)
    required DateTime createdAt,
  }) = _TodoCategoryEntity;
}
```

### TodoRepository (Interface)

```dart
abstract class TodoRepository {
  // 할일
  Future<List<TodoEntity>> getTodoList({String? categoryId});
  Future<TodoEntity> createTodo({required String title, String? categoryId, int? estimatedMinutes});
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);

  // 카테고리
  Future<List<TodoCategoryEntity>> getCategories();
  Future<TodoCategoryEntity> createCategory({required String name, String? emoji});
  Future<void> deleteCategory(String id); // 소속 할일은 미분류(categoryId=null)로 이동

  Future<void> clearAll(); // 로그아웃 시 전체 삭제
}
```

### UseCases

- `GetTodoListUseCase` - 할일 목록 조회 (카테고리 필터 옵션)
- `CreateTodoUseCase` - 할일 생성
- `UpdateTodoUseCase` - 할일 수정 (완료 토글 포함)
- `DeleteTodoUseCase` - 할일 삭제
- `GetCategoriesUseCase` - 카테고리 목록 조회
- `CreateCategoryUseCase` - 카테고리 생성
- `DeleteCategoryUseCase` - 카테고리 삭제

## 데이터 레이어

### 저장 전략

SharedPreferences에 JSON 문자열로 저장:
- `guest_todos` → `List<TodoModel>` JSON 배열
- `guest_todo_categories` → `List<TodoCategoryModel>` JSON 배열

### TodoModel (DTO)

```dart
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    @Default(false) bool completed,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'estimated_minutes') int? estimatedMinutes,
    @JsonKey(name: 'actual_minutes') int? actualMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) => _$TodoModelFromJson(json);
}
```

양방향 변환 확장 메서드 (`toEntity()` / `toModel()`) 포함.

### TodoCategoryModel (DTO)

```dart
@freezed
class TodoCategoryModel with _$TodoCategoryModel {
  const factory TodoCategoryModel({
    required String id,
    required String name,
    String? emoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) => _$TodoCategoryModelFromJson(json);
}
```

### LocalTodoDataSource

SharedPreferences에서 JSON 읽기/쓰기를 담당하는 클래스.

### LocalTodoRepositoryImpl

DataSource를 통해 Model을 읽고, Entity로 변환하여 반환. 카테고리 삭제 시 소속 할일의 `categoryId`를 null로 변경.

## 프레젠테이션 레이어

### Providers (Riverpod)

```
todoRepositoryProvider → isGuest 체크하여 Local/Remote 분기
todoListNotifierProvider → CRUD 상태 관리 (AsyncNotifier)
todoCategoryListProvider → 카테고리 목록 관리
```

### UI 구성

#### HomeScreen 개선
- 기존 하드코딩된 할일 리스트를 `todoListNotifierProvider`로 교체
- 할일 추가: 바텀시트 (제목 + 예상시간 입력)
- 완료 토글: 체크박스 탭
- 삭제: 스와이프 (Dismissible)

#### TodoListScreen (신규)
- 카테고리별 폴더 뷰
- 카테고리 생성/삭제
- 폴더 내 할일 관리
- 라우트: `RoutePaths.todoList`

## 로그아웃 연동

기존 `AuthNotifier.signOut()`에서 `todoRepository.clearAll()` 호출:
- `guest_todos` SharedPreferences 키 삭제
- `guest_todo_categories` SharedPreferences 키 삭제

## 타이머 연동 (향후)

- `estimatedMinutes`: 할일 생성 시 예상 시간 입력
- `actualMinutes`: 타이머 완료 시 실제 소요 시간 기록
- 타이머 시작 시 연결할 할일 선택 → 타이머 종료 시 `actualMinutes` 업데이트

## 파일 구조

```
lib/features/todo/
├── data/
│   ├── datasources/
│   │   └── local_todo_datasource.dart
│   ├── models/
│   │   ├── todo_model.dart
│   │   └── todo_category_model.dart
│   └── repositories/
│       └── local_todo_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── todo_entity.dart
│   │   └── todo_category_entity.dart
│   ├── repositories/
│   │   └── todo_repository.dart
│   └── usecases/
│       ├── get_todo_list_usecase.dart
│       ├── create_todo_usecase.dart
│       ├── update_todo_usecase.dart
│       ├── delete_todo_usecase.dart
│       ├── get_categories_usecase.dart
│       ├── create_category_usecase.dart
│       └── delete_category_usecase.dart
└── presentation/
    ├── providers/
    │   └── todo_provider.dart
    ├── screens/
    │   └── todo_list_screen.dart
    └── widgets/
        ├── todo_add_bottom_sheet.dart
        └── category_folder_card.dart
```
