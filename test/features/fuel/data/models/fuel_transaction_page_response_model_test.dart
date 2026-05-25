import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_page_response_model.dart';

void main() {
  group('FuelTransactionPageResponseModel', () {
    test('fromJson — 다중 항목 페이지 파싱', () {
      final json = {
        'content': [
          {
            'id': 'tx-1',
            'type': 'charge',
            'amount': 90,
            'reason': 'STUDY_SESSION',
            'referenceId': 'session-1',
            'balanceAfter': 350,
            'createdAt': '2026-04-16T10:30:00Z',
          },
        ],
        'page': 0,
        'size': 20,
        'totalElements': 120,
        'totalPages': 6,
      };
      final model = FuelTransactionPageResponseModel.fromJson(json);
      expect(model.content, hasLength(1));
      expect(model.page, 0);
      expect(model.size, 20);
      expect(model.totalElements, 120);
      expect(model.totalPages, 6);
    });

    test('fromJson — content 비어있는 페이지', () {
      final json = {
        'content': <Map<String, dynamic>>[],
        'page': 5,
        'size': 20,
        'totalElements': 100,
        'totalPages': 5,
      };
      final model = FuelTransactionPageResponseModel.fromJson(json);
      expect(model.content, isEmpty);
      expect(model.page, 5);
    });

    test('toEntity — Page 도메인 변환 + hasNext', () {
      final model = FuelTransactionPageResponseModel(
        content: const [],
        page: 0,
        size: 20,
        totalElements: 120,
        totalPages: 6,
      );
      final page = model.toEntity();
      expect(page.items, isEmpty);
      expect(page.hasNext, isTrue);
    });

    test('toEntity — 마지막 페이지 → hasNext false', () {
      final model = FuelTransactionPageResponseModel(
        content: const [],
        page: 5,
        size: 20,
        totalElements: 120,
        totalPages: 6,
      );
      expect(model.toEntity().hasNext, isFalse);
    });
  });
}
