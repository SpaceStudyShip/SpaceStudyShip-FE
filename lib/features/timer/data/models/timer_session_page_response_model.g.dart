// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionPageResponseModelImpl
_$$TimerSessionPageResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$TimerSessionPageResponseModelImpl(
      content: (json['content'] as List<dynamic>)
          .map(
            (e) =>
                TimerSessionResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$$TimerSessionPageResponseModelImplToJson(
  _$TimerSessionPageResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'page': instance.page,
  'size': instance.size,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
};
