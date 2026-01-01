# 01_ARCHITECTURE.md - 우주공부선 시스템 아키텍처

## 목차
1. [아키텍처 개요](#아키텍처-개요)
2. [전체 시스템 구조](#전체-시스템-구조)
3. [Flutter 앱 아키텍처](#flutter-앱-아키텍처)
4. [데이터 흐름](#데이터-흐름)
5. [오프라인 동기화 전략](#오프라인-동기화-전략)
6. [보안 아키텍처](#보안-아키텍처)
7. [확장성 고려사항](#확장성-고려사항)

---

## 아키텍처 개요

### 핵심 설계 원칙
```yaml
아키텍처 패턴: Clean Architecture + Feature-First
레이어 분리: Presentation → Domain → Data
의존성 방향: 외부 → 내부 (단방향)
테스트 전략: 레이어별 독립 테스트
확장성: MVP(P0) → P1 → P2 단계적 확장
```

### 기술 스택
```yaml
# Frontend
Flutter: ^3.9.2
상태관리: Riverpod 2.6.1 + Riverpod Generator
불변 데이터: Freezed 2.5.7
네트워킹: Dio 5.9.0 + Retrofit 4.7.2
로컬DB: Drift (SQLite)
보안 저장소: Flutter Secure Storage 9.2.4
애니메이션: Rive (P2)
UI 반응형: ScreenUtil 5.9.3

# Backend
Framework: Spring Boot
API: RESTful API
인증: Google OAuth 2.0 + JWT
DB: (백엔드 팀 결정)

# Infrastructure
푸시알림: Firebase Cloud Messaging (FCM)
크래시 리포팅: Firebase Crashlytics
```

---

## 전체 시스템 구조

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Presentation Layer (UI)                    │ │
│  │  - Screens (StatelessWidget / StatefulWidget)          │ │
│  │  - Widgets (재사용 가능한 UI 컴포넌트)                    │ │
│  │  - Providers (Riverpod StateNotifier)                  │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │ ViewModel 패턴                         │
│  ┌──────────────────▼─────────────────────────────────────┐ │
│  │               Domain Layer (비즈니스 로직)               │ │
│  │  - Entities (순수 Dart 모델, Freezed)                   │ │
│  │  - UseCases (비즈니스 로직 단위)                         │ │
│  │  - Repository Interfaces (추상화)                      │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │ Repository 패턴                        │
│  ┌──────────────────▼─────────────────────────────────────┐ │
│  │                Data Layer (데이터 소스)                  │ │
│  │  ┌─────────────────┐        ┌──────────────────────┐  │ │
│  │  │  Remote         │        │  Local               │  │ │
│  │  │  - Retrofit API │        │  - Drift (SQLite)    │  │ │
│  │  │  - Dio Client   │        │  - Secure Storage    │  │ │
│  │  └─────────────────┘        └──────────────────────┘  │ │
│  │  - Models (DTO ↔ Entity 변환, Freezed + JsonSerializable)│
│  │  - Repository Implementations                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTP (REST API)
                        │ JWT Token
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                  Spring Boot Backend                         │
│  - REST API Endpoints                                        │
│  - Google OAuth 2.0 인증                                     │
│  - JWT 토큰 발급/검증                                         │
│  - 비즈니스 로직 (연료 계산, 랭킹, 미션 등)                      │
│  - Database (사용자, Todo, 타이머, 연료, 랭킹 등)              │
└──────────────────────────────────────────────────────────────┘
```

---

## Flutter 앱 아키텍처

### Clean Architecture 3-Layer

#### 1. Presentation Layer (외부)
**역할**: 사용자 인터페이스 및 상태 관리

```
presentation/
├── providers/          # Riverpod StateNotifier, Provider
│   └── todo_provider.dart
├── screens/            # 화면 (페이지 단위)
│   └── todo_list_screen.dart
└── widgets/            # 재사용 UI 컴포넌트
    └── todo_item_widget.dart
```

**특징**:
- `StatelessWidget` / `StatefulWidget` 사용
- `Riverpod Provider`로 상태 관리
- UI 로직만 포함 (비즈니스 로직 ❌)
- `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용

**예시**:
```dart
// providers/todo_provider.dart
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final useCase = ref.read(getTodoListUseCaseProvider);
    return useCase.execute();
  }

  Future<void> addTodo(String title) async {
    final useCase = ref.read(createTodoUseCaseProvider);
    await useCase.execute(title);
    ref.invalidateSelf(); // 재로드
  }
}
```

---

#### 2. Domain Layer (중간 - 순수 Dart)
**역할**: 비즈니스 로직 및 추상화

```
domain/
├── entities/          # 도메인 모델 (Freezed)
│   └── todo_entity.dart
├── repositories/      # Repository 인터페이스 (추상)
│   └── todo_repository.dart
└── usecases/          # 비즈니스 로직 (UseCase 패턴)
    ├── get_todo_list_usecase.dart
    └── create_todo_usecase.dart
```

**특징**:
- **Flutter 의존성 없음** (순수 Dart)
- `Freezed`로 불변 Entity 생성
- Repository는 인터페이스로만 정의
- UseCase는 단일 책임 원칙 (하나의 작업)

**예시**:
```dart
// entities/todo_entity.dart
@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    required bool completed,
    required DateTime createdAt,
  }) = _TodoEntity;
}

// repositories/todo_repository.dart (인터페이스)
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodoList();
  Future<void> createTodo(String title);
  Future<void> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);
}

// usecases/get_todo_list_usecase.dart
@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodoListUseCase(repository);
}

class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  Future<List<TodoEntity>> execute() async {
    return await _repository.getTodoList();
  }
}
```

---

#### 3. Data Layer (내부)
**역할**: 데이터 소스 연결 및 변환

```
data/
├── datasources/       # 데이터 소스
│   ├── todo_remote_datasource.dart  # Retrofit API
│   └── todo_local_datasource.dart   # Drift DB
├── models/            # DTO (Data Transfer Object)
│   └── todo_model.dart
└── repositories/      # Repository 구현체
    └── todo_repository_impl.dart
```

**특징**:
- `Retrofit` + `Dio`로 REST API 통신
- `Drift`로 SQLite 로컬 DB 관리
- DTO ↔ Entity 변환 책임
- Repository 인터페이스 구현

**예시**:
```dart
// models/todo_model.dart (DTO)
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    required bool completed,
    required DateTime createdAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

extension TodoModelX on TodoModel {
  // DTO → Entity 변환
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      completed: completed,
      createdAt: createdAt,
    );
  }
}

// datasources/todo_remote_datasource.dart
@RestApi(baseUrl: '/api/v1/todos')
abstract class TodoRemoteDataSource {
  factory TodoRemoteDataSource(Dio dio) = _TodoRemoteDataSource;

  @GET('')
  Future<List<TodoModel>> getTodoList();

  @POST('')
  Future<TodoModel> createTodo(@Body() CreateTodoRequest request);
}

// repositories/todo_repository_impl.dart
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;

  TodoRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<TodoEntity>> getTodoList() async {
    try {
      // 1. 서버에서 가져오기 (Tier 3: Server-Only)
      final models = await _remoteDataSource.getTodoList();
      final entities = models.map((m) => m.toEntity()).toList();

      // 2. 로컬 캐시 저장
      await _localDataSource.saveTodoList(models);

      return entities;
    } catch (e) {
      // 3. 네트워크 에러 시 로컬 캐시 반환
      final cached = await _localDataSource.getTodoList();
      return cached.map((m) => m.toEntity()).toList();
    }
  }
}
```

---

## 데이터 흐름

### 1. 읽기 플로우 (Read)
```
[User Interaction]
       │
       ▼
[Screen] → ConsumerWidget.build()
       │
       ▼
[Provider] → ref.watch(todoListProvider)
       │
       ▼
[UseCase] → execute()
       │
       ▼
[Repository] → getTodoList()
       │
       ├─► [Remote DataSource] → Retrofit API → Spring Boot
       │         │
       │         ▼
       │    [Local DataSource] → Drift DB에 캐시 저장
       │
       └─► [Local DataSource] → (에러 시) 캐시 반환
       │
       ▼
[Entity] → 순수 도메인 모델
       │
       ▼
[Provider] → state 업데이트
       │
       ▼
[Screen] → UI 리빌드
```

### 2. 쓰기 플로우 (Write)

#### Tier 1: Optimistic Updates (Todo CRUD)
```
[User: Todo 추가 버튼 클릭]
       │
       ▼
[Provider] → addTodo(title)
       │
       ├─► [Local DB] → 즉시 저장 (임시 ID)
       │        │
       │        ▼
       │   [UI] → 즉시 업데이트 ✅
       │
       └─► [Background] → 동기화 큐에 추가
                │
                ▼
           [Network Available] → 서버 전송
                │
                ├─► 성공 → 로컬 ID를 서버 ID로 교체
                └─► 실패 → 재시도 큐 유지
```

#### Tier 2: Server-Validated (타이머 종료 → 연료 획득)
```
[User: 타이머 종료]
       │
       ▼
[Provider] → completeTimer(session)
       │
       ├─► [UI] → "연료 계산 중... ⏳" 표시
       │
       └─► [Server] → POST /api/v1/timer/complete
                │         { startTime, endTime }
                │
                ▼
           [Server 검증]
                │ - 시작/종료 시각 유효성
                │ - 조작 방지 재계산
                │ - 정각 보너스 적용
                │
                ▼
           [Response] → { fuelEarned: 0.76, bonusApplied: false }
                │
                ▼
           [Local DB] → 연료 업데이트
                │
                ▼
           [UI] → "0.76통의 연료를 획득했습니다! 🎉"
```

#### Tier 3: Server-Only (랭킹 조회)
```
[User: 랭킹 탭 진입]
       │
       ▼
[Provider] → fetchRanking()
       │
       └─► [Server] → GET /api/v1/ranking/weekly
                │
                ├─► 성공 → 서버 데이터 표시 + 로컬 캐시 저장
                │
                └─► 실패 → 캐시 데이터 표시 + "오프라인" 배지
```

---

## 오프라인 동기화 전략

### Hybrid 3-Tier 전략

#### Tier 1: Optimistic Updates (즉시 반영)
```yaml
대상 기능:
  - Todo CRUD (생성, 수정, 삭제)
  - 타이머 시작/일시정지/재개
  - 프로필 정보 수정

동작 방식:
  1. 로컬 DB에 즉시 저장
  2. UI 즉시 업데이트
  3. 백그라운드로 동기화 큐에 추가
  4. 온라인 시 서버 전송
  5. 실패 시 재시도 (exponential backoff)

장점:
  - 오프라인에서도 즉각적인 UX
  - 네트워크 상태 무관

단점:
  - 충돌 가능성 (Last-Write-Wins 정책)
```

#### Tier 2: Server-Validated (서버 검증)
```yaml
대상 기능:
  - 타이머 종료 → 연료 획득
  - 장소 해금 (연료 차감)
  - 미션 완료 → 보상 지급

동작 방식:
  1. 로컬에서 임시 계산 표시
  2. 서버에 전송
  3. 서버에서 재계산 및 검증
  4. 서버 응답으로 최종 값 확정
  5. 로컬 DB 업데이트

장점:
  - 데이터 무결성 보장
  - 조작 방지 (서버에서 재계산)

단점:
  - 온라인 필수
  - 네트워크 지연 시 UX 저하
```

#### Tier 3: Server-Only (서버 전용)
```yaml
대상 기능:
  - 랭킹 조회 (전체/주간/친구/그룹)
  - 친구 목록, 친구 요청
  - 그룹 멤버, 그룹 랭킹
  - 뱃지/우주선 컬렉션 (해금 조건 확인)

동작 방식:
  1. 항상 서버 API 호출
  2. 응답 받으면 로컬 캐시 저장 (읽기 전용)
  3. 오프라인 시 캐시 표시 + "오프라인" 배지

장점:
  - 항상 최신 데이터
  - 실시간성 보장

단점:
  - 오프라인 시 제한적 기능
```

---

### 동기화 큐 시스템

#### 큐 구조 (Drift DB 테이블)
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  action TEXT NOT NULL,              -- 'CREATE_TODO', 'UPDATE_TODO', 'DELETE_TODO'
  payload TEXT NOT NULL,              -- JSON 직렬화된 데이터
  timestamp INTEGER NOT NULL,         -- UnixTimestamp
  retry_count INTEGER DEFAULT 0,
  status TEXT DEFAULT 'PENDING',      -- 'PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED'
  error_message TEXT
);
```

#### 동기화 프로세스
```dart
/// 동기화 큐 관리자
class SyncQueueManager {
  final TodoLocalDataSource _localDataSource;
  final TodoRemoteDataSource _remoteDataSource;

  /// 큐에 작업 추가
  Future<void> enqueue(SyncAction action) async {
    await _localDataSource.insertSyncQueue(action);
  }

  /// 온라인 복귀 시 자동 실행
  Future<void> processPendingQueue() async {
    final pendingActions = await _localDataSource.getPendingQueue();

    for (final action in pendingActions) {
      try {
        // 서버 전송
        await _sendToServer(action);

        // 성공 → 큐에서 제거
        await _localDataSource.deleteSyncQueue(action.id);
      } catch (e) {
        // 실패 → retryCount 증가
        final newRetryCount = action.retryCount + 1;

        if (newRetryCount >= 3) {
          // 3번 실패 → 사용자에게 알림
          await _localDataSource.updateSyncQueue(
            action.id,
            status: 'FAILED',
            errorMessage: e.toString(),
          );
        } else {
          // 재시도
          await _localDataSource.updateSyncQueue(
            action.id,
            retryCount: newRetryCount,
          );

          // Exponential backoff: 1초 → 2초 → 4초
          await Future.delayed(Duration(seconds: 1 << newRetryCount));
        }
      }
    }
  }
}
```

---

### 충돌 해결 정책

#### Todo 충돌
```yaml
시나리오: 오프라인에서 Todo 수정 → 다른 기기에서도 수정됨
정책: Last-Write-Wins (타임스탬프 기준)
예외: 삭제된 Todo는 복구 안 함 (삭제 우선)
```

#### 타이머 충돌
```yaml
시나리오: 오프라인에서 타이머 완료 → 서버 전송
정책: 서버 검증 (시작/종료 시각 유효성 체크)
      조작 방지 (서버에서 재계산한 연료량 사용)
예외: 유효하지 않은 세션은 거부
```

#### 연료/장소 충돌
```yaml
정책: 항상 서버가 Source of Truth
      로컬은 캐시로만 사용
      충돌 가능성 원천 차단
```

#### 친구/그룹 충돌
```yaml
정책: 항상 서버 데이터 우선
      로컬은 읽기 캐시로만 사용
```

---

## 보안 아키텍처

### 1. 인증 플로우

#### Google OAuth 2.0 + JWT
```
[User: Google 로그인 버튼 클릭]
       │
       ▼
[Flutter] → GoogleSignIn().signIn()
       │
       ▼
[Google OAuth 2.0] → 사용자 인증
       │
       ▼
[Google] → ID Token 발급
       │
       ▼
[Flutter] → POST /api/v1/auth/google
            Body: { idToken: "..." }
       │
       ▼
[Spring Boot] → Google ID Token 검증
       │         - Google API로 토큰 유효성 확인
       │         - 사용자 정보 추출 (email, name, profileImage)
       │
       ▼
[Spring Boot] → 사용자 DB 조회/생성
       │         - 기존 사용자: 조회
       │         - 신규 사용자: 생성
       │
       ▼
[Spring Boot] → JWT Access Token 발급
       │         - Payload: userId, email
       │         - 유효기간: (백엔드 결정)
       │
       ▼
[Response] → { accessToken: "...", user: { ... } }
       │
       ▼
[Flutter] → Secure Storage에 토큰 저장
       │    await _storage.write(key: 'accessToken', value: token);
       │
       ▼
[Flutter] → 메인 홈 화면 이동
```

---

### 2. API 인증

#### Dio Interceptor로 JWT 자동 삽입
```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Secure Storage에서 토큰 가져오기
    final token = await _storage.read(key: 'accessToken');

    if (token != null) {
      // Authorization 헤더에 JWT 추가
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized → 토큰 만료
    if (err.response?.statusCode == 401) {
      // 로그아웃 처리
      await _storage.delete(key: 'accessToken');
      // 로그인 화면으로 이동
      // (Navigation 로직)
    }

    handler.next(err);
  }
}
```

---

### 3. 민감 데이터 저장

#### Flutter Secure Storage
```yaml
저장 대상:
  - JWT Access Token
  - Refresh Token (백엔드에서 사용 시)
  - 기기 고유 ID (UUID)

보안:
  - iOS: Keychain
  - Android: EncryptedSharedPreferences
```

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// JWT 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  /// JWT 토큰 가져오기
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// 로그아웃 (토큰 삭제)
  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
  }
}
```

---

### 4. 네트워크 보안

#### HTTPS 강제
```dart
// dio_client.dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.spacestudyship.com', // HTTPS 강제
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));
```

#### Certificate Pinning (P2 - 선택적)
```yaml
목적: 중간자 공격(MITM) 방지
구현: dio_http_certificate_pinning 패키지
시점: P2 (보안 강화 단계)
```

---

## 확장성 고려사항

### 1. Feature-First 구조
```
lib/features/
├── auth/        # P0: 독립적으로 개발 가능
├── todo/        # P0: 다른 feature와 분리
├── timer/       # P0
├── fuel/        # P0
├── exploration/ # P0
├── social/      # P0: friends + groups
├── ranking/     # P0
├── profile/     # P1: 나중에 추가 용이
├── mission/     # P1: 기존 코드 영향 최소
└── collection/  # P1: badges + spaceships
```

**장점**:
- Feature별 독립 개발 가능
- P0 → P1 → P2 단계적 확장 용이
- 팀 협업 시 충돌 최소화

---

### 2. 모듈화 전략

#### Core Module (공통)
```
lib/core/
├── constants/       # 상수 (색상, 폰트, API URL)
├── theme/           # 테마 (Material 3 + 우주 테마)
├── utils/           # 유틸리티 함수
├── widgets/         # 공통 위젯 (버튼, 카드 등)
├── services/        # 공통 서비스 (Dio, Storage)
└── errors/          # 에러 정의
```

#### Feature Module (기능별)
```
lib/features/todo/
├── data/
├── domain/
└── presentation/
```

---

### 3. 의존성 관리

#### Riverpod Provider 계층
```dart
// 1. DataSource Provider
@riverpod
TodoRemoteDataSource todoRemoteDataSource(TodoRemoteDataSourceRef ref) {
  final dio = ref.read(dioProvider);
  return TodoRemoteDataSource(dio);
}

// 2. Repository Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final remote = ref.read(todoRemoteDataSourceProvider);
  final local = ref.read(todoLocalDataSourceProvider);
  return TodoRepositoryImpl(remote, local);
}

// 3. UseCase Provider
@riverpod
GetTodoListUseCase getTodoListUseCase(GetTodoListUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodoListUseCase(repository);
}

// 4. StateNotifier Provider
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final useCase = ref.read(getTodoListUseCaseProvider);
    return useCase.execute();
  }
}
```

---

### 4. 테스트 전략

#### 레이어별 테스트
```yaml
Domain Layer:
  - UseCase 단위 테스트 (순수 Dart)
  - Repository 인터페이스 Mock

Data Layer:
  - Repository 구현 테스트
  - DataSource Mock

Presentation Layer:
  - Widget 테스트
  - Provider Mock
```

**예시**:
```dart
// test/domain/usecases/get_todo_list_usecase_test.dart
void main() {
  late MockTodoRepository mockRepository;
  late GetTodoListUseCase useCase;

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = GetTodoListUseCase(mockRepository);
  });

  test('성공: Todo 리스트 반환', () async {
    // Arrange
    final expected = [
      TodoEntity(id: '1', title: 'Test', completed: false),
    ];
    when(() => mockRepository.getTodoList()).thenAnswer((_) async => expected);

    // Act
    final result = await useCase.execute();

    // Assert
    expect(result, expected);
    verify(() => mockRepository.getTodoList()).called(1);
  });
}
```

---

## 다이어그램 요약

### 의존성 방향
```
Presentation Layer (UI)
       ↓ (의존)
Domain Layer (비즈니스 로직)
       ↓ (의존)
Data Layer (데이터 소스)
```

### 데이터 흐름
```
User → Screen → Provider → UseCase → Repository → DataSource → API/DB
                                                         ↓
                                                     Response
                                                         ↓
UI ← State ← Provider ← Entity ← Repository ← Model ← DataSource
```

---

## 핵심 아키텍처 결정 (ADR)

### ADR-001: Clean Architecture 채택
**결정**: Clean Architecture + Feature-First 구조 사용
**이유**:
- MVP(P0) → P1 → P2 단계적 확장 필요
- 테스트 용이성 (레이어별 독립 테스트)
- 팀 협업 (Feature별 독립 개발)

**트레이드오프**:
- 초기 보일러플레이트 증가
- 러닝 커브 존재

---

### ADR-002: Riverpod 2.x 상태 관리
**결정**: Riverpod 2.x + Riverpod Generator 사용
**이유**:
- 타입 안전성 (컴파일 타임 에러 체크)
- 코드 생성으로 보일러플레이트 감소
- Provider 계층 의존성 명확

**대안**:
- Bloc: 보일러플레이트 많음
- GetX: 테스트 어려움

---

### ADR-003: Hybrid 동기화 전략
**결정**: 기능별 3-Tier 동기화 전략
**이유**:
- Todo/타이머: Optimistic (즉각적 UX)
- 연료/장소: Server-Validated (무결성)
- 랭킹/친구: Server-Only (실시간성)

**트레이드오프**:
- 구현 복잡도 증가
- 충돌 해결 로직 필요

---

## 참고 자료

- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture/)
- [Riverpod Official Docs](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Retrofit for Flutter](https://pub.dev/packages/retrofit)
- [Drift (SQLite)](https://drift.simonbinder.eu/)
