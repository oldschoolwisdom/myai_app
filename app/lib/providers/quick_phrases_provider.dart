import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/quick_phrase.dart';
import '../services/quick_phrases_service.dart';

part 'quick_phrases_provider.g.dart';

@Riverpod(keepAlive: true)
class QuickPhrases extends _$QuickPhrases {
  final _service = QuickPhrasesService();

  @override
  List<QuickPhrase> build() => QuickPhrasesService.defaults();

  Future<void> loadFromDisk() async {
    state = await _service.load();
  }

  Future<void> add(QuickPhrase phrase) async {
    state = [...state, phrase];
    await _service.save(state);
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _service.save(state);
  }

  Future<void> update(QuickPhrase updated) async {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    await _service.save(state);
  }

  Future<void> reorder(List<QuickPhrase> reordered) async {
    state = reordered;
    await _service.save(state);
  }
}
