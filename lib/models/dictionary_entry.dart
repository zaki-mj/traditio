class DictionaryEntry {
  final String? id;
  final String arabic;
  final String french;
  final String english;

  DictionaryEntry({this.id, required this.arabic, required this.french, required this.english});

  Map<String, dynamic> toMap() {
    return {'arabic': arabic.trim(), 'french': french.trim(), 'english': english.trim(), 'createdAt': DateTime.now().toIso8601String()};
  }

  factory DictionaryEntry.fromMap(Map<String, dynamic> map, String id) {
    return DictionaryEntry(id: id, arabic: map['arabic'] ?? '', french: map['french'] ?? '', english: map['english'] ?? '');
  }
}
