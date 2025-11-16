import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Traditio',
      'welcome': 'Welcome to Traditio',
      'start_discovering': 'Start Discovering',
      'admin_login': 'Admin Login',
      'discover_page': 'Discover',
      'admin_page': 'Admin Login (placeholder)',
      'search_hint': 'Search places, e.g., "hotel" or "Cairo"',
      'recommended': 'Recommended',
      'all_places': 'All Places',
      'settings': 'Settings',
      'settings_title': 'Settings',
      'change_theme': 'Change Theme',
      'change_language': 'Change Language',
      'type_hotel': 'Hotel',
      'type_restaurant': 'Restaurant',
      'type_attraction': 'Attraction',
      'no_results': 'No places match your filters',
    },
    'ar': {
      'app_title': 'ترديتيو',
      'welcome': 'مرحبا بك في ترديتيو',
      'start_discovering': 'ابدأ الاكتشاف',
      'admin_login': 'دخول المسؤول',
      'discover_page': 'الاكتشاف',
      'admin_page': 'دخول المسؤول (عنصر نائب)',
      'search_hint': 'ابحث عن أماكن، مثلاً "فندق" أو "القاهرة"',
      'recommended': 'موصى به',
      'all_places': 'جميع الأماكن',
      'settings': 'الإعدادات',
      'settings_title': 'الإعدادات',
      'change_theme': 'تغيير المظهر',
      'change_language': 'تغيير اللغة',
      'type_hotel': 'فندق',
      'type_restaurant': 'مطعم',
      'type_attraction': 'معلم',
      'no_results': 'لا توجد أماكن تطابق عوامل التصفية',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('ar'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // As this is a tiny synchronous map-based loader, we can return immediate
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
