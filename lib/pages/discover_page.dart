import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
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
            final recommended = prov.recommended.take(5).toList();
            final filtered = prov.filteredPlaces;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: loc.translate('search_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: prov.setSearchQuery,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(loc.translate('type_hotel')),
                        selected: prov.isTypeSelected('hotel'),
                        onSelected: (_) => prov.toggleType('hotel'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(loc.translate('type_restaurant')),
                        selected: prov.isTypeSelected('restaurant'),
                        onSelected: (_) => prov.toggleType('restaurant'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(loc.translate('type_attraction')),
                        selected: prov.isTypeSelected('attraction'),
                        onSelected: (_) => prov.toggleType('attraction'),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: prov.currentLocation,
                        items: prov.availableLocations
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) => prov.setLocation(v ?? 'All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate('recommended'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.85),
                    itemCount: recommended.length,
                    itemBuilder: (ctx, i) {
                      final p = recommended[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailPage(place: p),
                            ),
                          ),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.overlayGradient,
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 6,
                                                color: Colors.black45,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${p.location} • ${p.type}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
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
                Text(
                  loc.translate('all_places'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text(loc.translate('no_results')))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => PlaceCard(
                            place: filtered[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlaceDetailPage(place: filtered[i]),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.tune),
        onPressed: () => Navigator.of(context).pushNamed('/settings'),
      ),
    );
  }
}
