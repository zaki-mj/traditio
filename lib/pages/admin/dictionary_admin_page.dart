import 'package:flutter/material.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/widgets/admin_search_bar.dart';

class DictionaryAdminPage extends StatefulWidget {
  const DictionaryAdminPage({super.key});

  @override
  State<DictionaryAdminPage> createState() => _DictionaryAdminPageState();
}

class _DictionaryAdminPageState extends State<DictionaryAdminPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('dictionary')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(loc.translate('add_dictionary_entry')),
              onPressed: () {
                // TODO: navigate to DictionaryEntryFormPage
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
              hintText: loc.translate('search_dictionary'),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 52, color: theme.colorScheme.onSurface.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('dictionary_coming_soon'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.35)),
                  ),
                  const SizedBox(height: 6),
                  Text(loc.translate('dictionary_wire_placeholder'), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.25))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
