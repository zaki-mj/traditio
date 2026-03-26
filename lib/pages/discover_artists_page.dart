import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/artists_provider.dart';
import '../models/artist.dart';

class DiscoverArtistsPage extends StatelessWidget {
  const DiscoverArtistsPage({super.key});

  void _openSearchFilters(BuildContext context) {
    final prov = context.read<ArtistsProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
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
                    'Search & Filter Artists',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),

                  // Search TextField
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name',
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
                  Text('Select Location', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                child: Text(l == 'All' ? 'All Locations' : prov.getWilayaName(l, Localizations.localeOf(context).languageCode), style: theme.textTheme.bodyMedium),
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
                            label: const Text('Clear Filters'),
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
                          label: const Text('Search'),
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
                // Results Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prov.hasActiveFilters ? 'Search Results' : 'All Artists', style: theme.textTheme.titleMedium),
                    if (prov.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () {
                          prov.clearFilters();
                        },
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Results List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text('No artists found', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        )
                      : ListView.builder(itemCount: filtered.length, itemBuilder: (ctx, i) => _buildArtistCard(context, filtered[i], theme)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.search), onPressed: () => _openSearchFilters(context)),
    );
  }

  Widget _buildArtistCard(BuildContext context, Artist artist, ThemeData theme) {
    final langCode = Localizations.localeOf(context).languageCode;
    final displayName = langCode == 'ar' ? artist.nameAR : artist.nameFR;
    final wilaya = langCode == 'ar' ? artist.wilayaNameAR : artist.wilayaNameFR;
    final city = langCode == 'ar' ? artist.cityNameAR : artist.cityNameFR;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Column(
            children: [
              // Image carousel
              if (artist.imageUrls != null && artist.imageUrls!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: artist.imageUrls!.length,
                      itemBuilder: (ctx, i) => Image.network(
                        artist.imageUrls![i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surfaceContainerHighest, alignment: Alignment.center, child: const Icon(Icons.image, size: 64)),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 64),
                ),

              // Artist Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$wilaya • $city',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (artist.description != null && artist.description!.isNotEmpty) Text(artist.description!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (artist.phone.isNotEmpty)
                          Tooltip(
                            message: artist.phone,
                            child: Icon(Icons.phone, size: 16, color: theme.colorScheme.primary),
                          ),
                        const SizedBox(width: 8),
                        if (artist.email.isNotEmpty)
                          Tooltip(
                            message: artist.email,
                            child: Icon(Icons.email, size: 16, color: theme.colorScheme.primary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
