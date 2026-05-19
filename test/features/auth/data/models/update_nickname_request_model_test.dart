import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_request_model.dart';

void main() {
  test('UpdateNicknameRequestModel 직렬화 라운드트립', () {
    const m = UpdateNicknameRequestModel(nickname: '우주탐험가');
    final round = UpdateNicknameRequestModel.fromJson(m.toJson());

    expect(round, m);
    expect(m.toJson(), {'nickname': '우주탐험가'});
  });
}
