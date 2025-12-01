import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('about')), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Icon and Title
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.location_city),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('app_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('slogan'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // About Description
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('about_title'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(loc.translate('about_description'), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Technical Details
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('technical_details'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    title: Text(loc.translate('app_version')),
                    subtitle: Text("0.1"),
                  ),
                  ListTile(
                    leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                    title: Text(loc.translate('developed_with')),
                    subtitle: const Text('Flutter & Dart'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Credits
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('credits'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                    title: Text(loc.translate('idea_by')),
                    subtitle: Text(loc.translate('medjdoub_hadjirat')),
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                    title: Text(loc.translate('developed_by')),
                    subtitle: Text(loc.translate('medjdoub_zakaria')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
