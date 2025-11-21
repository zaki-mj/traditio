import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  // Default to Arabic as the main app language
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
