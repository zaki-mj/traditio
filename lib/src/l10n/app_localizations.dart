import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _translations = {
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
      'type_store': 'Stores',
      'type_other': 'Everything Else',
      'about_us': 'About Us',
      'logout': 'Logout',
      'admin_panel': 'Admin Panel',
      'guest': 'Guest',
      'dashboard': 'Dashboard',
      'places': 'Places',
      'home': 'Home',
      'categories': 'Categories',
      'favorites': 'Favorites',
      'favorites_cleared': 'Favorites cleared',
      'add_new_place': 'Add new place',
      'search_places': 'Search places...',
      'all_types': 'All Types',
      'total_places': 'Total Places',
      'average_rating': 'Average Rating',
      'by_type': 'By Type',
      'by_location': 'By Location',
      'hotels': 'Hotels',
      'restaurants': 'Restaurants',
      'attractions': 'Attractions',
      'no_places_found': 'No places found',
      'edit': 'Edit',
      'delete': 'Delete',
      'clear_filters': 'Clear Filters',
      'search': 'Search',
      'dark_mode': 'Dark Mode',
      'clear_all_favorites': 'Clear All Favorites',
      'light_mode': 'Light Mode',
      'cancel': 'Cancel',
      'contact': 'Contact',
      'social': 'Social Media',
      'address': 'Address',
      'open_map': 'Open Map',
      'phone': 'Phone',
      'email': 'Email',
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
      'type_store': 'متاجر',
      'type_other': 'كل شيء آخر',
      'about_us': 'من نحن',
      'logout': 'تسجيل الخروج',
      'admin_panel': 'لوحة المسؤول',
      'guest': 'ضيف',
      'dashboard': 'لوحة التحكم',
      'places': 'الأماكن',
      'home': 'الرئيسية',
      'categories': 'الفئات',
      'favorites': 'المفضلات',
      'favorites_cleared': 'تم مسح المفضلات',
      'add_new_place': 'إضافة مكان جديد',
      'search_places': 'ابحث عن الأماكن...',
      'all_types': 'جميع الأنواع',
      'total_places': 'إجمالي الأماكن',
      'average_rating': 'متوسط التقييم',
      'by_type': 'حسب النوع',
      'by_location': 'حسب الموقع',
      'hotels': 'الفنادق',
      'restaurants': 'المطاعم',
      'attractions': 'المعالم السياحية',
      'no_places_found': 'لم يتم العثور على أماكن',
      'edit': 'تعديل',
      'delete': 'حذف',
      'clear_filters': 'مسح المرشحات',
      'search': 'بحث',
      'dark_mode': 'الوضع الليلي',
      'clear_all_favorites': 'مسح جميع المفضلات',
      'light_mode': 'الوضع النهاري',
      'cancel': 'إلغاء',
      'contact': 'جهات الاتصال',
      'social': 'وسائل التواصل الاجتماعي',
      'address': 'العنوان',
      'open_map': 'فتح الخريطة',
      'phone': 'هاتف',
      'email': 'بريد إلكتروني',
    },
    'fr': {
      'app_title': 'Traditio',
      'welcome': 'Bienvenue à Traditio',
      'start_discovering': 'Commencer à Découvrir',
      'admin_login': 'Connexion Admin',
      'discover_page': 'Découvrir',
      'admin_page': 'Connexion Admin (placeholder)',
      'search_hint': 'Recherchez des lieux, par ex. "hôtel" ou "Le Caire"',
      'recommended': 'Recommandé',
      'all_places': 'Tous les Lieux',
      'settings': 'Paramètres',
      'settings_title': 'Paramètres',
      'change_theme': 'Changer le Thème',
      'change_language': 'Changer la Langue',
      'type_hotel': 'Hôtel',
      'type_restaurant': 'Restaurant',
      'type_attraction': 'Attraction',
      'no_results': 'Aucun lieu ne correspond à vos filtres',
      'type_store': 'Magasins',
      'type_other': 'Autre',
      'about_us': 'À Propos de Nous',
      'logout': 'Déconnexion',
      'admin_panel': 'Panneau d\'Administration',
      'guest': 'Invité',
      'dashboard': 'Tableau de Bord',
      'places': 'Lieux',
      'add_new_place': 'Ajouter un nouveau lieu',
      'search_places': 'Rechercher des lieux...',
      'all_types': 'Tous les Types',
      'total_places': 'Total des Lieux',
      'average_rating': 'Note Moyenne',
      'by_type': 'Par Type',
      'by_location': 'Par Localisation',
      'hotels': 'Hôtels',
      'restaurants': 'Restaurants',
      'attractions': 'Attractions',
      'no_places_found': 'Aucun lieu trouvé',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'clear_filters': 'Effacer les Filtres',
      'search': 'Rechercher',
      'dark_mode': 'Mode Sombre',
      'clear_all_favorites': 'Effacer Tous les Favoris',
      'light_mode': 'Mode Clair',
      'cancel': 'Annuler',
      'contact': 'Contact',
      'social': 'Réseaux Sociaux',
      'address': 'Adresse',
      'open_map': 'Ouvrir la Carte',
      'phone': 'Téléphone',
      'email': 'E-mail',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // As this is a tiny synchronous map-based loader, we can return immediate
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
