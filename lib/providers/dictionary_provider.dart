import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/firebase_dictionary_service.dart';

class DictionaryProvider extends ChangeNotifier {
  final FirebaseDictionaryService _service = FirebaseDictionaryService();

  List<DictionaryEntry> _entries = [];
  String _searchQuery = '';

  List<DictionaryEntry> get filteredEntries {
    if (_searchQuery.isEmpty) return _entries;

    final q = _searchQuery.toLowerCase();
    return _entries.where((entry) {
      return entry.arabic.toLowerCase().contains(q) || entry.french.toLowerCase().contains(q) || entry.english.toLowerCase().contains(q);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Listen to Firestore
  void startListening() {
    _service.getEntries().listen((entries) {
      _entries = entries;
      notifyListeners();
    });
  }

  Future<void> addEntry(DictionaryEntry entry) async {
    await _service.addEntry(entry);
  }

  Future<void> updateEntry(String id, DictionaryEntry entry) async {
    await _service.updateEntry(id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
  }
}
