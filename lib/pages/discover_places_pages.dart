import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/models/place.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
import 'place_detail_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void _openFilters(BuildContext context) {
    final prov = context.read<PlacesProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    // read provider in bottom sheet when needed

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
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

                  // Search Field
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
                    onChanged: (value) {
                      prov.setSearchQuery(value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 28),

                  // ==================== CATEGORY FILTER ====================
                  Text(loc.translate('category'), style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: POICategory.values.map((category) {
                      final typeName = category.name; // "hotel", "restaurant", etc.
                      final isSelected = prov.isTypeSelected(typeName);

                      return GestureDetector(
                        onTap: () {
                          prov.toggleType(typeName);
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withAlpha(60), width: isSelected ? 2 : 1),
                            boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withAlpha(70), blurRadius: 6, offset: const Offset(0, 2))] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(category), size: 20, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                loc.translate('type_${category.name}'),
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Location Filter (unchanged)
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
                  const SizedBox(height: 32),

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
                            icon: const Icon(Icons.clear_all),
                            label: Text(loc.translate('clear_filters')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      if (prov.hasActiveFilters) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.search),
                          label: Text(loc.translate('apply_filters')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<PlacesProvider>(
          builder: (context, prov, _) {
            final filtered = prov.filteredPlaces;
            return filtered.isEmpty
                ? Center(child: Text(loc.translate('no_places_found')))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => PlaceCard(
                      place: filtered[i],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: filtered[i]))),
                    ),
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.search), onPressed: () => _openFilters(context)),
    );
  }
}

IconData _getCategoryIcon(POICategory category) {
  switch (category) {
    case POICategory.hotel:
      return Icons.hotel;
    case POICategory.restaurant:
      return Icons.restaurant;
    case POICategory.attraction:
      return Icons.place;
    case POICategory.guesthouse:
      return Icons.home;
    case POICategory.other:
      return Icons.category_outlined;
  }
}
