import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/buttons/app_filled_button.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) =>
                context.read<LocaleProvider>().setLocale(locale),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              loc.translate('welcome'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              'Discover traditional touristic places: hotels, restaurants and more.',
            ),
            const Spacer(),
            AppFilledButton(
              label: loc.translate('start_discovering'),
              onPressed: () => Navigator.of(context).pushNamed('/discover'),
            ),
            const SizedBox(height: 12),
            AppFilledButton(
              label: loc.translate('admin_login'),
              onPressed: () => Navigator.of(context).pushNamed('/admin'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
