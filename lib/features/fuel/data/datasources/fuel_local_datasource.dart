import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_model.dart';
import '../models/fuel_transaction_model.dart';

class FuelLocalDataSource {
  static const _fuelKey = 'guest_fuel_data';
  static const _transactionsKey = 'guest_fuel_transactions';

  final SharedPreferences _prefs;

  FuelLocalDataSource(this._prefs);

  FuelModel getFuel() {
    final jsonString = _prefs.getString(_fuelKey);
    if (jsonString == null) {
      return FuelModel(lastUpdatedAt: DateTime.now());
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FuelModel.fromJson(json);
    } catch (e) {
      debugPrint('⚠️ Fuel 데이터 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_fuelKey);
      return FuelModel(lastUpdatedAt: DateTime.now());
    }
  }

  Future<void> saveFuel(FuelModel fuel) async {
    final jsonString = jsonEncode(fuel.toJson());
    await _prefs.setString(_fuelKey, jsonString);
  }

  List<FuelTransactionModel> getTransactions() {
    final jsonString = _prefs.getString(_transactionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => FuelTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Fuel 트랜잭션 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_transactionsKey);
      return [];
    }
  }

  Future<void> saveTransactions(List<FuelTransactionModel> transactions) async {
    final jsonString = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionsKey, jsonString);
  }

  Future<void> addTransaction(FuelTransactionModel transaction) async {
    final transactions = getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  Future<void> clearAll() async {
    final fuel = getFuel();
    final txCount = getTransactions().length;
    await _prefs.remove(_fuelKey);
    await _prefs.remove(_transactionsKey);
    debugPrint(
      '🧹 Fuel 캐시 삭제 완료 '
      '(연료: ${fuel.currentFuel}통, 누적분: ${fuel.pendingMinutes}분, '
      '트랜잭션: $txCount건)',
    );
  }
}
