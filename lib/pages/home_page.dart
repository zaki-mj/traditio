import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/models/artist.dart';
import 'package:traditional_gems/models/place.dart';
import 'package:traditional_gems/pages/artist_details_page.dart';
import 'package:traditional_gems/pages/discover_shell.dart';
import 'package:traditional_gems/pages/place_detail_page.dart';
import 'package:traditional_gems/providers/artists_provider.dart';
import 'package:traditional_gems/providers/places_provider.dart';
import 'package:traditional_gems/services/firebase_services.dart';
import 'package:traditional_gems/theme/app_colors.dart';
import '../widgets/home_page_card.dart';

class DiscoverTraditionalPlacesScreen extends StatefulWidget {
  const DiscoverTraditionalPlacesScreen({super.key});

  @override
  State<DiscoverTraditionalPlacesScreen> createState() => _DiscoverTraditionalPlacesScreenState();
}

class _DiscoverTraditionalPlacesScreenState extends State<DiscoverTraditionalPlacesScreen> {
  void _navigateToPlaces() {
    // Find the DiscoverShell and change its index to 1 (Places tab)
    final shellState = context.findAncestorStateOfType<DiscoverShellState>();
    if (shellState != null) {
      shellState.index = 1;
      shellState.updateUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poi_prov = context.read<PlacesProvider>();
    final artist_prov = context.read<ArtistsProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _navigateToPlaces,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(20), child: Image.asset("assets/pictures/discover_banner.jpg")),
            ),
          ),

          const SizedBox(height: 32),
          // 1. Featured Places section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.translate('featured_places'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _navigateToPlaces,
                      child: Text(
                        loc.translate('see_all'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240, // Card height + some padding
                  child: StreamBuilder<List<PointOfInterest>>(
                    stream: FirebaseServices().streamRecommendedPOIs(),
                    builder: (ctx, snap) {
                      final full = snap.hasData ? snap.data! : poi_prov.recommended;
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
                                    p.imageUrls != null && p.imageUrls!.isNotEmpty
                                        ? Image.network(
                                            p.imageUrls![0],
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
                                            Text('${Localizations.localeOf(context).languageCode == 'ar' ? p.wilayaNameAR : p.wilayaNameFR} • ${loc.translate('type_${p.category.name}')}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 1. Featured Places section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.translate('featured_artists'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _navigateToPlaces,
                      child: Text(
                        loc.translate('see_all'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240, // Card height + some padding
                  child: StreamBuilder<List<Artist>>(
                    stream: FirebaseServices().streamRecommendedArtists(),
                    builder: (ctx, snap) {
                      final full = snap.hasData ? snap.data! : artist_prov.recommended;
                      final recommended = full.isEmpty ? <Artist>[] : (full.length > 5 ? full.sublist(0, 5) : full);

                      if (recommended.isEmpty) {
                        return Center(child: Text(loc.translate('no_artists_found')));
                      }

                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        itemCount: recommended.length,
                        itemBuilder: (ctx, i) {
                          final a = recommended[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArtistDetailPage(artist: a))),
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    a.imageUrls != null && a.imageUrls!.isNotEmpty
                                        ? Image.network(
                                            a.imageUrls![0],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surface),
                                          )
                                        : Container(
                                            color: _categoryColor(a).withAlpha(30),
                                            alignment: Alignment.center,
                                            child: Icon(_categoryIcon(a), size: 48, color: _categoryColor(a)),
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
                                              Localizations.localeOf(context).languageCode == 'ar' ? a.nameAR : a.nameFR,
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            Text(Localizations.localeOf(context).languageCode == 'ar' ? a.wilayaNameAR : a.wilayaNameFR, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Featured Trips section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.translate('featured_trips'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _navigateToPlaces,
                      child: Text(
                        loc.translate('see_all'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: HomePageCard.buildCard(
                          title: loc.translate('trip_demo_title_$index'),
                          subtitle: loc.translate('trip_demo_subtitle'),
                          imageUrl: 'https://images.unsplash.com/photo-1585208798174-6cedd78e0198?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80', // Placeholder
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40), // Bottom spacing
        ],
      ),
    );
  }

  IconData _categoryIcon(var category) {
    switch (category) {
      case POICategory.hotel:
        return Icons.hotel;
      case POICategory.restaurant:
        return Icons.restaurant;
      case POICategory.attraction:
        return Icons.attractions;
      case POICategory.guesthouse:
        return Icons.store;
      case POICategory.other:
        return Icons.more_horiz;
      case Artist _:
        return Icons.person;
    }
    return Icons.help_outline_sharp;
  }

  Color _categoryColor(var category) {
    switch (category) {
      case POICategory.hotel:
        return Colors.blue;
      case POICategory.restaurant:
        return Colors.orange;
      case POICategory.attraction:
        return Colors.green;
      case POICategory.guesthouse:
        return Colors.purple;
      case POICategory.other:
        return Colors.grey;
      case Artist _:
        return Colors.amberAccent;
    }
    return Colors.redAccent;
  }
}
