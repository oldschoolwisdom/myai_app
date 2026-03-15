// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PermissionRequest {

 String get requestId; String get roleId; String get question; List<String> get choices;
/// Create a copy of PermissionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionRequestCopyWith<PermissionRequest> get copyWith => _$PermissionRequestCopyWithImpl<PermissionRequest>(this as PermissionRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionRequest&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other.choices, choices));
}


@override
int get hashCode => Object.hash(runtimeType,requestId,roleId,question,const DeepCollectionEquality().hash(choices));

@override
String toString() {
  return 'PermissionRequest(requestId: $requestId, roleId: $roleId, question: $question, choices: $choices)';
}


}

/// @nodoc
abstract mixin class $PermissionRequestCopyWith<$Res>  {
  factory $PermissionRequestCopyWith(PermissionRequest value, $Res Function(PermissionRequest) _then) = _$PermissionRequestCopyWithImpl;
@useResult
$Res call({
 String requestId, String roleId, String question, List<String> choices
});




}
/// @nodoc
class _$PermissionRequestCopyWithImpl<$Res>
    implements $PermissionRequestCopyWith<$Res> {
  _$PermissionRequestCopyWithImpl(this._self, this._then);

  final PermissionRequest _self;
  final $Res Function(PermissionRequest) _then;

/// Create a copy of PermissionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? roleId = null,Object? question = null,Object? choices = null,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PermissionRequest].
extension PermissionRequestPatterns on PermissionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PermissionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PermissionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PermissionRequest value)  $default,){
final _that = this;
switch (_that) {
case _PermissionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PermissionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PermissionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestId,  String roleId,  String question,  List<String> choices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PermissionRequest() when $default != null:
return $default(_that.requestId,_that.roleId,_that.question,_that.choices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestId,  String roleId,  String question,  List<String> choices)  $default,) {final _that = this;
switch (_that) {
case _PermissionRequest():
return $default(_that.requestId,_that.roleId,_that.question,_that.choices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestId,  String roleId,  String question,  List<String> choices)?  $default,) {final _that = this;
switch (_that) {
case _PermissionRequest() when $default != null:
return $default(_that.requestId,_that.roleId,_that.question,_that.choices);case _:
  return null;

}
}

}

/// @nodoc


class _PermissionRequest implements PermissionRequest {
  const _PermissionRequest({required this.requestId, required this.roleId, required this.question, final  List<String> choices = const []}): _choices = choices;
  

@override final  String requestId;
@override final  String roleId;
@override final  String question;
 final  List<String> _choices;
@override@JsonKey() List<String> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}


/// Create a copy of PermissionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionRequestCopyWith<_PermissionRequest> get copyWith => __$PermissionRequestCopyWithImpl<_PermissionRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionRequest&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._choices, _choices));
}


@override
int get hashCode => Object.hash(runtimeType,requestId,roleId,question,const DeepCollectionEquality().hash(_choices));

@override
String toString() {
  return 'PermissionRequest(requestId: $requestId, roleId: $roleId, question: $question, choices: $choices)';
}


}

/// @nodoc
abstract mixin class _$PermissionRequestCopyWith<$Res> implements $PermissionRequestCopyWith<$Res> {
  factory _$PermissionRequestCopyWith(_PermissionRequest value, $Res Function(_PermissionRequest) _then) = __$PermissionRequestCopyWithImpl;
@override @useResult
$Res call({
 String requestId, String roleId, String question, List<String> choices
});




}
/// @nodoc
class __$PermissionRequestCopyWithImpl<$Res>
    implements _$PermissionRequestCopyWith<$Res> {
  __$PermissionRequestCopyWithImpl(this._self, this._then);

  final _PermissionRequest _self;
  final $Res Function(_PermissionRequest) _then;

/// Create a copy of PermissionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? roleId = null,Object? question = null,Object? choices = null,}) {
  return _then(_PermissionRequest(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
