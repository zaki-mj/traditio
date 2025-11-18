import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _fav = {};

  bool isFavorite(String id) => _fav.contains(id);

  void toggle(String id) {
    if (_fav.contains(id)) {
      _fav.remove(id);
    } else {
      _fav.add(id);
    }
    notifyListeners();
  }

  List<String> get allFavorites => _fav.toList(growable: false);

  void clearAll() {
    _fav.clear();
    notifyListeners();
  }
}
