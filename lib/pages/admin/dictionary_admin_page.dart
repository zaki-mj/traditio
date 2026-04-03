import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/models/dictionary_entry.dart';
import 'package:traditional_gems/providers/dictionary_provider.dart';
import 'package:traditional_gems/widgets/admin_search_bar.dart';

class DictionaryAdminPage extends StatefulWidget {
  const DictionaryAdminPage({super.key});

  @override
  State<DictionaryAdminPage> createState() => _DictionaryAdminPageState();
}

class _DictionaryAdminPageState extends State<DictionaryAdminPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Start listening to Firestore when page opens
    context.read<DictionaryProvider>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    // Filter entries based on search
    final filtered = provider.filteredEntries.where((e) => e.arabic.toLowerCase().contains(_searchQuery.toLowerCase()) || e.french.toLowerCase().contains(_searchQuery.toLowerCase()) || e.english.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('dictionary')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(icon: const Icon(Icons.add_rounded, size: 18), label: Text(loc.translate('add_dictionary_entry')), onPressed: () => _showEntryDialog(context)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminSearchBar(hintText: loc.translate('search_dictionary'), onChanged: (q) => setState(() => _searchQuery = q)),
          ),
          const SizedBox(height: 8),

          // Result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${filtered.length} ${loc.translate('results_found')}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(loc: loc)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return _DictionaryCard(
                        entry: entry,
                        onEdit: () => _showEntryDialog(context, entry: entry),
                        onDelete: () => _confirmDelete(context, entry),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Add / Edit Dialog
  // ─────────────────────────────────────────────────────────────
  void _showEntryDialog(BuildContext context, {DictionaryEntry? entry}) {
    final loc = AppLocalizations(Localizations.localeOf(context));

    final arabicCtrl = TextEditingController(text: entry?.arabic);
    final frenchCtrl = TextEditingController(text: entry?.french);
    final englishCtrl = TextEditingController(text: entry?.english);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(entry == null ? loc.translate('add_dictionary_entry') : loc.translate('edit_dictionary_entry')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: arabicCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: loc.translate('arabic'),
                  hintText: loc.translate('enter_arabic'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frenchCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('french'),
                  hintText: loc.translate('enter_french'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: englishCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('english'),
                  hintText: loc.translate('enter_english'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(loc.translate('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final arabic = arabicCtrl.text.trim();
              final french = frenchCtrl.text.trim();
              final english = englishCtrl.text.trim();

              if (arabic.isEmpty || french.isEmpty || english.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('fill_all_fields'))));
                return;
              }

              final newEntry = DictionaryEntry(id: entry?.id, arabic: arabic, french: french, english: english);

              final provider = context.read<DictionaryProvider>();

              if (entry == null) {
                await provider.addEntry(newEntry);
              } else {
                await provider.updateEntry(entry.id!, newEntry);
              }

              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(entry == null ? loc.translate('entry_added_successfully') : loc.translate('entry_updated_successfully')), backgroundColor: theme.colorScheme.primary));
              }
            },
            child: Text(entry == null ? loc.translate('add') : loc.translate('save')),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Delete Confirmation
  // ─────────────────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, DictionaryEntry entry) async {
    final loc = AppLocalizations(Localizations.localeOf(context));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(loc.translate('delete_entry')),
        content: Text(loc.translate('confirm_delete_entry')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<DictionaryProvider>().deleteEntry(entry.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('entry_deleted_successfully'))));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Dictionary Card
// ─────────────────────────────────────────────────────────────
class _DictionaryCard extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DictionaryCard({required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arabic
            Text(
              entry.arabic,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
            const Divider(height: 20),
            // French
            Row(
              children: [
                Text(
                  "FR",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.french, style: theme.textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: 8),
            // English
            Row(
              children: [
                Text(
                  "EN",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.english, style: theme.textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(icon: const Icon(Icons.edit_outlined, size: 18), label: Text(loc.translate('edit')), onPressed: onEdit),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text(loc.translate('delete'), style: TextStyle(color: Colors.red)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations loc;

  const _EmptyState({required this.loc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(loc.translate('dictionary_coming_soon'), style: theme.textTheme.titleMedium),
          Text(loc.translate('no_entries_found'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}
