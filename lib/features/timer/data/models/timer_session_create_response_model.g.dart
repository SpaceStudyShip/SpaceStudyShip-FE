// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_create_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionCreateResponseModelImpl
_$$TimerSessionCreateResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$TimerSessionCreateResponseModelImpl(
      session: TimerSessionResponseModel.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      fuelCharged: (json['fuelCharged'] as num).toInt(),
    );

Map<String, dynamic> _$$TimerSessionCreateResponseModelImplToJson(
  _$TimerSessionCreateResponseModelImpl instance,
) => <String, dynamic>{
  'session': instance.session,
  'fuelCharged': instance.fuelCharged,
};
