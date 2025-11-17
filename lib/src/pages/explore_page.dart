import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
import 'place_detail_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void _openFilters(BuildContext context) {
    final prov = context.read<PlacesProvider>();
    // read provider in bottom sheet when needed
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final types = ['hotel', 'restaurant', 'attraction'];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                ),
                onChanged: (v) => prov.setSearchQuery(v),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: types.map((t) {
                  return FilterChip(
                    label: Text(t),
                    selected: prov.isTypeSelected(t),
                    onSelected: (_) => prov.toggleType(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Location:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: prov.currentLocation,
                    items: prov.availableLocations
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => prov.setLocation(v ?? 'All'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      prov.setSearchQuery('');
                      for (var t in types) {
                        if (prov.isTypeSelected(t)) {
                          prov.toggleType(t);
                        }
                      }
                    },
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<PlacesProvider>(
          builder: (context, prov, _) {
            final filtered = prov.filteredPlaces;
            return filtered.isEmpty
                ? Center(child: Text('No results'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => PlaceCard(
                      place: filtered[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailPage(place: filtered[i]),
                        ),
                      ),
                    ),
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () => _openFilters(context),
      ),
    );
  }
}
