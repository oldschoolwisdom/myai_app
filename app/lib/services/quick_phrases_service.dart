import 'dart:io';
import '../models/quick_phrase.dart';

/// Reads and writes quick phrases as JSON to `myai_phrases.json`
/// in the same directory as `myai.env` (project root).
class QuickPhrasesService {
  static const _fileName = 'myai_phrases.json';

  static String _filePath() {
    final appDir = Directory.current.path;
    return '$appDir/../../$_fileName';
  }

  Future<List<QuickPhrase>> load() async {
    final file = File(_filePath());
    if (!await file.exists()) return QuickPhrasesService.defaults();
    try {
      final raw = await file.readAsString();
      return QuickPhrase.listFromJson(raw);
    } catch (_) {
      return QuickPhrasesService.defaults();
    }
  }

  Future<void> save(List<QuickPhrase> phrases) async {
    final file = File(_filePath());
    await file.writeAsString(QuickPhrase.listToJson(phrases));
  }

  static List<QuickPhrase> defaults() => const [
        QuickPhrase(id: 'update_issue', label: '更新 Issue', text: '更新 Issue'),
      ];
}
