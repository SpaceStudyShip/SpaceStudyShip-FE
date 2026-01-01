# 03_CODE_CONVENTIONS.md - 우주공부선 코딩 컨벤션

## 목차
1. [Dart 코딩 스타일](#dart-코딩-스타일)
2. [네이밍 컨벤션](#네이밍-컨벤션)
3. [주석 작성 규칙](#주석-작성-규칙)
4. [에러 처리 패턴](#에러-처리-패턴)
5. [비동기 처리 규칙](#비동기-처리-규칙)
6. [Widget 작성 가이드](#widget-작성-가이드)
7. [Riverpod 사용 규칙](#riverpod-사용-규칙)
8. [Freezed 사용 규칙](#freezed-사용-규칙)
9. [테스트 작성 규칙](#테스트-작성-규칙)

---

## Dart 코딩 스타일

### 1. 코드 포맷팅
```yaml
도구: dart format (공식 포매터)
명령어: dart format lib/
IDE: VSCode - "Format on Save" 활성화

규칙:
  - 들여쓰기: 2칸 공백
  - 최대 줄 길이: 80자 (권장)
  - 세미콜론: 필수
```

### 2. 중괄호 스타일
```dart
// ✅ 좋은 예: K&R 스타일 (Dart 표준)
if (condition) {
  doSomething();
}

class MyClass {
  void myMethod() {
    // ...
  }
}

// ❌ 나쁜 예: Allman 스타일
if (condition)
{
  doSomething();
}
```

### 3. 공백 사용
```dart
// ✅ 좋은 예
final sum = a + b;
if (condition) {}
void function(int param) {}

// ❌ 나쁜 예
final sum=a+b;
if(condition){}
void function ( int param ){}
```

### 4. 줄 바꿈
```dart
// ✅ 좋은 예: 80자 초과 시 줄 바꿈
final longString = 'This is a very long string that exceeds '
    'the 80 character limit and should be split '
    'into multiple lines for better readability.';

final result = someFunction(
  parameter1: value1,
  parameter2: value2,
  parameter3: value3,
);

// ❌ 나쁜 예: 한 줄에 모두 작성
final longString = 'This is a very long string that exceeds the 80 character limit...';
```

---

## 네이밍 컨벤션

### 1. 클래스명
```dart
// ✅ PascalCase
class TodoEntity {}
class AuthRepository {}
class TodoListScreen {}

// ❌ 잘못된 예
class todoEntity {}
class auth_repository {}
class TodoListscreen {}
```

### 2. 변수명
```dart
// ✅ camelCase
final userName = 'John';
int todoCount = 0;
bool isCompleted = false;

// ❌ 잘못된 예
final UserName = 'John';
int todo_count = 0;
bool IsCompleted = false;
```

### 3. 함수명
```dart
// ✅ camelCase, 동사로 시작
void fetchUserData() {}
Future<void> saveTodo() async {}
bool isValidEmail(String email) {}

// ❌ 잘못된 예
void FetchUserData() {}
Future<void> save_todo() async {}
bool valid_email(String email) {}
```

### 4. Private 멤버
```dart
// ✅ _ (언더스코어) 접두사
class MyClass {
  final String _privateField;

  void _privateMethod() {}
}

// ❌ public으로 노출
class MyClass {
  final String privateField; // public
}
```

### 5. 상수
```dart
// ✅ lowerCamelCase with const
const maxRetryCount = 3;
const apiBaseUrl = 'https://api.example.com';

// ❌ UPPER_CASE (Dart는 권장하지 않음)
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';
```

### 6. Enum
```dart
// ✅ PascalCase (Enum), camelCase (값)
enum TodoStatus {
  pending,
  inProgress,
  completed,
}

// ❌ 잘못된 예
enum todoStatus {
  PENDING,
  IN_PROGRESS,
  COMPLETED,
}
```

### 7. Boolean 변수
```dart
// ✅ is, has, can 접두사
bool isCompleted = true;
bool hasPermission = false;
bool canEdit = true;

// ❌ 명확하지 않은 이름
bool completed = true;
bool permission = false;
bool edit = true;
```

### 8. 컬렉션 변수
```dart
// ✅ 복수형
final List<Todo> todos = [];
final Map<String, User> users = {};
final Set<String> tags = {};

// ❌ 단수형
final List<Todo> todo = [];
final Map<String, User> user = {};
```

---

## 주석 작성 규칙

### 1. DartDoc 주석 (공개 API)
```dart
/// Todo 목록을 가져오는 UseCase
///
/// [completed] 파라미터로 완료된 Todo만 필터링할 수 있습니다.
///
/// Returns:
/// - 성공: Todo 리스트
/// - 실패: [ServerException]
///
/// Example:
/// ```dart
/// final useCase = GetTodoListUseCase(repository);
/// final todos = await useCase.execute(completed: true);
/// ```
class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  /// Todo 리스트를 가져옵니다
  Future<List<TodoEntity>> execute({bool? completed}) async {
    return await _repository.getTodoList(completed: completed);
  }
}
```

### 2. 인라인 주석 (복잡한 로직)
```dart
// ✅ 좋은 예: 왜 이렇게 했는지 설명
// iOS 시뮬레이터에서는 FCM 토큰을 발급받을 수 없으므로
// null 체크 후 에러 메시지를 사용자에게 알림
if (fcmToken == null) {
  debugPrint('💡 [안내] iOS 시뮬레이터에서는 FCM을 지원하지 않습니다.');
  return;
}

// ❌ 나쁜 예: 코드 그대로 반복
// fcmToken이 null이면 리턴
if (fcmToken == null) {
  return;
}
```

### 3. TODO 주석
```dart
// ✅ 좋은 예: 이슈 번호 또는 구체적인 설명
// TODO(#123): Rive 애니메이션 추가 (P2)
// TODO: 에러 발생 시 재시도 로직 추가

// ❌ 나쁜 예: 모호한 TODO
// TODO: 나중에 수정
// TODO: 개선 필요
```

### 4. FIXME, HACK 주석
```dart
// ✅ 임시 해결책 명시
// FIXME: 네트워크 타임아웃 처리 개선 필요
await Future.delayed(Duration(seconds: 5));

// HACK: Dio 버그 우회 (v5.9.0)
// https://github.com/cfug/dio/issues/1234
dio.options.connectTimeout = null;
```

### 5. 주석 지양
```dart
// ✅ 코드 자체로 설명 (주석 불필요)
final isValidEmail = email.contains('@');

// ❌ 불필요한 주석
// 이메일 유효성 검사
final isValidEmail = email.contains('@');
```

---

## 에러 처리 패턴

### 1. Try-Catch 기본 패턴
```dart
// ✅ 좋은 예: 구체적인 예외 처리
Future<List<TodoEntity>> getTodoList() async {
  try {
    final models = await _remoteDataSource.getTodoList();
    return models.map((m) => m.toEntity()).toList();
  } on DioException catch (e) {
    // 네트워크 에러: 로컬 캐시 반환
    debugPrint('❌ Network error: $e');
    return _localDataSource.getTodoList();
  } on ServerException catch (e) {
    // 서버 에러: 사용자에게 알림
    debugPrint('❌ Server error: ${e.message}');
    rethrow;
  } catch (e, stackTrace) {
    // 예상치 못한 에러: Crashlytics 전송
    debugPrint('❌ Unexpected error: $e');
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    throw UnknownException(e.toString());
  }
}

// ❌ 나쁜 예: 모든 에러를 동일하게 처리
Future<List<TodoEntity>> getTodoList() async {
  try {
    final models = await _remoteDataSource.getTodoList();
    return models.map((m) => m.toEntity()).toList();
  } catch (e) {
    debugPrint('Error: $e');
    return [];
  }
}
```

### 2. Custom Exception 정의
```dart
// lib/core/errors/exceptions.dart
/// 서버 에러
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// 네트워크 에러
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 캐시 에러
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
```

### 3. Result 패턴 (선택적)
```dart
// ✅ Either<Failure, Success> 패턴 (Dartz)
import 'package:dartz/dartz.dart';

Future<Either<Failure, List<TodoEntity>>> getTodoList() async {
  try {
    final models = await _remoteDataSource.getTodoList();
    final entities = models.map((m) => m.toEntity()).toList();
    return Right(entities);
  } on DioException catch (e) {
    return Left(NetworkFailure(e.message ?? 'Network error'));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

// Provider에서 사용
final result = await ref.read(todoRepositoryProvider).getTodoList();
result.fold(
  (failure) => debugPrint('Error: $failure'),
  (todos) => state = todos,
);
```

---

## 비동기 처리 규칙

### 1. async/await 사용
```dart
// ✅ async/await 사용
Future<void> fetchTodos() async {
  final todos = await _repository.getTodoList();
  state = todos;
}

// ❌ .then() 체인 (가독성 저하)
Future<void> fetchTodos() {
  return _repository.getTodoList().then((todos) {
    state = todos;
  });
}
```

### 2. FutureBuilder보다 Riverpod 선호
```dart
// ✅ Riverpod AsyncValue 사용
@riverpod
Future<List<TodoEntity>> todoList(TodoListRef ref) async {
  final repository = ref.read(todoRepositoryProvider);
  return repository.getTodoList();
}

// Widget에서 사용
ref.watch(todoListProvider).when(
  data: (todos) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);

// ❌ FutureBuilder (보일러플레이트 많음)
FutureBuilder<List<TodoEntity>>(
  future: repository.getTodoList(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return ListView.builder(...);
  },
);
```

### 3. Stream 처리
```dart
// ✅ Stream 사용
@riverpod
Stream<List<TodoEntity>> todoStream(TodoStreamRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return repository.watchTodoList();
}

// Widget에서 사용
ref.watch(todoStreamProvider).when(
  data: (todos) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);
```

### 4. 병렬 실행
```dart
// ✅ Future.wait 사용
final results = await Future.wait([
  _repository.getTodos(),
  _repository.getFuel(),
  _repository.getLocations(),
]);
final todos = results[0] as List<TodoEntity>;
final fuel = results[1] as FuelEntity;
final locations = results[2] as List<LocationEntity>;

// ❌ 순차 실행 (느림)
final todos = await _repository.getTodos();
final fuel = await _repository.getFuel();
final locations = await _repository.getLocations();
```

---

## Widget 작성 가이드

### 1. StatelessWidget 우선
```dart
// ✅ StatelessWidget (상태 없음)
class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
  });

  final TodoEntity todo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      onTap: onTap,
    );
  }
}

// ❌ StatefulWidget (불필요)
class TodoItem extends StatefulWidget {
  // 상태가 없는데 StatefulWidget 사용
}
```

### 2. const 생성자 활용
```dart
// ✅ const 생성자 (성능 최적화)
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// 사용 시
const PrimaryButton(
  text: 'Submit',
  onPressed: _onSubmit,
);
```

### 3. Build 메서드 분리
```dart
// ✅ 복잡한 위젯은 서브위젯으로 분리
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(todos),
      floatingActionButton: _buildFAB(ref),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(title: Text('Todos'));
  }

  Widget _buildBody(AsyncValue<List<TodoEntity>> todos) {
    return todos.when(
      data: (list) => _TodoList(todos: list),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildFAB(WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddDialog(ref),
      child: Icon(Icons.add),
    );
  }
}

// 서브위젯
class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos});

  final List<TodoEntity> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoItem(todo: todos[index]);
      },
    );
  }
}

