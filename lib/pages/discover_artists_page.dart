import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/pages/artist_details_page.dart';
import '../l10n/app_localizations.dart';
import '../providers/artists_provider.dart';
import '../models/artist.dart';
import '../widgets/cards/artist_card.dart'; // ← You'll need to create this
import '../theme/app_colors.dart';
// ← Adjust name if different

class DiscoverArtistsPage extends StatelessWidget {
  const DiscoverArtistsPage({super.key});

  void _openSearchFilters(BuildContext context) {
    final prov = context.read<ArtistsProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65, // Slightly smaller since no type filter
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: theme.colorScheme.onSurface.withAlpha(100), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    loc.translate('search_filter'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),

                  // Search TextField
                  TextField(
                    decoration: InputDecoration(
                      hintText: loc.translate('search_by_name'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: prov.searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                prov.setSearchQuery('');
                                setModalState(() {});
                              },
                              child: Icon(Icons.close, color: theme.colorScheme.primary),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) {
                      prov.setSearchQuery(v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 24),

                  // Location Filter
                  Text(loc.translate('select_location'), style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: prov.currentLocation != 'All' ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(50), width: prov.currentLocation != 'All' ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      value: prov.currentLocation,
                      items: prov.availableLocations
                          .map(
                            (l) => DropdownMenuItem(
                              value: l,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(l == 'All' ? loc.translate('all_locations') : prov.getWilayaName(l, Localizations.localeOf(context).languageCode), style: theme.textTheme.bodyMedium),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          prov.setLocation(v);
                          setModalState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      if (prov.hasActiveFilters)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              prov.clearFilters();
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.clear),
                            label: Text(loc.translate('clear_filters')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      if (prov.hasActiveFilters) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.search),
                          label: Text(loc.translate('search')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<ArtistsProvider>(
        builder: (context, prov, _) {
          final filtered = prov.filteredArtists;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended Section
                Text(loc.translate('recommended'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: prov.recommended.isEmpty
                      ? Center(child: Text(loc.translate('no_artists_found')))
                      : PageView.builder(
                          controller: PageController(viewportFraction: 0.85),
                          itemCount: prov.recommended.length > 5 ? 5 : prov.recommended.length,
                          itemBuilder: (ctx, i) {
                            final artist = prov.recommended[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArtistDetailPage(artist: artist))),
                                child: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Image
                                      artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              artist.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surface),
                                            )
                                          : artist.imageUrls != null && artist.imageUrls!.isNotEmpty
                                          ? Image.network(
                                              artist.imageUrls!.first,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surface),
                                            )
                                          : Container(color: theme.colorScheme.primary.withAlpha(30), alignment: Alignment.center, child: const Icon(Icons.person, size: 48)),

                                      Container(decoration: const BoxDecoration(gradient: AppColors.overlayGradient)),

                                      Positioned(
                                        left: 12,
                                        bottom: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                Localizations.localeOf(context).languageCode == 'ar' ? (artist.nameAR.isNotEmpty ? artist.nameAR : artist.nameFR) : (artist.nameFR.isNotEmpty ? artist.nameFR : artist.nameAR),
                                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(Localizations.localeOf(context).languageCode == 'ar' ? artist.wilayaNameAR : artist.wilayaNameFR, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // Results Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prov.hasActiveFilters ? loc.translate('search_results') : loc.translate('all_artists'), // Make sure this key exists in your localization
                      style: theme.textTheme.titleMedium,
                    ),
                    if (prov.hasActiveFilters) TextButton.icon(onPressed: () => prov.clearFilters(), icon: const Icon(Icons.close, size: 18), label: Text(loc.translate('clear_filters'))),
                  ],
                ),
                const SizedBox(height: 8),

                // Results List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(loc.translate('no_artists_found'), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => ArtistCard(
                            artist: filtered[i],
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArtistDetailPage(artist: filtered[i]))),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.search), onPressed: () => _openSearchFilters(context)),
    );
  }
}
