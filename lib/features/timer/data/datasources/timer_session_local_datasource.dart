import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_session_model.dart';

class TimerSessionLocalDataSource {
  static const _sessionsKey = 'guest_timer_sessions';

  final SharedPreferences _prefs;

  TimerSessionLocalDataSource(this._prefs);

  List<TimerSessionModel> getSessions() {
    final jsonString = _prefs.getString(_sessionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TimerSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_sessionsKey);
      return [];
    }
  }

  Future<void> saveSessions(List<TimerSessionModel> sessions) async {
    final jsonString = json.encode(sessions.map((e) => e.toJson()).toList());
    await _prefs.setString(_sessionsKey, jsonString);
  }

  Future<void> addSession(TimerSessionModel session) async {
    final sessions = getSessions();
    sessions.add(session);
    await saveSessions(sessions);
  }
}
