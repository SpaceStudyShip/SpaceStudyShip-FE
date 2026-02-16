import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_category_model.dart';
import '../models/todo_model.dart';

class LocalTodoDataSource {
  static const _todosKey = 'guest_todos';
  static const _categoriesKey = 'guest_todo_categories';

  final SharedPreferences _prefs;

  LocalTodoDataSource(this._prefs);

  // === Todos ===

  List<TodoModel> getTodos() {
    final jsonString = _prefs.getString(_todosKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_todosKey);
      return [];
    }
  }

  Future<void> saveTodos(List<TodoModel> todos) async {
    final jsonString = json.encode(todos.map((e) => e.toJson()).toList());
    await _prefs.setString(_todosKey, jsonString);
  }

  // === Categories ===

  List<TodoCategoryModel> getCategories() {
    final jsonString = _prefs.getString(_categoriesKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TodoCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_categoriesKey);
      return [];
    }
  }

  Future<void> saveCategories(List<TodoCategoryModel> categories) async {
    final jsonString = json.encode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_categoriesKey, jsonString);
  }

  // === Clear ===

  Future<void> clearAll() async {
    await _prefs.remove(_todosKey);
    await _prefs.remove(_categoriesKey);
  }
}
