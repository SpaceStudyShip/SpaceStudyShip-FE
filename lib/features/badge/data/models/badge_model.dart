// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

/// 배지 해금 상태 저장용 모델 (SharedPreferences JSON)
@freezed
class BadgeUnlockModel with _$BadgeUnlockModel {
  const factory BadgeUnlockModel({
    @JsonKey(name: 'badge_id') required String badgeId,
    @JsonKey(name: 'unlocked_at') required DateTime unlockedAt,
    @Default(true) @JsonKey(name: 'is_new') bool isNew,
  }) = _BadgeUnlockModel;

  factory BadgeUnlockModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeUnlockModelFromJson(json);
}
