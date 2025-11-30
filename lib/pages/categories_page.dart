import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../l10n/app_localizations.dart';
import 'explore_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final prov = context.watch<PlacesProvider>();

    final categories = [
      {'type': 'hotel', 'icon': Icons.hotel, 'label': loc.translate('type_hotel')},
      {'type': 'restaurant', 'icon': Icons.restaurant, 'label': loc.translate('type_restaurant')},
      {'type': 'attraction', 'icon': Icons.landscape, 'label': loc.translate('type_attraction')},
      {'type': 'store', 'icon': Icons.shopping_bag, 'label': loc.translate('type_store')},
      {'type': 'other', 'icon': Icons.more_horiz, 'label': loc.translate('type_other')},
    ];

    final counts = {
      'hotel': prov.allPlaces.where((p) => p.category.name == 'hotel').length,
      'restaurant': prov.allPlaces.where((p) => p.category.name == 'restaurant').length,
      'attraction': prov.allPlaces.where((p) => p.category.name == 'attraction').length,
      'store': prov.allPlaces.where((p) => p.category.name == 'store').length,
      'other': prov.allPlaces.where((p) => p.category.name == 'other').length,
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: categories.map((cat) {
            final type = cat['type'] as String;
            final icon = cat['icon'] as IconData;
            final label = cat['label'] as String;
            final count = counts[type] ?? 0;
            return GestureDetector(
              onTap: () {
                prov.setSearchQuery('');
                for (var t in ['hotel', 'restaurant', 'attraction', 'store', 'other']) {
                  if (prov.isTypeSelected(t) && t != type) {
                    prov.toggleType(t);
                  }
                }
                if (!prov.isTypeSelected(type)) {
                  prov.toggleType(type);
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExplorePage()));
              },
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).colorScheme.primary.withAlpha(200), Theme.of(context).colorScheme.primary.withAlpha(100)]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 56, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: Text('$count items', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
