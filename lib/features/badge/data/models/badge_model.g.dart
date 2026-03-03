// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeUnlockModelImpl _$$BadgeUnlockModelImplFromJson(
  Map<String, dynamic> json,
) => _$BadgeUnlockModelImpl(
  badgeId: json['badge_id'] as String,
  unlockedAt: DateTime.parse(json['unlocked_at'] as String),
  isNew: json['is_new'] as bool? ?? true,
);

Map<String, dynamic> _$$BadgeUnlockModelImplToJson(
  _$BadgeUnlockModelImpl instance,
) => <String, dynamic>{
  'badge_id': instance.badgeId,
  'unlocked_at': instance.unlockedAt.toIso8601String(),
  'is_new': instance.isNew,
};
