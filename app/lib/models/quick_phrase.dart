import 'dart:convert';

class QuickPhrase {
  const QuickPhrase({required this.id, required this.label, required this.text});

  final String id;
  final String label;
  final String text;

  QuickPhrase copyWith({String? label, String? text}) => QuickPhrase(
        id: id,
        label: label ?? this.label,
        text: text ?? this.text,
      );

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'text': text};

  factory QuickPhrase.fromJson(Map<String, dynamic> json) => QuickPhrase(
        id: json['id'] as String,
        label: json['label'] as String,
        text: json['text'] as String,
      );

  static List<QuickPhrase> listFromJson(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => QuickPhrase.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<QuickPhrase> phrases) =>
      jsonEncode(phrases.map((p) => p.toJson()).toList());
}
