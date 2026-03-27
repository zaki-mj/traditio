import 'package:flutter/material.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/widgets/admin_search_bar.dart';


class JourneysAdminPage extends StatefulWidget {
  const JourneysAdminPage({super.key});

  @override
  State<JourneysAdminPage> createState() => _JourneysAdminPageState();
}

class _JourneysAdminPageState extends State<JourneysAdminPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('journeys')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add journey'),   // TODO: localize
              onPressed: () {
                // TODO: navigate to JourneyFormPage
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminSearchBar(
              hintText: 'Search journeys...',   // TODO: localize
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.route_rounded, size: 52, color: theme.colorScheme.onSurface.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text(
                    'Journeys list — coming soon',   // TODO: localize
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wire up JourneyProvider here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.25),
                    ),
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