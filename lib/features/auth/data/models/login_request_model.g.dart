// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestModelImpl _$$LoginRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoginRequestModelImpl(
  socialType: json['socialType'] as String,
  idToken: json['idToken'] as String,
  fcmToken: json['fcmToken'] as String,
  deviceType: json['deviceType'] as String,
  deviceId: json['deviceId'] as String,
);

Map<String, dynamic> _$$LoginRequestModelImplToJson(
  _$LoginRequestModelImpl instance,
) => <String, dynamic>{
  'socialType': instance.socialType,
  'idToken': instance.idToken,
  'fcmToken': instance.fcmToken,
  'deviceType': instance.deviceType,
  'deviceId': instance.deviceId,
};
