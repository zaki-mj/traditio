import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
import '../l10n/app_localizations.dart';
import 'place_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openSearchFilters(BuildContext context) {
    final prov = context.read<PlacesProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
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

                  // Search field
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: loc.translate('search_by_name'),
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

                  // Location section
                  Text(loc.translate('select_location'), style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: prov.currentLocation != 'All' ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(50), width: prov.currentLocation != 'All' ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
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
                  const SizedBox(height: 24),

                  // Active filters badge
                  const SizedBox(height: 24),

                  // Action buttons
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
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.search),
                          label: Text(loc.translate('search')),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: theme.colorScheme.primary,
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
        );
      },
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
            final rec = prov.recommended.take(6).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('recommended'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rec.length,
                    itemBuilder: (ctx, i) {
                      final p = rec[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: SizedBox(
                          width: 320,
                          child: PlaceCard(
                            place: p,
                            enableHero: false,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: p))),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prov.hasActiveFilters ? loc.translate('search_results') : loc.translate('all_places'), style: Theme.of(context).textTheme.titleMedium),
                    if (prov.hasActiveFilters) TextButton.icon(onPressed: () => prov.clearFilters(), icon: const Icon(Icons.close, size: 18), label: Text(loc.translate('clear_filters'))),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: prov.filteredPlaces.length,
                    itemBuilder: (ctx, i) => PlaceCard(
                      place: prov.filteredPlaces[i],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: prov.filteredPlaces[i]))),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.search), onPressed: () => _openSearchFilters(context)),
    );
  }
}
