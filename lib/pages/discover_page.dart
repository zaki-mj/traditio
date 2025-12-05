import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/places_provider.dart';
import '../models/place.dart';
import '../widgets/cards/place_card.dart';
import '../services/firebase_services.dart';
import '../theme/app_colors.dart';
import 'place_detail_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<PlacesProvider>(
          builder: (context, prov, _) {
            // Prefer a filtered Firestore stream for recommended items (less data over the wire)
            // Fall back to provider.recommended if no stream snapshot available.

            // We'll build the recommended section with a StreamBuilder below.
            final filtered = prov.filteredPlaces;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: loc.translate('search_hint'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: prov.setSearchQuery,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(label: Text(loc.translate('type_hotel')), selected: prov.isTypeSelected('hotel'), onSelected: (_) => prov.toggleType('hotel')),
                      const SizedBox(width: 8),
                      FilterChip(label: Text(loc.translate('type_restaurant')), selected: prov.isTypeSelected('restaurant'), onSelected: (_) => prov.toggleType('restaurant')),
                      const SizedBox(width: 8),
                      FilterChip(label: Text(loc.translate('type_attraction')), selected: prov.isTypeSelected('attraction'), onSelected: (_) => prov.toggleType('attraction')),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: prov.currentLocation,
                        items: prov.availableLocations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (v) => prov.setLocation(v ?? 'All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.translate('recommended'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: StreamBuilder<List<PointOfInterest>>(
                    stream: FirebaseServices().streamRecommendedPOIs(),
                    builder: (ctx, snap) {
                      final full = snap.hasData ? snap.data! : prov.recommended;
                      final recommended = full.isEmpty ? <PointOfInterest>[] : (full.length > 5 ? full.sublist(0, 5) : full);

                      if (recommended.isEmpty) {
                        return Center(child: Text(loc.translate('no_places_found')));
                      }

                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        itemCount: recommended.length,
                        itemBuilder: (ctx, i) {
                          final p = recommended[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: p))),
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    p.imageUrl != null && p.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surface),
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
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              Localizations.localeOf(context).languageCode == 'ar' ? p.nameAR : p.nameFR,
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            Text('${Localizations.localeOf(context).languageCode == 'ar' ? p.cityNameAR : p.cityNameFR} • ${loc.translate('type_${p.category.name}')}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.translate('all_places'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text(loc.translate('no_results')))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => PlaceCard(
                            place: filtered[i],
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: filtered[i]))),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.tune), onPressed: () => Navigator.of(context).pushNamed('/settings')),
    );
  }

  IconData _categoryIcon(POICategory category) {
    switch (category) {
      case POICategory.hotel:
        return Icons.hotel;
      case POICategory.restaurant:
        return Icons.restaurant;
      case POICategory.attraction:
        return Icons.attractions;
      case POICategory.store:
        return Icons.store;
      case POICategory.other:
        return Icons.more_horiz;
    }
  }

  Color _categoryColor(POICategory category) {
    switch (category) {
      case POICategory.hotel:
        return Colors.blue;
      case POICategory.restaurant:
        return Colors.orange;
      case POICategory.attraction:
        return Colors.green;
      case POICategory.store:
        return Colors.purple;
      case POICategory.other:
        return Colors.grey;
    }
  }
}
