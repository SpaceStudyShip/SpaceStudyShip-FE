import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/login_request_model.dart';

void main() {
  group('LoginRequestModel', () {
    test('5필드를 모두 직렬화한다', () {
      const model = LoginRequestModel(
        socialType: 'GOOGLE',
        idToken: 'eyJhbGc...',
        fcmToken: 'fcm-abc',
        deviceType: 'IOS',
        deviceId: '550e8400-e29b-41d4-a716-446655440000',
      );

      final json = model.toJson();

      expect(
        json.keys,
        containsAll([
          'socialType',
          'idToken',
          'fcmToken',
          'deviceType',
          'deviceId',
        ]),
      );
      expect(json['socialType'], 'GOOGLE');
      expect(json['idToken'], 'eyJhbGc...');
      expect(json['fcmToken'], 'fcm-abc');
      expect(json['deviceType'], 'IOS');
      expect(json['deviceId'], '550e8400-e29b-41d4-a716-446655440000');
    });

    test('fromJson 라운드트립', () {
      const original = LoginRequestModel(
        socialType: 'APPLE',
        idToken: 't1',
        fcmToken: 'f1',
        deviceType: 'ANDROID',
        deviceId: '11111111-2222-3333-4444-555555555555',
      );

      final round = LoginRequestModel.fromJson(original.toJson());

      expect(round, original);
    });
  });
}
