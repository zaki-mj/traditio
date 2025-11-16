import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/places_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();
    final placesProv = context.read<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(loc.translate('change_theme')),
              trailing: Switch(
                value: themeProv.isDark,
                onChanged: (v) => themeProv.setDark(v),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(loc.translate('change_language')),
              trailing: DropdownButton<Locale>(
                value: localeProv.locale,
                items: AppLocalizations.supportedLocales
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.languageCode),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) localeProv.setLocale(v);
                },
              ),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                // reset filters
                placesProv.setLocation('All');
                // remove all types
                for (var t in ['hotel', 'restaurant', 'attraction']) {
                  if (placesProv.isTypeSelected(t)) placesProv.toggleType(t);
                }
                placesProv.setSearchQuery('');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters cleared')),
                );
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
