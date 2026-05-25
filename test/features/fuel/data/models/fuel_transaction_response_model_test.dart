import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_response_model.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_entity.dart';

void main() {
  group('FuelTransactionResponseModel', () {
    test('fromJson — charge / STUDY_SESSION 매핑', () {
      final json = {
        'id': 'tx-1',
        'type': 'charge',
        'amount': 90,
        'reason': 'STUDY_SESSION',
        'referenceId': 'session-1',
        'balanceAfter': 350,
        'createdAt': '2026-04-16T10:30:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.id, 'tx-1');
      expect(model.type, FuelTransactionTypeWire.charge);
      expect(model.amount, 90);
      expect(model.reason, FuelTransactionReasonWire.studySession);
      expect(model.referenceId, 'session-1');
      expect(model.balanceAfter, 350);
    });

    test('fromJson — consume / EXPLORATION_UNLOCK 매핑', () {
      final json = {
        'id': 'tx-2',
        'type': 'consume',
        'amount': 5,
        'reason': 'EXPLORATION_UNLOCK',
        'referenceId': null,
        'balanceAfter': 345,
        'createdAt': '2026-04-16T10:35:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.type, FuelTransactionTypeWire.consume);
      expect(model.reason, FuelTransactionReasonWire.explorationUnlock);
      expect(model.referenceId, isNull);
    });

    test('fromJson — 미지 reason → fallback (studySession)', () {
      final json = {
        'id': 'tx-3',
        'type': 'charge',
        'amount': 10,
        'reason': 'MISSION_REWARD',
        'balanceAfter': 360,
        'createdAt': '2026-04-16T10:40:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.reason, FuelTransactionReasonWire.studySession);
    });

    test('fromJson — 미지 type → fallback (charge)', () {
      final json = {
        'id': 'tx-x',
        'type': 'UNKNOWN_TYPE',
        'amount': 1,
        'reason': 'STUDY_SESSION',
        'balanceAfter': 1,
        'createdAt': '2026-04-16T10:30:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.type, FuelTransactionTypeWire.charge);
    });

    test('toEntity — wire enum → 도메인 enum 매핑', () {
      final model = FuelTransactionResponseModel(
        id: 'tx-1',
        type: FuelTransactionTypeWire.charge,
        amount: 90,
        reason: FuelTransactionReasonWire.studySession,
        referenceId: 'session-1',
        balanceAfter: 350,
        createdAt: DateTime.utc(2026, 4, 16, 10, 30),
      );
      final entity = model.toEntity();
      expect(entity.type, FuelTransactionType.charge);
      expect(entity.reason, FuelTransactionReason.studySession);
      expect(entity.id, 'tx-1');
      expect(entity.balanceAfter, 350);
    });
  });
}
