// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthConfig {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthConfig()';
}


}

/// @nodoc
class $AuthConfigCopyWith<$Res>  {
$AuthConfigCopyWith(AuthConfig _, $Res Function(AuthConfig) __);
}


/// Adds pattern-matching-related methods to [AuthConfig].
extension AuthConfigPatterns on AuthConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CopilotAuthConfig value)?  copilot,TResult Function( ByokAuthConfig value)?  byok,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CopilotAuthConfig() when copilot != null:
return copilot(_that);case ByokAuthConfig() when byok != null:
return byok(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CopilotAuthConfig value)  copilot,required TResult Function( ByokAuthConfig value)  byok,}){
final _that = this;
switch (_that) {
case CopilotAuthConfig():
return copilot(_that);case ByokAuthConfig():
return byok(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CopilotAuthConfig value)?  copilot,TResult? Function( ByokAuthConfig value)?  byok,}){
final _that = this;
switch (_that) {
case CopilotAuthConfig() when copilot != null:
return copilot(_that);case ByokAuthConfig() when byok != null:
return byok(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String githubToken)?  copilot,TResult Function( String apiKey,  String baseUrl,  String type,  String model)?  byok,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CopilotAuthConfig() when copilot != null:
return copilot(_that.githubToken);case ByokAuthConfig() when byok != null:
return byok(_that.apiKey,_that.baseUrl,_that.type,_that.model);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String githubToken)  copilot,required TResult Function( String apiKey,  String baseUrl,  String type,  String model)  byok,}) {final _that = this;
switch (_that) {
case CopilotAuthConfig():
return copilot(_that.githubToken);case ByokAuthConfig():
return byok(_that.apiKey,_that.baseUrl,_that.type,_that.model);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String githubToken)?  copilot,TResult? Function( String apiKey,  String baseUrl,  String type,  String model)?  byok,}) {final _that = this;
switch (_that) {
case CopilotAuthConfig() when copilot != null:
return copilot(_that.githubToken);case ByokAuthConfig() when byok != null:
return byok(_that.apiKey,_that.baseUrl,_that.type,_that.model);case _:
  return null;

}
}

}

/// @nodoc


class CopilotAuthConfig implements AuthConfig {
  const CopilotAuthConfig({required this.githubToken});
  

 final  String githubToken;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CopilotAuthConfigCopyWith<CopilotAuthConfig> get copyWith => _$CopilotAuthConfigCopyWithImpl<CopilotAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopilotAuthConfig&&(identical(other.githubToken, githubToken) || other.githubToken == githubToken));
}


@override
int get hashCode => Object.hash(runtimeType,githubToken);

@override
String toString() {
  return 'AuthConfig.copilot(githubToken: $githubToken)';
}


}

/// @nodoc
abstract mixin class $CopilotAuthConfigCopyWith<$Res> implements $AuthConfigCopyWith<$Res> {
  factory $CopilotAuthConfigCopyWith(CopilotAuthConfig value, $Res Function(CopilotAuthConfig) _then) = _$CopilotAuthConfigCopyWithImpl;
@useResult
$Res call({
 String githubToken
});




}
/// @nodoc
class _$CopilotAuthConfigCopyWithImpl<$Res>
    implements $CopilotAuthConfigCopyWith<$Res> {
  _$CopilotAuthConfigCopyWithImpl(this._self, this._then);

  final CopilotAuthConfig _self;
  final $Res Function(CopilotAuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? githubToken = null,}) {
  return _then(CopilotAuthConfig(
githubToken: null == githubToken ? _self.githubToken : githubToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ByokAuthConfig implements AuthConfig {
  const ByokAuthConfig({required this.apiKey, required this.baseUrl, this.type = 'openai', this.model = 'gpt-4o'});
  

 final  String apiKey;
 final  String baseUrl;
@JsonKey() final  String type;
@JsonKey() final  String model;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ByokAuthConfigCopyWith<ByokAuthConfig> get copyWith => _$ByokAuthConfigCopyWithImpl<ByokAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ByokAuthConfig&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,apiKey,baseUrl,type,model);

@override
String toString() {
  return 'AuthConfig.byok(apiKey: $apiKey, baseUrl: $baseUrl, type: $type, model: $model)';
}


}

/// @nodoc
abstract mixin class $ByokAuthConfigCopyWith<$Res> implements $AuthConfigCopyWith<$Res> {
  factory $ByokAuthConfigCopyWith(ByokAuthConfig value, $Res Function(ByokAuthConfig) _then) = _$ByokAuthConfigCopyWithImpl;
@useResult
$Res call({
 String apiKey, String baseUrl, String type, String model
});




}
/// @nodoc
class _$ByokAuthConfigCopyWithImpl<$Res>
    implements $ByokAuthConfigCopyWith<$Res> {
  _$ByokAuthConfigCopyWithImpl(this._self, this._then);

  final ByokAuthConfig _self;
  final $Res Function(ByokAuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiKey = null,Object? baseUrl = null,Object? type = null,Object? model = null,}) {
  return _then(ByokAuthConfig(
apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
