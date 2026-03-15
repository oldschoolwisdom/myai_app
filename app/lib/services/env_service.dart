import 'dart:io';

class EnvService {
  final Map<String, String> _values = {};
  bool _loaded = false;
  String? _loadedPath;

  Future<void> load({String? path}) async {
    final envPath = path ?? _defaultEnvPath();
    _loadedPath = envPath;
    final file = File(envPath);
    if (!await file.exists()) return;
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx < 0) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      _values[key] = value;
    }
    _loaded = true;
  }

  String? get(String key) => _values[key];

  Map<String, String> getAll() => Map.unmodifiable(_values);

  bool get isLoaded => _loaded;

  /// Update a key in memory and immediately write back to the file.
  Future<void> set(String key, String value) async {
    _values[key] = value;
    await _persist();
  }

  Future<void> _persist() async {
    final filePath = _loadedPath ?? _defaultEnvPath();
    final file = File(filePath);

    // Read existing lines to preserve comments and ordering.
    final existingLines =
        file.existsSync() ? await file.readAsLines() : <String>[];

    final updated = <String>[];
    final written = <String>{};

    for (final line in existingLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        updated.add(line);
        continue;
      }
      final idx = trimmed.indexOf('=');
      if (idx < 0) {
        updated.add(line);
        continue;
      }
      final key = trimmed.substring(0, idx).trim();
      if (_values.containsKey(key)) {
        updated.add('$key=${_values[key]}');
        written.add(key);
      } else {
        updated.add(line);
      }
    }

    // Append any keys not already in the file.
    for (final entry in _values.entries) {
      if (!written.contains(entry.key)) {
        updated.add('${entry.key}=${entry.value}');
      }
    }

    await file.writeAsString('${updated.join('\n')}\n');
  }

  static String _defaultEnvPath() {
    // At runtime, cwd is the app's code/ dir.
    // Project root is 2 levels up: code/ → app/ → project_root/
    final appDir = Directory.current.path;
    return '$appDir/../../myai.env';
  }
}
