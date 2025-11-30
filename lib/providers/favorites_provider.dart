import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _fav = {};
  static const _prefsKey = 'favorites_ids';

  FavoritesProvider() {
    _loadFromPrefs();
  }

  bool isFavorite(String id) => _fav.contains(id);

  Future<void> toggle(String id) async {
    if (_fav.contains(id)) {
      _fav.remove(id);
    } else {
      _fav.add(id);
    }
    notifyListeners();
    _saveToPrefs();
  }

  List<String> get allFavorites => _fav.toList(growable: false);

  void clearAll() {
    _fav.clear();
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _fav.toList(growable: false));
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? [];
      _fav.addAll(list);
      notifyListeners();
    } catch (_) {}
  }
}
