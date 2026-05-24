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

    test('도메인 에러 (401) → UnauthenticatedRequestException throw', () async {
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