// ❌ Build 메서드에 모든 로직 포함 (가독성 저하)
class TodoListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Todos')),
      body: todos.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(list[index].title),
            // ... 복잡한 로직
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ... 복잡한 로직
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 4. Key 사용
```dart
// ✅ 리스트 항목에 Key 사용
ListView.builder(
  itemCount: todos.length,
  itemBuilder: (context, index) {
    final todo = todos[index];
    return TodoItem(
      key: Key(todo.id), // Key 사용
      todo: todo,
    );
  },
);

// ❌ Key 없음 (재렌더링 시 문제 발생 가능)
ListView.builder(
  itemCount: todos.length,
  itemBuilder: (context, index) {
    return TodoItem(todo: todos[index]);
  },
);
```

---

## Riverpod 사용 규칙

### 1. Provider 정의
```dart
// ✅ @riverpod 어노테이션 사용 (Riverpod 2.x)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_provider.g.dart';

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

// ❌ 수동 Provider 정의 (보일러플레이트)
final todoListProvider = StateNotifierProvider<TodoListNotifier, AsyncValue<List<TodoEntity>>>((ref) {
  return TodoListNotifier(ref);
});
```

### 2. Provider 사용
```dart
// ✅ ConsumerWidget 사용
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListNotifierProvider);

    return todos.when(
      data: (list) => _buildList(list),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}

// ❌ StatelessWidget + Consumer (중복)
class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final todos = ref.watch(todoListNotifierProvider);
        // ...
      },
    );
  }
}
```

