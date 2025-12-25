import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/places_provider.dart';
import '../models/place.dart';
import '../widgets/cards/place_card.dart';
import '../theme/app_colors.dart';
import 'place_detail_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  void _openSearchFilters(BuildContext context) {
    final prov = context.read<PlacesProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
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
                    loc.translate('search_filter'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),

                  // Search TextField
                  TextField(
                    controller: TextEditingController(text: prov.searchQuery),
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
                    ),
                    onChanged: (v) {
                      prov.setSearchQuery(v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 24),

                  // Location Filter
                  Text(loc.translate('select_location'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: prov.currentLocation,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: prov.availableLocations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l,
                            child: Text(l == 'All' ? loc.translate('all_locations') : prov.getWilayaName(l, Localizations.localeOf(context).languageCode)),
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
                  const SizedBox(height: 24),

                  // Type Filter
                  Text(loc.translate('select_type'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['hotel', 'restaurant', 'attraction', 'store', 'other'].map((type) {
                      final isSelected = prov.isTypeSelected(type);
                      return ChoiceChip(
                        label: Text(loc.translate('type_$type')),
                        selected: isSelected,
                        onSelected: (_) {
                          prov.toggleType(type);
                          setModalState(() {});
                        },
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
                      );
                    }).toList(),
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
                          ),
                        ),
                      if (prov.hasActiveFilters) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.search),
                          label: Text(loc.translate('search')),
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
      body: Consumer<PlacesProvider>(
        builder: (context, prov, _) {
          final filtered = prov.filteredPlaces;
          final recommended = prov.recommended;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended Carousel
                Text(loc.translate('recommended'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: recommended.isEmpty
                      ? Center(child: Text(loc.translate('no_recommended_places')))
                      : PageView.builder(
                          controller: PageController(viewportFraction: 0.85),
                          itemCount: recommended.length > 5 ? 5 : recommended.length, // Show max 5
                          itemBuilder: (ctx, i) {
                            final p = recommended[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: p))),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      p.imageUrls.isNotEmpty
                                          ? Image.network(
                                              p.imageUrls.first,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surface),
                                            )
                                          : Container(
                                              color: _categoryColor(p.category).withAlpha(30),
                                              alignment: Alignment.center,
                                              child: Icon(_categoryIcon(p.category), size: 48, color: _categoryColor(p.category)),
                                            ),
                                      Container(decoration: const BoxDecoration(gradient: AppColors.overlayGradient)),
                                      Positioned(
                                        left: 12,
                                        bottom: 12,
                                        right: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              Localizations.localeOf(context).languageCode == 'ar' ? p.nameAR : p.nameFR,
                                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8)]),
                                            ),
                                            Text(
                                              '${Localizations.localeOf(context).languageCode == 'ar' ? p.wilayaNameAR : p.wilayaNameFR} • ${loc.translate('type_${p.category.name}')}',
                                              style: const TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(blurRadius: 6)]),
                                            ),
                                          ],
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
                const SizedBox(height: 20),

                // Results Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prov.hasActiveFilters ? loc.translate('search_results') : loc.translate('all_places'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (prov.hasActiveFilters)
                      TextButton.icon(
                        onPressed: prov.clearFilters,
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(loc.translate('clear_filters')),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Results List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(loc.translate('no_places_found_filters'), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => PlaceCard(
                            place: filtered[i],
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: filtered[i]))),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () => _openSearchFilters(context),
        tooltip: loc.translate('search_filter'),
      ),
    );
  }

  IconData _categoryIcon(POICategory category) {
    switch (category) {
      case POICategory.hotel: return Icons.hotel;
      case POICategory.restaurant: return Icons.restaurant;
      case POICategory.attraction: return Icons.attractions;
      case POICategory.store: return Icons.store;
      case POICategory.other: return Icons.more_horiz;
    }
  }

  Color _categoryColor(POICategory category) {
    switch (category) {
      case POICategory.hotel: return Colors.blue;
      case POICategory.restaurant: return Colors.orange;
      case POICategory.attraction: return Colors.green;
      case POICategory.store: return Colors.purple;
      case POICategory.other: return Colors.grey;
    }
  }
}
