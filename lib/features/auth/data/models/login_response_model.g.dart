// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseModelImpl _$$LoginResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoginResponseModelImpl(
  memberId: (json['memberId'] as num).toInt(),
  nickname: json['nickname'] as String,
  tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
  isNewMember: json['isNewMember'] as bool,
);

Map<String, dynamic> _$$LoginResponseModelImplToJson(
  _$LoginResponseModelImpl instance,
) => <String, dynamic>{
  'memberId': instance.memberId,
  'nickname': instance.nickname,
  'tokens': instance.tokens,
  'isNewMember': instance.isNewMember,
};

_$TokensModelImpl _$$TokensModelImplFromJson(Map<String, dynamic> json) =>
    _$TokensModelImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$TokensModelImplToJson(_$TokensModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