### 3. 의존성 주입
```dart
// ✅ Provider로 의존성 주입
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

// ❌ 직접 인스턴스 생성
final repository = TodoRepositoryImpl(
  TodoRemoteDataSource(dio),
  TodoLocalDataSource(db),
);
```

---

## Freezed 사용 규칙

### 1. Entity/Model 정의
```dart
// ✅ Freezed + JsonSerializable
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

### 2. copyWith 사용
```dart
// ✅ copyWith로 불변 업데이트
final updatedTodo = todo.copyWith(completed: true);

// ❌ 직접 수정 불가 (Freezed는 불변)
todo.completed = true; // 컴파일 에러
```

### 3. 패턴 매칭
```dart
// ✅ Union Type 사용
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// 사용
authState.when(
  initial: () => Text('Please login'),
  loading: () => CircularProgressIndicator(),
  authenticated: (user) => Text('Hello, ${user.name}'),
  unauthenticated: () => LoginScreen(),
  error: (message) => Text('Error: $message'),
);
```

---

## 테스트 작성 규칙

### 1. 테스트 파일 위치
```
test/
├── domain/
│   └── usecases/
│       └── get_todo_list_usecase_test.dart
├── data/
│   └── repositories/
│       └── todo_repository_impl_test.dart
└── presentation/
    └── providers/
        └── todo_provider_test.dart
