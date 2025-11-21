import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/places_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/admin_provider.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'pages/welcome_page.dart';
import 'pages/discover_shell.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_shell.dart';
import 'pages/settings_page.dart';

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
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProv, localeProv, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppLocalizations(localeProv.locale).translate('app_title'),
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
              '/discover': (_) => const DiscoverShell(),
              '/admin': (_) => const AdminLoginPage(),
              '/admin-dashboard': (_) => const AdminShell(),
              '/settings': (_) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
