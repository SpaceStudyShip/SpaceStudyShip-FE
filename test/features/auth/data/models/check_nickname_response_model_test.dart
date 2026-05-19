import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/check_nickname_response_model.dart';

void main() {
  test('CheckNicknameResponseModel available=true 파싱', () {
    final m = CheckNicknameResponseModel.fromJson({'available': true});
    expect(m.available, isTrue);
  });

  test('CheckNicknameResponseModel available=false 파싱', () {
    final m = CheckNicknameResponseModel.fromJson({'available': false});
    expect(m.available, isFalse);
  });
}
