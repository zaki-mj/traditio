import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/cards/place_card.dart';
import 'place_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
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
      appBar: AppBar(title: Text(loc.translate('favorites'))),
      //backgroundColor: Colors.transparent,
      body: favPlaces.isEmpty
          ? Center(child: Text(AppLocalizations(Localizations.localeOf(context)).translate('no_favorites_yet')))
          : ListView.builder(
              itemCount: favPlaces.length,
              itemBuilder: (ctx, i) => PlaceCard(
                place: favPlaces[i],
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceDetailPage(place: favPlaces[i]))),
              ),
            ),
    );
  }
}
