import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/places_provider.dart';
import '../theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings_title')),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Theme Settings Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('settings'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theme Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) => SwitchListTile(
                        secondary: Icon(
                          themeProvider.isDark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          themeProvider.isDark
                              ? loc.translate('dark_mode')
                              : loc.translate('light_mode'),
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          themeProvider.isDark
                              ? 'Switch to light mode'
                              : 'Switch to dark mode',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        value: themeProvider.isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    ),

                    const Divider(),

                    // Language Picker
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, _) => ListTile(
                        leading: Icon(Icons.language, color: AppColors.primary),
                        title: Text(
                          _getLanguageName(localeProvider.locale.languageCode),
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          loc.translate('change_language'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          size: 16,
                        ),
                        onTap: () {
                          _showLanguageDialog(context, localeProvider, loc);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Clear Filters Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('clear_filters'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reset all search filters and preferences to default.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final placesProv = context.read<PlacesProvider>();
                          // Reset filters
                          placesProv.setLocation('All');
                          // Remove all types
                          for (var t in ['hotel', 'restaurant', 'attraction']) {
                            if (placesProv.isTypeSelected(t)) {
                              placesProv.toggleType(t);
                            }
                          }
                          placesProv.setSearchQuery('');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Filters cleared successfully',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.green.shade600,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.clear_all),
                        label: Text(loc.translate('clear_filters')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Info Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Traditio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.info, color: AppColors.primary),
                      title: const Text('Version'),
                      subtitle: const Text('1.0.0'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: Icon(Icons.business, color: AppColors.primary),
                      title: const Text('Developer'),
                      subtitle: const Text('Traditio Team'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: Icon(Icons.copyright, color: AppColors.primary),
                      title: const Text('Copyright'),
                      subtitle: const Text('© 2025 All Rights Reserved'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
    AppLocalizations loc,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.translate('change_language')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.language, color: AppColors.primary),
                  title: const Text('العربية'),
                  onTap: () {
                    localeProvider.setLocale(const Locale('ar'));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.language, color: AppColors.primary),
                  title: const Text('Français'),
                  onTap: () {
                    localeProvider.setLocale(const Locale('fr'));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.language, color: AppColors.primary),
                  title: const Text('English'),
                  onTap: () {
                    localeProvider.setLocale(const Locale('en'));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return code;
    }
  }
}
