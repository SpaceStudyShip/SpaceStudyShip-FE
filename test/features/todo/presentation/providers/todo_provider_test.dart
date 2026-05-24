import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/todo/data/datasources/local_todo_datasource.dart';
import 'package:space_study_ship/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:space_study_ship/features/todo/data/repositories/local_todo_repository_impl.dart';
import 'package:space_study_ship/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:space_study_ship/features/todo/presentation/providers/todo_provider.dart';

class _MockRemote extends Mock implements TodoRemoteDataSource {}

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
          localTodoDataSourceProvider.overrideWithValue(
            LocalTodoDataSource(prefs),
          ),
          isAuthenticatedProvider.overrideWith((ref) => false),
        ],
      );

      final repo = container.read(todoRepositoryProvider);

      expect(repo, isA<LocalTodoRepositoryImpl>());
    });

    test('인증 상태 → TodoRepositoryImpl 반환', () {
      container = ProviderContainer(
        overrides: [
          localTodoDataSourceProvider.overrideWithValue(
            LocalTodoDataSource(prefs),
          ),
          todoRemoteDataSourceProvider.overrideWithValue(_MockRemote()),
          isAuthenticatedProvider.overrideWith((ref) => true),
        ],
      );

      final repo = container.read(todoRepositoryProvider);

      expect(repo, isA<TodoRepositoryImpl>());
    });

    test('인증 → 미인증 전환 시 Repository 가 변경된다', () {
      container = ProviderContainer(
        overrides: [
          localTodoDataSourceProvider.overrideWithValue(
            LocalTodoDataSource(prefs),
          ),
          todoRemoteDataSourceProvider.overrideWithValue(_MockRemote()),
          isAuthenticatedProvider.overrideWith((ref) => true),
        ],
      );

      expect(container.read(todoRepositoryProvider), isA<TodoRepositoryImpl>());

      // 미인증 상태로 override 갱신 — 새 컨테이너로 재구성
      container.dispose();
      container = ProviderContainer(
        overrides: [
          localTodoDataSourceProvider.overrideWithValue(
            LocalTodoDataSource(prefs),
          ),
          isAuthenticatedProvider.overrideWith((ref) => false),
        ],
      );

      expect(
        container.read(todoRepositoryProvider),
        isA<LocalTodoRepositoryImpl>(),
      );
    });
  });
}
