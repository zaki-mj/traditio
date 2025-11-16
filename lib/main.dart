import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/locale_provider.dart';
import 'src/providers/places_provider.dart';
import 'src/providers/favorites_provider.dart';
import 'src/theme/app_theme.dart';
import 'src/l10n/app_localizations.dart';
import 'src/pages/welcome_page.dart';
import 'src/pages/discover_page.dart';
import 'src/pages/admin_login_page.dart';
import 'src/pages/settings_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProv, localeProv, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Traditio',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProv.mode,
            locale: localeProv.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/',
            routes: {
              '/': (_) => const WelcomePage(),
              '/discover': (_) => const DiscoverPage(),
              '/admin': (_) => const AdminLoginPage(),
              '/settings': (_) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
