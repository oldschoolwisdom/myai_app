// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Messages)
final messagesProvider = MessagesFamily._();

final class MessagesProvider
    extends $NotifierProvider<Messages, List<Message>> {
  MessagesProvider._({
    required MessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Messages create() => Messages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'6f546ba429aad0600b743fe966d86accc3ce2e4c';

final class MessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          Messages,
          List<Message>,
          List<Message>,
          List<Message>,
          String
        > {
  MessagesFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MessagesProvider call(String roleId) =>
      MessagesProvider._(argument: roleId, from: this);

  @override
  String toString() => r'messagesProvider';
}

abstract class _$Messages extends $Notifier<List<Message>> {
  late final _$args = ref.$arg as String;
  String get roleId => _$args;

  List<Message> build(String roleId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Message>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Message>, List<Message>>,
              List<Message>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
