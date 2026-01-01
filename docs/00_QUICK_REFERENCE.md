# 🚀 Quick Reference - 우주공부선

> **빠른 참조 가이드** | 2-3분 내 핵심 정보 찾기 | 신규 팀원 30분 온보딩
>
> 상세 정보는 [01_ARCHITECTURE.md](./01_ARCHITECTURE.md) ~ [04_CODE_GENERATION_GUIDE.md](./04_CODE_GENERATION_GUIDE.md) 참조

---

## 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [레이어별 체크리스트](#레이어별-체크리스트)
3. [핵심 코드 스니펫](#핵심-코드-스니펫)
4. [필수 명령어](#필수-명령어)
5. [네이밍 치트시트](#네이밍-치트시트)
6. [동기화 전략](#동기화-전략)
7. [자주 하는 실수](#자주-하는-실수)
8. [빠른 찾기](#빠른-찾기)

---

## 프로젝트 개요

### 기술 스택
```yaml
Flutter: 3.9.2
상태관리: Riverpod 2.6.1 + Generator
불변 모델: Freezed 2.5.7
네트워킹: Retrofit 4.7.2 + Dio 5.9.0
로컬DB: Drift (SQLite)
보안저장: Flutter Secure Storage 9.2.4
백엔드: Spring Boot + JWT
인증: Google OAuth 2.0
```

### 아키텍처
```
Presentation (UI) → Domain (비즈니스) → Data (데이터소스)
     ↓                   ↓                    ↓
  Provider           UseCase           Repository
   Screen             Entity        Remote/Local DataSource
   Widget          Repository           Model (DTO)
```

### 핵심 디렉토리 구조
```
lib/
├── core/               # 공통 기능
│   ├── constants/      # 색상, 텍스트 스타일, API URL
│   ├── theme/          # Material 3 테마
│   ├── services/       # Dio, Secure Storage, FCM
│   ├── widgets/        # 공통 위젯 (버튼, 카드 등)
│   └── errors/         # 커스텀 Exception
│
├── features/           # Feature-First 구조
│   ├── auth/           # P0: Google 로그인
│   ├── todo/           # P0: Todo CRUD
│   ├── timer/          # P0: 타이머 + 연료
│   ├── fuel/           # P0: 연료 시스템
│   ├── exploration/    # P0: 탐험 지도
│   ├── social/         # P0: 친구 + 그룹
│   │   ├── friends/
│   │   └── groups/
│   ├── ranking/        # P0: 랭킹
│   ├── profile/        # P1: 프로필
│   ├── mission/        # P1: 미션
│   └── collection/     # P1: 뱃지 + 우주선
│
└── routes/             # GoRouter 라우팅
```

### Feature 내부 구조 (예: todo)
```
features/todo/
├── data/
│   ├── datasources/
│   │   ├── todo_remote_datasource.dart    # Retrofit API
│   │   └── todo_local_datasource.dart     # Drift DB
│   ├── models/
│   │   └── todo_model.dart                # DTO (Freezed)
│   └── repositories/
│       └── todo_repository_impl.dart      # Repository 구현
│
├── domain/
│   ├── entities/
│   │   └── todo_entity.dart               # Entity (Freezed)
│   ├── repositories/
│   │   └── todo_repository.dart           # Repository 인터페이스
│   └── usecases/
│       ├── get_todo_list_usecase.dart
│       ├── create_todo_usecase.dart
│       ├── update_todo_usecase.dart
│       └── delete_todo_usecase.dart
│
└── presentation/
    ├── providers/
    │   └── todo_provider.dart             # Riverpod Provider
    ├── screens/
    │   └── todo_list_screen.dart
    └── widgets/
        └── todo_item.dart
```

---

## 레이어별 체크리스트

### ✅ Feature 구현 순서

#### 1️⃣ Domain Layer (순수 Dart, Flutter 의존성 ❌)
- [ ] **Entity 생성** (`domain/entities/`)
  - Freezed 사용, Flutter 의존성 없음
  - 비즈니스 로직만 포함

- [ ] **Repository 인터페이스 정의** (`domain/repositories/`)
  - `abstract class`로 메서드 시그니처만 정의
  - Entity 타입 사용

- [ ] **UseCase 작성** (`domain/usecases/`)
  - 하나의 UseCase = 하나의 작업 (Single Responsibility)
  - `execute()` 메서드로 실행

#### 2️⃣ Data Layer
- [ ] **Model 생성** (`data/models/`)
  - Freezed + JsonSerializable
  - `toEntity()` 확장 메서드로 Entity 변환
  - `@JsonKey(name: 'snake_case')` 서버 필드명 매핑

- [ ] **Remote DataSource** (`data/datasources/`)
  - Retrofit으로 REST API 정의
  - `@GET`, `@POST`, `@PUT`, `@DELETE`

- [ ] **Local DataSource** (`data/datasources/`)
  - Drift로 SQLite 관리
  - 캐시 저장/조회

- [ ] **Repository 구현** (`data/repositories/`)
  - Domain의 Repository 인터페이스 구현
  - 동기화 전략 적용 (Tier 1/2/3)
  - DTO ↔ Entity 변환

#### 3️⃣ Presentation Layer
- [ ] **Provider 정의** (`presentation/providers/`)
  - `@riverpod` 어노테이션 사용
  - DataSource → Repository → UseCase → StateNotifier 의존성 체인

- [ ] **Screen 작성** (`presentation/screens/`)
  - `ConsumerWidget` 또는 `ConsumerStatefulWidget`
  - `ref.watch()` / `ref.read()` 사용
  - `.when()` 메서드로 AsyncValue 처리

- [ ] **Widget 분리** (`presentation/widgets/`)
  - 재사용 가능한 UI 컴포넌트
  - `StatelessWidget` 우선, `const` 생성자

#### 4️⃣ 코드 생성 & 검증
- [ ] **Build Runner 실행**
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **생성 파일 확인**
  - `*.freezed.dart` (Freezed)
  - `*.g.dart` (Riverpod, Retrofit, JsonSerializable)

- [ ] **컴파일 에러 없음**

- [ ] **테스트 작성** (선택적, 하지만 권장)

---

## 핵심 코드 스니펫

### 1. Entity (Domain Layer)
```dart
// domain/entities/todo_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';
part 'todo_entity.g.dart';

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

### 2. Model (Data Layer)
```dart
// data/models/todo_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

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

// DTO → Entity 변환
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

// Entity → DTO 변환
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

### 3. Repository Interface (Domain Layer)
```dart
// domain/repositories/todo_repository.dart
import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodoList({bool? completed});
  Future<TodoEntity> createTodo(String title);
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);
}
```

### 4. Remote DataSource (Retrofit)
```dart
// data/datasources/todo_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/todo_model.dart';

part 'todo_remote_datasource.g.dart';

@RestApi(baseUrl: '/api/v1/todos')
abstract class TodoRemoteDataSource {
  factory TodoRemoteDataSource(Dio dio) = _TodoRemoteDataSource;

  @GET('')
  Future<List<TodoModel>> getTodoList(@Query('completed') bool? completed);

  @POST('')
  Future<TodoModel> createTodo(@Body() CreateTodoRequest request);

  @PUT('/{id}')
  Future<TodoModel> updateTodo(
    @Path('id') String id,
    @Body() UpdateTodoRequest request,
  );

  @DELETE('/{id}')
  Future<void> deleteTodo(@Path('id') String id);
}
```

### 5. Repository Implementation (Data Layer)
```dart
// data/repositories/todo_repository_impl.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;

  TodoRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<TodoEntity>> getTodoList({bool? completed}) async {
    try {
      // 1. 서버에서 가져오기
      final models = await _remoteDataSource.getTodoList(completed);

      // 2. 로컬 캐시 저장
      for (final model in models) {
        await _localDataSource.saveTodo(model);
      }

      // 3. Entity로 변환
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      debugPrint('❌ TodoRepository.getTodoList error: $e');

      // 4. 네트워크 에러 시 로컬 캐시 반환
      final cached = await _localDataSource.getTodoList(completed);
      return cached.map((m) => m.toEntity()).toList();
    }
  }
}
```

### 6. UseCase (Domain Layer)
```dart
// domain/usecases/get_todo_list_usecase.dart
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  Future<List<TodoEntity>> execute({bool? completed}) async {
    return await _repository.getTodoList(completed: completed);
  }
}
```

### 7. Provider (Presentation Layer)
```dart
// presentation/providers/todo_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/get_todo_list_usecase.dart';

part 'todo_provider.g.dart';

// Repository Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final remote = ref.read(todoRemoteDataSourceProvider);
  final local = ref.read(todoLocalDataSourceProvider);
  return TodoRepositoryImpl(remote, local);
}

// UseCase Provider
@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodoListUseCase(repository);
}

// StateNotifier Provider
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final useCase = ref.read(getTodoListUseCaseProvider);
    return useCase.execute();
  }

  Future<void> addTodo(String title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(createTodoUseCaseProvider);
      await useCase.execute(title);
      return ref.read(getTodoListUseCaseProvider).execute();
    });
  }
}
```

### 8. Screen (Presentation Layer)
```dart
// presentation/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 미션')),
      body: todosAsync.when(
        data: (todos) => ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return TodoItem(key: Key(todos[index].id), todo: todos[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 필수 명령어

### 코드 생성
```bash
# 모든 코드 생성 (Freezed, Riverpod, Retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (파일 변경 시 자동 재생성)
flutter pub run build_runner watch --delete-conflicting-outputs

# 캐시 삭제 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Feature 생성 스크립트
```bash
# 새 Feature 생성 (디렉토리 + 빈 파일)
chmod +x scripts/create_feature.sh
./scripts/create_feature.sh mission

# 생성되는 구조:
# lib/features/mission/
# ├── data/{datasources,models,repositories}
# ├── domain/{entities,repositories,usecases}
# └── presentation/{providers,screens,widgets}
```

### Git Workflow
```bash
# Feature 브랜치 생성
git checkout -b feature/todo

# 작업 후 커밋
git add .
git commit -m "feat: Todo CRUD 구현"

# 푸시
git push -u origin feature/todo
```

### Flutter 명령어
```bash
# 의존성 설치
flutter pub get

# 앱 실행 (개발 모드)
flutter run

# 빌드
flutter build apk        # Android APK
flutter build ios        # iOS
flutter build web        # Web
```

---

## 네이밍 치트시트

### 파일명 규칙
| 타입 | 규칙 | 예시 |
|------|-----|------|
| Dart 파일 | `snake_case.dart` | `todo_list_screen.dart` |
| Entity | `{name}_entity.dart` | `todo_entity.dart` |
| Model (DTO) | `{name}_model.dart` | `todo_model.dart` |
| Repository 인터페이스 | `{name}_repository.dart` | `todo_repository.dart` |
| Repository 구현 | `{name}_repository_impl.dart` | `todo_repository_impl.dart` |
| Remote DataSource | `{name}_remote_datasource.dart` | `todo_remote_datasource.dart` |
| Local DataSource | `{name}_local_datasource.dart` | `todo_local_datasource.dart` |
| UseCase | `{verb}_{name}_usecase.dart` | `get_todo_list_usecase.dart` |
| Provider | `{name}_provider.dart` | `todo_provider.dart` |
| Screen | `{name}_screen.dart` | `todo_list_screen.dart` |
| Widget | `{name}.dart` | `todo_item.dart` |

### 클래스명 규칙
| 타입 | 규칙 | 예시 |
|------|-----|------|
| 클래스 | `PascalCase` | `TodoEntity` |
| 함수 | `camelCase` | `getTodoList()` |
| 변수 | `camelCase` | `todoList` |
| 상수 | `camelCase with const` | `const maxRetryCount = 3` |
| Private | `_prefix` | `_privateMethod()` |
| Boolean | `is`, `has`, `can` prefix | `isCompleted`, `hasPermission` |
| 컬렉션 | 복수형 | `List<Todo> todos` |

### Provider 네이밍
| Provider 타입 | 네이밍 패턴 | 예시 |
|--------------|-----------|------|
| DataSource | `{name}DataSourceProvider` | `todoRemoteDataSourceProvider` |
| Repository | `{name}RepositoryProvider` | `todoRepositoryProvider` |
| UseCase | `{verb}{Name}UseCaseProvider` | `getTodoListUseCaseProvider` |
| StateNotifier | `{name}NotifierProvider` | `todoListNotifierProvider` |

### Import 순서
```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 외부 패키지 (알파벳 순)
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 4. 프로젝트 내부
import '../../../core/constants/api_endpoints.dart';
import '../../domain/entities/todo_entity.dart';

// 5. Part 파일
part 'todo_model.freezed.dart';
part 'todo_model.g.dart';
```

---

## 동기화 전략

### Hybrid 3-Tier 전략

| Tier | 대상 기능 | 전략 | 장점 | 단점 |
|------|---------|-----|------|------|
| **Tier 1: Optimistic** | Todo CRUD, 타이머 시작/일시정지, 프로필 수정 | 로컬 먼저 저장 → UI 즉시 업데이트 → 백그라운드 동기화 | 오프라인 즉각 UX | 충돌 가능성 (Last-Write-Wins) |
| **Tier 2: Server-Validated** | 타이머 종료 → 연료 획득, 장소 해금, 미션 완료 | 서버 전송 → 서버 검증 → 최종 값 확정 → 로컬 업데이트 | 데이터 무결성, 조작 방지 | 온라인 필수, 네트워크 지연 |
| **Tier 3: Server-Only** | 랭킹, 친구 목록, 그룹, 뱃지/우주선 컬렉션 | 항상 서버 API 호출 → 로컬 캐시 (읽기 전용) | 항상 최신, 실시간성 | 오프라인 시 제한적 |

### Tier별 구현 패턴

#### Tier 1: Optimistic Updates
```dart
Future<TodoEntity> createTodo(String title) async {
  // 1. 로컬에 먼저 저장 (임시 ID)
  final tempId = DateTime.now().millisecondsSinceEpoch.toString();
  final tempModel = TodoModel(id: tempId, title: title, ...);
  await _localDataSource.saveTodo(tempModel);

  try {
    // 2. 서버에 전송
    final serverModel = await _remoteDataSource.createTodo(request);

    // 3. 서버 ID로 교체
    await _localDataSource.deleteTodo(tempId);
    await _localDataSource.saveTodo(serverModel);

    return serverModel.toEntity();
  } catch (e) {
    debugPrint('❌ Error: $e');
    // 4. 실패 시 임시 모델 반환 (동기화 큐에 추가)
    return tempModel.toEntity();
  }
}
```

#### Tier 2: Server-Validated
```dart
Future<FuelEntity> completeTimer(TimerSessionEntity session) async {
  try {
    // 1. 서버에 전송 (시작/종료 시각)
    final response = await _remoteDataSource.completeTimer(
      startTime: session.startTime,
      endTime: session.endTime,
    );

    // 2. 서버에서 재계산한 연료량 사용
    final fuelEarned = response.fuelEarned; // 서버 검증값

    // 3. 로컬 업데이트
    await _localDataSource.updateFuel(fuelEarned);

    return FuelEntity(amount: fuelEarned);
  } catch (e) {
    throw ServerException('타이머 완료 실패: $e');
  }
}
```

#### Tier 3: Server-Only
```dart
Future<List<RankingEntity>> getRanking() async {
  try {
    // 1. 항상 서버 API 호출
    final models = await _remoteDataSource.getRanking();

    // 2. 로컬 캐시 저장 (읽기 전용)
    await _localDataSource.saveRankingCache(models);

    return models.map((m) => m.toEntity()).toList();
  } catch (e) {
    debugPrint('❌ Network error: $e');

    // 3. 오프라인 시 캐시 반환 + "오프라인" 배지
    final cached = await _localDataSource.getRankingCache();
    return cached.map((m) => m.toEntity()).toList();
  }
}
```

---

## 자주 하는 실수

### ❌ 실수 1: Layer 경계 위반
```dart
// ❌ Screen에서 DataSource 직접 호출
class TodoListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.read(todoRemoteDataSourceProvider);
    final todos = await dataSource.getTodoList(); // 잘못됨!
  }
}

// ✅ 올바른 방법: Screen → Provider → UseCase → Repository
class TodoListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);
    // ...
  }
}
```

### ❌ 실수 2: UPPER_CASE 상수명
```dart
// ❌ Dart는 UPPER_CASE 사용 안 함
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// ✅ lowerCamelCase with const
const maxRetryCount = 3;
const apiBaseUrl = 'https://api.example.com';
```

### ❌ 실수 3: .then() 체인
```dart
// ❌ .then() 체인 (가독성 저하)
Future<void> fetchTodos() {
  return _repository.getTodoList().then((todos) {
    state = todos;
  }).catchError((error) {
    debugPrint('Error: $error');
  });
}

// ✅ async/await 사용
Future<void> fetchTodos() async {
  try {
    final todos = await _repository.getTodoList();
    state = todos;
  } catch (error) {
    debugPrint('Error: $error');
  }
}
```

### ❌ 실수 4: build_runner 실행 안 함
```
Error: "part of 'todo_model.freezed.dart' not found"
Error: "The getter 'todoListNotifierProvider' isn't defined"
```

**해결책**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ 실수 5: Provider 순환 참조
```dart
// ❌ Provider A가 Provider B를 읽고, B가 A를 읽음
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final useCase = ref.read(getTodoListUseCaseProvider); // A → B
  return TodoRepositoryImpl(useCase);
}

@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider); // B → A (순환!)
  return GetTodoListUseCase(repository);
}

// ✅ 올바른 의존성 방향: DataSource → Repository → UseCase → Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final remote = ref.read(todoRemoteDataSourceProvider);
  final local = ref.read(todoLocalDataSourceProvider);
  return TodoRepositoryImpl(remote, local);
}

@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodoListUseCase(repository);
}
```

### ❌ 실수 6: Entity와 Model 혼동
```dart
// ❌ Repository가 Model 반환
abstract class TodoRepository {
  Future<List<TodoModel>> getTodoList(); // 잘못됨!
}

// ✅ Repository는 Entity 반환
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodoList();
}

// Model은 Data Layer 내부에서만 사용
// Repository 구현체에서 Model → Entity 변환
```

### ❌ 실수 7: StatefulWidget 남발
```dart
// ❌ 상태가 없는데 StatefulWidget 사용
class TodoItem extends StatefulWidget {
  final TodoEntity todo;
  const TodoItem({super.key, required this.todo});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(widget.todo.title));
  }
}

// ✅ StatelessWidget 사용
class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final TodoEntity todo;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(todo.title));
  }
}
```

---

## 빠른 찾기

### 파일 위치 매핑
| 찾고 싶은 것 | 위치 |
|-------------|------|
| API 엔드포인트 | `lib/core/constants/api_endpoints.dart` |
| 색상 정의 | `lib/core/constants/app_colors.dart` |
| 텍스트 스타일 | `lib/core/constants/text_styles.dart` |
| 간격/모서리 | `lib/core/constants/spacing_and_radius.dart` |
| 문자열 상수 | `lib/core/constants/app_strings.dart` |
| Dio Client | `lib/core/services/dio/dio_client.dart` |
| Auth Interceptor | `lib/core/services/dio/interceptors/auth_interceptor.dart` |
| Secure Storage | `lib/core/services/storage/secure_storage_service.dart` |
| 에러 정의 | `lib/core/errors/exceptions.dart` |
| 공통 버튼 | `lib/core/widgets/buttons/` |
| 라우팅 | `lib/routes/app_router.dart` |

### 에러 메시지 → 해결책
| 에러 메시지 | 원인 | 해결책 |
|-----------|-----|--------|
| `part of 'xxx.freezed.dart' not found` | Freezed 코드 미생성 | `flutter pub run build_runner build --delete-conflicting-outputs` |
| `The getter 'xxxProvider' isn't defined` | Riverpod 코드 미생성 | 위와 동일 |
| `No named parameter with the name 'xxx'` | Freezed 필드 불일치 | Model/Entity 필드 확인 후 build_runner 재실행 |
| `Provider not found in scope` | Provider 정의 누락 | Provider 파일에서 `@riverpod` 추가 및 build_runner |
| `CircularDependencyError` | Provider 순환 참조 | 의존성 방향 확인 (DataSource → Repository → UseCase) |
| `DioException [connection error]` | 네트워크 연결 실패 | 1) 인터넷 확인 2) API URL 확인 3) 로컬 캐시 폴백 구현 |
| `401 Unauthorized` | JWT 토큰 만료/없음 | 1) 로그인 확인 2) Secure Storage 토큰 확인 3) 로그아웃 처리 |

