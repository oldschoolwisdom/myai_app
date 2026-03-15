// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoleConfig {

 String get id;@JsonKey(name: 'prompt_path') String get promptPath;@JsonKey(name: 'work_dir') String get workDir; String get model;
/// Create a copy of RoleConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleConfigCopyWith<RoleConfig> get copyWith => _$RoleConfigCopyWithImpl<RoleConfig>(this as RoleConfig, _$identity);

  /// Serializes this RoleConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.promptPath, promptPath) || other.promptPath == promptPath)&&(identical(other.workDir, workDir) || other.workDir == workDir)&&(identical(other.model, model) || other.model == model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,promptPath,workDir,model);

@override
String toString() {
  return 'RoleConfig(id: $id, promptPath: $promptPath, workDir: $workDir, model: $model)';
}


}

/// @nodoc
abstract mixin class $RoleConfigCopyWith<$Res>  {
  factory $RoleConfigCopyWith(RoleConfig value, $Res Function(RoleConfig) _then) = _$RoleConfigCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'prompt_path') String promptPath,@JsonKey(name: 'work_dir') String workDir, String model
});




}
/// @nodoc
class _$RoleConfigCopyWithImpl<$Res>
    implements $RoleConfigCopyWith<$Res> {
  _$RoleConfigCopyWithImpl(this._self, this._then);

  final RoleConfig _self;
  final $Res Function(RoleConfig) _then;

/// Create a copy of RoleConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? promptPath = null,Object? workDir = null,Object? model = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,promptPath: null == promptPath ? _self.promptPath : promptPath // ignore: cast_nullable_to_non_nullable
as String,workDir: null == workDir ? _self.workDir : workDir // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleConfig].
extension RoleConfigPatterns on RoleConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleConfig value)  $default,){
final _that = this;
switch (_that) {
case _RoleConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RoleConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'prompt_path')  String promptPath, @JsonKey(name: 'work_dir')  String workDir,  String model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleConfig() when $default != null:
return $default(_that.id,_that.promptPath,_that.workDir,_that.model);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'prompt_path')  String promptPath, @JsonKey(name: 'work_dir')  String workDir,  String model)  $default,) {final _that = this;
switch (_that) {
case _RoleConfig():
return $default(_that.id,_that.promptPath,_that.workDir,_that.model);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'prompt_path')  String promptPath, @JsonKey(name: 'work_dir')  String workDir,  String model)?  $default,) {final _that = this;
switch (_that) {
case _RoleConfig() when $default != null:
return $default(_that.id,_that.promptPath,_that.workDir,_that.model);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleConfig implements RoleConfig {
  const _RoleConfig({required this.id, @JsonKey(name: 'prompt_path') required this.promptPath, @JsonKey(name: 'work_dir') required this.workDir, this.model = 'claude-sonnet-4.6'});
  factory _RoleConfig.fromJson(Map<String, dynamic> json) => _$RoleConfigFromJson(json);

@override final  String id;
@override@JsonKey(name: 'prompt_path') final  String promptPath;
@override@JsonKey(name: 'work_dir') final  String workDir;
@override@JsonKey() final  String model;

/// Create a copy of RoleConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleConfigCopyWith<_RoleConfig> get copyWith => __$RoleConfigCopyWithImpl<_RoleConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.promptPath, promptPath) || other.promptPath == promptPath)&&(identical(other.workDir, workDir) || other.workDir == workDir)&&(identical(other.model, model) || other.model == model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,promptPath,workDir,model);

@override
String toString() {
  return 'RoleConfig(id: $id, promptPath: $promptPath, workDir: $workDir, model: $model)';
}


}

/// @nodoc
abstract mixin class _$RoleConfigCopyWith<$Res> implements $RoleConfigCopyWith<$Res> {
  factory _$RoleConfigCopyWith(_RoleConfig value, $Res Function(_RoleConfig) _then) = __$RoleConfigCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'prompt_path') String promptPath,@JsonKey(name: 'work_dir') String workDir, String model
});




}
/// @nodoc
class __$RoleConfigCopyWithImpl<$Res>
    implements _$RoleConfigCopyWith<$Res> {
  __$RoleConfigCopyWithImpl(this._self, this._then);

  final _RoleConfig _self;
  final $Res Function(_RoleConfig) _then;

/// Create a copy of RoleConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? promptPath = null,Object? workDir = null,Object? model = null,}) {
  return _then(_RoleConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,promptPath: null == promptPath ? _self.promptPath : promptPath // ignore: cast_nullable_to_non_nullable
as String,workDir: null == workDir ? _self.workDir : workDir // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
