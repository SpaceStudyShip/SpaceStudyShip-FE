// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nickname_form_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NicknameFormState {
  String get input => throw _privateConstructorUsedError;
  String get serverNickname => throw _privateConstructorUsedError;
  NicknameValidationStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get isCheckingDuplicate => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;

  /// Create a copy of NicknameFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NicknameFormStateCopyWith<NicknameFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NicknameFormStateCopyWith<$Res> {
  factory $NicknameFormStateCopyWith(
    NicknameFormState value,
    $Res Function(NicknameFormState) then,
  ) = _$NicknameFormStateCopyWithImpl<$Res, NicknameFormState>;
  @useResult
  $Res call({
    String input,
    String serverNickname,
    NicknameValidationStatus status,
    String? errorMessage,
    bool isCheckingDuplicate,
    bool isSubmitting,
  });
}

/// @nodoc
class _$NicknameFormStateCopyWithImpl<$Res, $Val extends NicknameFormState>
    implements $NicknameFormStateCopyWith<$Res> {
  _$NicknameFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NicknameFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? serverNickname = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? isCheckingDuplicate = null,
    Object? isSubmitting = null,
  }) {
    return _then(
      _value.copyWith(
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as String,
            serverNickname: null == serverNickname
                ? _value.serverNickname
                : serverNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NicknameValidationStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCheckingDuplicate: null == isCheckingDuplicate
                ? _value.isCheckingDuplicate
                : isCheckingDuplicate // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NicknameFormStateImplCopyWith<$Res>
    implements $NicknameFormStateCopyWith<$Res> {
  factory _$$NicknameFormStateImplCopyWith(
    _$NicknameFormStateImpl value,
    $Res Function(_$NicknameFormStateImpl) then,
  ) = __$$NicknameFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String input,
    String serverNickname,
    NicknameValidationStatus status,
    String? errorMessage,
    bool isCheckingDuplicate,
    bool isSubmitting,
  });
}

/// @nodoc
class __$$NicknameFormStateImplCopyWithImpl<$Res>
    extends _$NicknameFormStateCopyWithImpl<$Res, _$NicknameFormStateImpl>
    implements _$$NicknameFormStateImplCopyWith<$Res> {
  __$$NicknameFormStateImplCopyWithImpl(
    _$NicknameFormStateImpl _value,
    $Res Function(_$NicknameFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NicknameFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? serverNickname = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? isCheckingDuplicate = null,
    Object? isSubmitting = null,
  }) {
    return _then(
      _$NicknameFormStateImpl(
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as String,
        serverNickname: null == serverNickname
            ? _value.serverNickname
            : serverNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NicknameValidationStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCheckingDuplicate: null == isCheckingDuplicate
            ? _value.isCheckingDuplicate
            : isCheckingDuplicate // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$NicknameFormStateImpl
    with DiagnosticableTreeMixin
    implements _NicknameFormState {
  const _$NicknameFormStateImpl({
    required this.input,
    required this.serverNickname,
    this.status = NicknameValidationStatus.idle,
    this.errorMessage,
    this.isCheckingDuplicate = false,
    this.isSubmitting = false,
  });

  @override
  final String input;
  @override
  final String serverNickname;
  @override
  @JsonKey()
  final NicknameValidationStatus status;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool isCheckingDuplicate;
  @override
  @JsonKey()
  final bool isSubmitting;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NicknameFormState(input: $input, serverNickname: $serverNickname, status: $status, errorMessage: $errorMessage, isCheckingDuplicate: $isCheckingDuplicate, isSubmitting: $isSubmitting)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NicknameFormState'))
      ..add(DiagnosticsProperty('input', input))
      ..add(DiagnosticsProperty('serverNickname', serverNickname))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty('isCheckingDuplicate', isCheckingDuplicate))
      ..add(DiagnosticsProperty('isSubmitting', isSubmitting));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NicknameFormStateImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.serverNickname, serverNickname) ||
                other.serverNickname == serverNickname) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isCheckingDuplicate, isCheckingDuplicate) ||
                other.isCheckingDuplicate == isCheckingDuplicate) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    input,
    serverNickname,
    status,
    errorMessage,
    isCheckingDuplicate,
    isSubmitting,
  );

  /// Create a copy of NicknameFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NicknameFormStateImplCopyWith<_$NicknameFormStateImpl> get copyWith =>
      __$$NicknameFormStateImplCopyWithImpl<_$NicknameFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _NicknameFormState implements NicknameFormState {
  const factory _NicknameFormState({
    required final String input,
    required final String serverNickname,
    final NicknameValidationStatus status,
    final String? errorMessage,
    final bool isCheckingDuplicate,
    final bool isSubmitting,
  }) = _$NicknameFormStateImpl;

  @override
  String get input;
  @override
  String get serverNickname;
  @override
  NicknameValidationStatus get status;
  @override
  String? get errorMessage;
  @override
  bool get isCheckingDuplicate;
  @override
  bool get isSubmitting;

  /// Create a copy of NicknameFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NicknameFormStateImplCopyWith<_$NicknameFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