### Feature별 주요 파일
| Feature | Entity | Model | Repository Impl | Provider | Screen |
|---------|--------|-------|----------------|----------|--------|
| Auth | `user_entity.dart` | `user_model.dart` | `auth_repository_impl.dart` | `auth_provider.dart` | `login_screen.dart` |
| Todo | `todo_entity.dart` | `todo_model.dart` | `todo_repository_impl.dart` | `todo_provider.dart` | `todo_list_screen.dart` |
| Timer | `timer_session_entity.dart` | `timer_session_model.dart` | `timer_repository_impl.dart` | `timer_provider.dart` | `timer_screen.dart` |
| Fuel | `fuel_entity.dart` | `fuel_model.dart` | `fuel_repository_impl.dart` | `fuel_provider.dart` | (Widget으로 표시) |
| Exploration | `location_entity.dart` | `location_model.dart` | `location_repository_impl.dart` | `exploration_provider.dart` | `exploration_map_screen.dart` |

---

## 추가 참고 자료

### 상세 문서
- [01_ARCHITECTURE.md](./01_ARCHITECTURE.md) - Clean Architecture 3-Layer, 동기화 전략, 보안 아키텍처
- [02_FOLDER_STRUCTURE.md](./02_FOLDER_STRUCTURE.md) - 전체 폴더 구조, Barrel Export, Import 순서
- [03_CODE_CONVENTIONS.md](./03_CODE_CONVENTIONS.md) - Dart 코딩 스타일, 에러 처리, Widget 가이드
- [04_CODE_GENERATION_GUIDE.md](./04_CODE_GENERATION_GUIDE.md) - 전체 템플릿, MVP 구현 순서 (8 Phase)

### 외부 문서
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture/)
- [Riverpod Official Docs](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Retrofit for Flutter](https://pub.dev/packages/retrofit)
- [Drift (SQLite)](https://drift.simonbinder.eu/)

---

**마지막 업데이트**: 2026-01-01
**버전**: v1.0 (MVP 기준)
