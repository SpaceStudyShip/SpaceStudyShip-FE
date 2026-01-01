# 02_FOLDER_STRUCTURE.md - 우주공부선 폴더 구조 가이드

## 목차
1. [전체 프로젝트 구조](#전체-프로젝트-구조)
2. [lib/ 디렉토리 상세](#lib-디렉토리-상세)
3. [Feature 모듈 구조](#feature-모듈-구조)
4. [파일 명명 규칙](#파일-명명-규칙)
5. [Import 순서 규칙](#import-순서-규칙)
6. [Barrel Export 패턴](#barrel-export-패턴)

---

## 전체 프로젝트 구조

```
space_study_ship/
├── android/                 # Android 네이티브 코드
├── ios/                     # iOS 네이티브 코드
├── lib/                     # Flutter 소스 코드 (메인)
├── test/                    # 단위 테스트
├── integration_test/        # 통합 테스트 (E2E)
├── assets/                  # 정적 리소스
│   ├── fonts/              # Pretendard 폰트
│   ├── images/             # 이미지 (PNG, JPG)
│   ├── icons/              # 아이콘 (SVG)
│   ├── lottie/             # Lottie 애니메이션 (P1)
│   └── rive/               # Rive 애니메이션 (P2)
├── docs/                    # 프로젝트 문서
│   ├── 우주공부선PRD.md
│   ├── 01_ARCHITECTURE.md
│   ├── 02_FOLDER_STRUCTURE.md
│   ├── 03_CODE_CONVENTIONS.md
│   └── 04_CODE_GENERATION_GUIDE.md
├── pubspec.yaml            # 의존성 관리
├── .env                    # 환경 변수 (API URL, FCM 등)
├── .gitignore
└── README.md
```

---

## lib/ 디렉토리 상세

### 전체 구조
```
lib/
├── main.dart                         # 앱 진입점
├── app.dart                          # MaterialApp 설정
├── firebase_options.dart             # Firebase 자동 생성 파일
│
├── core/                             # 공통 기능 (모든 feature에서 사용)
│   ├── constants/                    # 상수
│   │   ├── app_colors.dart          # 색상 (우주 테마)
│   │   ├── text_styles.dart         # 텍스트 스타일 (Pretendard)
│   │   ├── spacing_and_radius.dart  # 간격, 모서리 반경
│   │   ├── api_endpoints.dart       # API URL
│   │   └── app_strings.dart         # 문자열 상수
│   │
│   ├── theme/                        # 테마
│   │   ├── app_theme.dart           # Material 3 테마
│   │   └── theme_provider.dart      # 다크모드 Provider (P2)
│   │
│   ├── utils/                        # 유틸리티
│   │   ├── date_formatter.dart      # 날짜 포맷팅
│   │   ├── validators.dart          # 입력 검증
│   │   └── extensions.dart          # Dart 확장
│   │
│   ├── widgets/                      # 공통 위젯
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   └── secondary_button.dart
│   │   ├── cards/
│   │   │   └── base_card.dart
│   │   ├── loading/
│   │   │   └── loading_indicator.dart
│   │   └── empty_state.dart
│   │
│   ├── services/                     # 공통 서비스
│   │   ├── dio/
│   │   │   ├── dio_client.dart      # Dio 설정
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart
│   │   │       └── logging_interceptor.dart
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   └── shared_prefs_service.dart
│   │   ├── device/
│   │   │   ├── device_info_service.dart
│   │   │   └── device_id_manager.dart
│   │   └── fcm/
│   │       ├── firebase_messaging_service.dart
│   │       └── local_notifications_service.dart
│   │
│   └── errors/                       # 에러 정의
│       ├── exceptions.dart           # Custom Exceptions
│       ├── failures.dart             # Failure 클래스
│       └── error_handler.dart        # 글로벌 에러 핸들러
│
├── features/                         # 기능별 모듈 (Feature-First)
│   │
│   ├── auth/                         # P0: 인증 (Google 로그인)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── login_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── google_sign_in_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/
│   │           └── google_sign_in_button.dart
│   │
│   ├── todo/                         # P0: Todo CRUD
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── todo_remote_datasource.dart
│   │   │   │   └── todo_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── todo_model.dart
│   │   │   │   └── create_todo_request.dart
│   │   │   └── repositories/
│   │   │       └── todo_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── todo_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── todo_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_todo_list_usecase.dart
│   │   │       ├── create_todo_usecase.dart
│   │   │       ├── update_todo_usecase.dart
│   │   │       └── delete_todo_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── todo_provider.dart
│   │       ├── screens/
│   │       │   └── todo_list_screen.dart
│   │       └── widgets/
│   │           ├── todo_item.dart
│   │           └── todo_input_dialog.dart
│   │
│   ├── timer/                        # P0: 타이머
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── timer_remote_datasource.dart
│   │   │   │   └── timer_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── timer_session_model.dart
│   │   │   │   └── complete_timer_response.dart
│   │   │   └── repositories/
│   │   │       └── timer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── timer_session_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── timer_repository.dart
│   │   │   └── usecases/
│   │   │       ├── start_timer_usecase.dart
│   │   │       ├── pause_timer_usecase.dart
│   │   │       └── complete_timer_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── timer_provider.dart
│   │       ├── screens/
│   │       │   └── timer_screen.dart
│   │       └── widgets/
│   │           ├── timer_display.dart
│   │           ├── timer_controls.dart
│   │           └── spaceship_animation.dart (Rive - P2)
│   │
│   ├── fuel/                         # P0: 연료 시스템
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── fuel_remote_datasource.dart
│   │   │   │   └── fuel_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── fuel_model.dart
│   │   │   └── repositories/
│   │   │       └── fuel_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── fuel_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── fuel_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_fuel_balance_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── fuel_provider.dart
│   │       └── widgets/
│   │           └── fuel_display.dart
│   │
│   ├── exploration/                  # P0: 탐험 지도
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── location_remote_datasource.dart
│   │   │   │   └── location_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── location_model.dart
│   │   │   └── repositories/
│   │   │       └── location_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── location_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── location_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_locations_usecase.dart
│   │   │       └── unlock_location_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── exploration_provider.dart
│   │       ├── screens/
│   │       │   └── exploration_map_screen.dart
│   │       └── widgets/
│   │           ├── location_card.dart
│   │           └── unlock_dialog.dart
│   │
│   ├── social/                       # P0: 친구 + 그룹
│   │   ├── friends/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── groups/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── ranking/                      # P0: 랭킹
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/                      # P1: 프로필
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── mission/                      # P1: 미션 시스템
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── collection/                   # P1: 뱃지 + 우주선 컬렉션
│       ├── badges/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       └── spaceships/
│           ├── data/
│           ├── domain/
│           └── presentation/
│
├── shared/                           # Feature 간 공유 모델 (선택적)
│   └── models/
│       └── pagination_model.dart
│
└── routes/                           # 라우팅 (GoRouter)
    ├── app_router.dart
    └── route_names.dart
```

---

## Feature 모듈 구조

### 표준 Feature 구조 (Todo 예시)
```
features/todo/
├── data/                          # Data Layer
│   ├── datasources/               # 데이터 소스
│   │   ├── todo_remote_datasource.dart    # Retrofit API
│   │   └── todo_local_datasource.dart     # Drift DB
│   │
│   ├── models/                    # DTO (Data Transfer Object)
│   │   ├── todo_model.dart                 # Freezed + JsonSerializable
│   │   ├── todo_model.freezed.dart         # 자동 생성
│   │   ├── todo_model.g.dart               # 자동 생성
│   │   ├── create_todo_request.dart
│   │   └── update_todo_request.dart
│   │
│   └── repositories/              # Repository 구현
│       └── todo_repository_impl.dart       # 인터페이스 구현
│
├── domain/                        # Domain Layer
│   ├── entities/                  # 도메인 모델
│   │   ├── todo_entity.dart                # Freezed (불변)
│   │   ├── todo_entity.freezed.dart        # 자동 생성
│   │   └── todo_entity.g.dart              # 자동 생성 (선택적)
│   │
│   ├── repositories/              # Repository 인터페이스
│   │   └── todo_repository.dart            # abstract class
│   │
│   └── usecases/                  # UseCase (비즈니스 로직)
│       ├── get_todo_list_usecase.dart
│       ├── create_todo_usecase.dart
│       ├── update_todo_usecase.dart
│       └── delete_todo_usecase.dart
│
└── presentation/                  # Presentation Layer
    ├── providers/                 # Riverpod Provider
    │   ├── todo_provider.dart              # @riverpod 코드
    │   └── todo_provider.g.dart            # 자동 생성
    │
    ├── screens/                   # 화면 (페이지)
    │   └── todo_list_screen.dart
    │
    └── widgets/                   # 재사용 위젯
        ├── todo_item.dart
        ├── todo_input_dialog.dart
        └── empty_todo_list.dart
```

---

### 각 디렉토리 역할

#### `data/datasources/`
```yaml
역할: 외부 데이터 소스와 통신
파일명 패턴: {feature}_remote_datasource.dart
           {feature}_local_datasource.dart

예시:
  - todo_remote_datasource.dart  # Retrofit API
  - todo_local_datasource.dart   # Drift DB
```

#### `data/models/`
```yaml
역할: DTO (서버 ↔ 앱 데이터 전송)
파일명 패턴: {entity}_model.dart
           {action}_request.dart
           {action}_response.dart

특징:
  - Freezed + JsonSerializable 사용
  - toEntity() 메서드로 Entity 변환
  - fromJson() / toJson() 자동 생성

예시:
  - todo_model.dart
  - create_todo_request.dart
  - update_todo_response.dart
```

#### `data/repositories/`
```yaml
역할: Repository 인터페이스 구현
파일명 패턴: {feature}_repository_impl.dart

특징:
  - domain/repositories의 인터페이스 구현
  - datasource 호출 및 에러 처리
  - DTO ↔ Entity 변환 책임
```

#### `domain/entities/`
```yaml
역할: 순수 비즈니스 모델 (Flutter 의존성 ❌)
파일명 패턴: {entity}_entity.dart

특징:
  - Freezed로 불변 클래스 생성
  - 비즈니스 로직만 포함
  - JsonSerializable 선택적 (서버 통신 시)
```

#### `domain/repositories/`
```yaml
역할: Repository 인터페이스 정의
파일명 패턴: {feature}_repository.dart

특징:
  - abstract class (구현 없음)
  - 메서드 시그니처만 정의
  - Entity 타입 사용
```

#### `domain/usecases/`
```yaml
역할: 단일 비즈니스 로직 (Single Responsibility)
파일명 패턴: {verb}_{entity}_usecase.dart

특징:
  - 하나의 UseCase = 하나의 작업
  - execute() 메서드로 실행
  - Repository 의존

예시:
  - get_todo_list_usecase.dart
  - create_todo_usecase.dart
```

#### `presentation/providers/`
```yaml
역할: Riverpod 상태 관리
파일명 패턴: {feature}_provider.dart

특징:
  - @riverpod 어노테이션 사용
  - StateNotifier, FutureProvider 등
  - build_runner로 코드 생성
```

#### `presentation/screens/`
```yaml
역할: 화면 단위 (페이지)
파일명 패턴: {feature}_{type}_screen.dart

특징:
  - StatelessWidget or ConsumerWidget
  - Scaffold 포함
  - 화면 전체 레이아웃

예시:
  - todo_list_screen.dart
  - timer_screen.dart
```

#### `presentation/widgets/`
```yaml
역할: 재사용 가능한 UI 컴포넌트
파일명 패턴: {component_name}.dart

특징:
  - StatelessWidget 우선
  - 특정 화면에 종속되지 않음
  - const 생성자 활용

예시:
  - todo_item.dart
  - fuel_display.dart
```

---

## 파일 명명 규칙

### 1. Dart 파일명
```yaml
규칙: snake_case (소문자 + 언더스코어)

예시:
  ✅ todo_list_screen.dart
  ✅ user_profile_widget.dart
  ✅ auth_repository_impl.dart

  ❌ TodoListScreen.dart
  ❌ user-profile-widget.dart
  ❌ authRepositoryImpl.dart
```

---

### 2. 클래스명
```yaml
규칙: PascalCase (각 단어 첫 글자 대문자)

예시:
  ✅ class TodoListScreen
  ✅ class UserProfileWidget
  ✅ class AuthRepositoryImpl

  ❌ class todoListScreen
  ❌ class user_profile_widget
```

---

### 3. 변수 & 함수명
```yaml
규칙: camelCase (첫 단어 소문자, 나머지 대문자)

예시:
  ✅ final userName = 'John';
  ✅ void getUserData() {}
  ✅ Future<void> fetchTodoList() async {}

  ❌ final UserName = 'John';
  ❌ void get_user_data() {}
```

---

### 4. Private 멤버
```yaml
규칙: _ (언더스코어) 접두사

예시:
  ✅ final _privateVariable = 10;
  ✅ void _privateMethod() {}
  ✅ class _PrivateClass {}

  ❌ final privateVariable = 10; (public)
```

---

### 5. 상수
```yaml
규칙: lowerCamelCase with const

예시:
  ✅ const maxRetryCount = 3;
  ✅ const apiBaseUrl = 'https://api.example.com';

  ❌ const MAX_RETRY_COUNT = 3; (Dart는 UPPER_CASE 사용 안 함)
  ❌ final maxRetryCount = 3; (const 우선)
```

---

### 6. Provider 파일명
```yaml
패턴: {feature}_provider.dart

예시:
  ✅ todo_provider.dart
  ✅ auth_provider.dart
  ✅ timer_provider.dart
```

---

### 7. UseCase 파일명
```yaml
패턴: {verb}_{entity}_usecase.dart

예시:
  ✅ get_todo_list_usecase.dart
  ✅ create_todo_usecase.dart
  ✅ update_user_profile_usecase.dart
  ✅ fetch_ranking_usecase.dart
```

---

### 8. Model/Entity 파일명
```yaml
패턴: {entity}_model.dart (DTO)
      {entity}_entity.dart (Domain)

예시:
  ✅ todo_model.dart (DTO)
  ✅ todo_entity.dart (Domain)
  ✅ user_model.dart
  ✅ fuel_entity.dart
```

---

### 9. DataSource 파일명
```yaml
패턴: {feature}_remote_datasource.dart
      {feature}_local_datasource.dart

예시:
  ✅ todo_remote_datasource.dart
  ✅ todo_local_datasource.dart
  ✅ auth_remote_datasource.dart
```

---

### 10. Repository 파일명
```yaml
패턴: {feature}_repository.dart (interface)
      {feature}_repository_impl.dart (implementation)

예시:
  ✅ todo_repository.dart (interface)
  ✅ todo_repository_impl.dart (implementation)
```

---

## Import 순서 규칙

### 표준 Import 순서
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

// 4. 프로젝트 내부 (상대 경로)
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';

// 5. Part 파일 (코드 생성)
part 'todo_model.freezed.dart';
part 'todo_model.g.dart';
```

### Import 그룹 구분
```dart
// ✅ 좋은 예: 그룹별로 한 줄 띄우기
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';

// ❌ 나쁜 예: 모두 붙여쓰기
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../domain/entities/todo_entity.dart';
part 'todo_model.freezed.dart';
```

---

## Barrel Export 패턴

### Barrel 파일 생성 (선택적)
```dart
// lib/features/todo/todo.dart (Barrel Export)
export 'domain/entities/todo_entity.dart';
export 'domain/repositories/todo_repository.dart';
export 'domain/usecases/get_todo_list_usecase.dart';
export 'presentation/providers/todo_provider.dart';
export 'presentation/screens/todo_list_screen.dart';
```

### Barrel 사용
```dart
// 다른 feature에서 import
import 'package:space_study_ship/features/todo/todo.dart';

// 개별 import 대신 한 줄로
final todos = ref.watch(todoListProvider);
```

### 주의사항
```yaml
장점:
  - Import 줄 수 감소
  - 모듈 간 의존성 명확화

단점:
  - Barrel 파일 유지보수 필요
  - 순환 참조 위험

추천:
  - core/ 에서만 사용
  - features/ 간 import는 개별 파일로
```

---

## 코드 생성 파일 관리

### 자동 생성 파일 패턴
```yaml
Freezed:
  - {file}.freezed.dart
  - {file}.g.dart (JsonSerializable 포함 시)

Riverpod Generator:
  - {file}.g.dart

Retrofit:
  - {file}.g.dart

규칙:
  - .gitignore에 추가하지 않음 (커밋 포함)
  - build_runner로 재생성 가능
```

### 생성 명령어
```bash
# 모든 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (자동 재생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 디렉토리 생성 가이드

### Feature 추가 시 (예: Mission)
```bash
# 1. Feature 디렉토리 생성
mkdir -p lib/features/mission/{data,domain,presentation}/{datasources,models,repositories,entities,usecases,providers,screens,widgets}

# 2. 파일 생성
touch lib/features/mission/data/datasources/mission_remote_datasource.dart
touch lib/features/mission/data/models/mission_model.dart
touch lib/features/mission/domain/entities/mission_entity.dart
touch lib/features/mission/domain/repositories/mission_repository.dart
touch lib/features/mission/domain/usecases/get_missions_usecase.dart
touch lib/features/mission/presentation/providers/mission_provider.dart
touch lib/features/mission/presentation/screens/mission_list_screen.dart
```

---

## 핵심 원칙 요약

### ✅ DO (해야 할 것)
```yaml
- Feature-First 구조 유지
- Clean Architecture 3-Layer 분리
- snake_case 파일명
- PascalCase 클래스명
- camelCase 변수/함수명
- Import 순서 준수
- 자동 생성 파일 커밋 포함
```

### ❌ DON'T (하지 말아야 할 것)
```yaml
- Layer 경계 넘어서는 직접 참조
  (예: Screen에서 DataSource 직접 호출 ❌)
- 파일명에 PascalCase 사용
- UPPER_CASE 상수명
- 순환 참조 (Circular Dependency)
- feature 간 직접 의존 (core 통해 공유)
```

---

## 참고 예시

### 전체 Import 예시 (todo_repository_impl.dart)
```dart
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;

  TodoRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<TodoEntity>> getTodoList() async {
    try {
      final models = await _remoteDataSource.getTodoList();
      final entities = models.map((m) => m.toEntity()).toList();
      await _localDataSource.saveTodoList(models);
      return entities;
    } on DioException catch (e) {
      debugPrint('❌ TodoRepository: Network error - $e');
      final cached = await _localDataSource.getTodoList();
      return cached.map((m) => m.toEntity()).toList();
    } catch (e) {
      debugPrint('❌ TodoRepository: Unexpected error - $e');
      throw ServerException(e.toString());
    }
  }
}
```

---

## 다음 문서
- [03_CODE_CONVENTIONS.md](./03_CODE_CONVENTIONS.md): 코딩 스타일 및 컨벤션
- [04_CODE_GENERATION_GUIDE.md](./04_CODE_GENERATION_GUIDE.md): 코드 생성 템플릿 및 가이드
