// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ws_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WsEvent {

 String get type;@JsonKey(name: 'role_id') String get roleId; Map<String, dynamic> get payload;
/// Create a copy of WsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsEventCopyWith<WsEvent> get copyWith => _$WsEventCopyWithImpl<WsEvent>(this as WsEvent, _$identity);

  /// Serializes this WsEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,roleId,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'WsEvent(type: $type, roleId: $roleId, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $WsEventCopyWith<$Res>  {
  factory $WsEventCopyWith(WsEvent value, $Res Function(WsEvent) _then) = _$WsEventCopyWithImpl;
@useResult
$Res call({
 String type,@JsonKey(name: 'role_id') String roleId, Map<String, dynamic> payload
});




}
/// @nodoc
class _$WsEventCopyWithImpl<$Res>
    implements $WsEventCopyWith<$Res> {
  _$WsEventCopyWithImpl(this._self, this._then);

  final WsEvent _self;
  final $Res Function(WsEvent) _then;

/// Create a copy of WsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? roleId = null,Object? payload = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [WsEvent].
extension WsEventPatterns on WsEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsEvent value)  $default,){
final _that = this;
switch (_that) {
case _WsEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsEvent value)?  $default,){
final _that = this;
switch (_that) {
case _WsEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'role_id')  String roleId,  Map<String, dynamic> payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsEvent() when $default != null:
return $default(_that.type,_that.roleId,_that.payload);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'role_id')  String roleId,  Map<String, dynamic> payload)  $default,) {final _that = this;
switch (_that) {
case _WsEvent():
return $default(_that.type,_that.roleId,_that.payload);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type, @JsonKey(name: 'role_id')  String roleId,  Map<String, dynamic> payload)?  $default,) {final _that = this;
switch (_that) {
case _WsEvent() when $default != null:
return $default(_that.type,_that.roleId,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsEvent implements WsEvent {
  const _WsEvent({required this.type, @JsonKey(name: 'role_id') required this.roleId, final  Map<String, dynamic> payload = const {}}): _payload = payload;
  factory _WsEvent.fromJson(Map<String, dynamic> json) => _$WsEventFromJson(json);

@override final  String type;
@override@JsonKey(name: 'role_id') final  String roleId;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of WsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsEventCopyWith<_WsEvent> get copyWith => __$WsEventCopyWithImpl<_WsEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&const DeepCollectionEquality().equals(other._payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,roleId,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'WsEvent(type: $type, roleId: $roleId, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$WsEventCopyWith<$Res> implements $WsEventCopyWith<$Res> {
  factory _$WsEventCopyWith(_WsEvent value, $Res Function(_WsEvent) _then) = __$WsEventCopyWithImpl;
@override @useResult
$Res call({
 String type,@JsonKey(name: 'role_id') String roleId, Map<String, dynamic> payload
});




}
/// @nodoc
class __$WsEventCopyWithImpl<$Res>
    implements _$WsEventCopyWith<$Res> {
  __$WsEventCopyWithImpl(this._self, this._then);

  final _WsEvent _self;
  final $Res Function(_WsEvent) _then;

/// Create a copy of WsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? roleId = null,Object? payload = null,}) {
  return _then(_WsEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
