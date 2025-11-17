import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
import 'place_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favsProv = context.watch<FavoritesProvider>();
    final placesProv = context.watch<PlacesProvider>();
    final favIds = favsProv.allFavorites;
    final favPlaces = favIds
        .map((id) {
          try {
            return placesProv.allPlaces.firstWhere((p) => p.id == id);
          } catch (_) {
            return null;
          }
        })
        .where((p) => p != null)
        .cast()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favPlaces.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: favPlaces.length,
              itemBuilder: (ctx, i) => PlaceCard(
                place: favPlaces[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailPage(place: favPlaces[i]),
                  ),
                ),
              ),
            ),
    );
  }
}