```

### 2. 테스트 구조 (AAA 패턴)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetTodoListUseCase useCase;
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = GetTodoListUseCase(mockRepository);
  });

  group('GetTodoListUseCase', () {
    test('성공: Todo 리스트를 반환한다', () async {
      // Arrange (준비)
      final expected = [
        TodoEntity(
          id: '1',
          title: 'Test Todo',
          completed: false,
          createdAt: DateTime.now(),
        ),
      ];
      when(() => mockRepository.getTodoList())
          .thenAnswer((_) async => expected);

      // Act (실행)
      final result = await useCase.execute();

      // Assert (검증)
      expect(result, expected);
      verify(() => mockRepository.getTodoList()).called(1);
    });

    test('실패: 네트워크 에러 시 예외를 던진다', () async {
      // Arrange
      when(() => mockRepository.getTodoList())
          .thenThrow(NetworkException('Connection failed'));

      // Act & Assert
      expect(
        () => useCase.execute(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

---

## 코드 리뷰 체크리스트

### ✅ DO (해야 할 것)
```yaml
- Dart 공식 스타일 가이드 준수
- const 생성자 활용
- Private 멤버에 _ 사용
- DartDoc 주석 작성 (공개 API)
- 구체적인 예외 처리
- async/await 사용
- StatelessWidget 우선
- Riverpod Provider로 의존성 주입
- Freezed로 불변 모델 생성
- 테스트 작성 (AAA 패턴)
```

### ❌ DON'T (하지 말아야 할 것)
```yaml
- UPPER_CASE 상수명
- .then() 체인 (async/await 사용)
- FutureBuilder 남발 (Riverpod 사용)
- StatefulWidget 남발
- 직접 인스턴스 생성 (Provider 사용)
- 가변 모델 (Freezed 사용)
- 불필요한 주석
- catch (e) 만 사용 (구체적 예외 처리)
```

---

## 참고 자료
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/reading)
- [Freezed Documentation](https://pub.dev/packages/freezed)
