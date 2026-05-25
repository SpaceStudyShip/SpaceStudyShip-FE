import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_response_model.dart';

void main() {
  group('FuelResponseModel', () {
    test('fromJson — 정상 파싱', () {
      final json = {
        'currentFuel': 350,
        'totalCharged': 1200,
        'totalConsumed': 850,
        'pendingMinutes': 0,
        'lastUpdatedAt': '2026-04-16T10:30:00Z',
      };
      final model = FuelResponseModel.fromJson(json);
      expect(model.currentFuel, 350);
      expect(model.totalCharged, 1200);
      expect(model.totalConsumed, 850);
      expect(model.pendingMinutes, 0);
      expect(model.lastUpdatedAt, DateTime.utc(2026, 4, 16, 10, 30));
    });

    test('toEntity — 도메인 엔티티 변환', () {
      final model = FuelResponseModel(
        currentFuel: 350,
        totalCharged: 1200,
        totalConsumed: 850,
        pendingMinutes: 0,
        lastUpdatedAt: DateTime.utc(2026, 4, 16, 10, 30),
      );
      final entity = model.toEntity();
      expect(entity.currentFuel, 350);
      expect(entity.totalCharged, 1200);
      expect(entity.totalConsumed, 850);
      expect(entity.pendingMinutes, 0);
      expect(entity.lastUpdatedAt, DateTime.utc(2026, 4, 16, 10, 30));
    });
  });
}
