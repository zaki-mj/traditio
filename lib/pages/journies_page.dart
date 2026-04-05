import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/models/place.dart';
import 'package:traditional_gems/pages/place_detail_page.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/journey_provider.dart';
import '../../models/journey.dart';

class JourneysPage extends StatelessWidget {
  const JourneysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final journeyProv = context.watch<JourneyProvider>();
    final locale = Localizations.localeOf(context).languageCode;

    final journeys = journeyProv.filteredJourneys;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('journeys')), centerTitle: true),
      body: journeys.isEmpty
          ? _EmptyJourneysState(loc: loc)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: journeys.length,
              itemBuilder: (context, index) {
                return JourneyCard(journey: journeys[index]);
              },
            ),
    );
  }
}

// ====================== JOURNEY CARD ======================
class JourneyCard extends StatelessWidget {
  final Journey journey;

  const JourneyCard({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context).languageCode;

    final displayName = locale == 'ar' ? journey.nameAR : journey.nameFR;
    final description = locale == 'ar' ? journey.descriptionAR : (locale == 'fr' ? journey.descriptionFR : journey.descriptionEN);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journey Name
            Text(displayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),

            // Description (if exists)
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Places Horizontal List
            Text(
              "${journey.pois.length} ${loc.translate('places')}",
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: journey.pois.length,
                itemBuilder: (context, index) {
                  final place = journey.pois[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _PlaceMiniCard(
                      place: place,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== MINI PLACE CARD ======================
class _PlaceMiniCard extends StatelessWidget {
  final PointOfInterest place;
  final VoidCallback onTap;

  const _PlaceMiniCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context).languageCode;

    final title = locale == 'ar' ? place.nameAR : place.nameFR;
    final city = locale == 'ar' ? (place.cityNameAR ?? place.wilayaNameAR) : (place.cityNameFR ?? place.wilayaNameFR);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Image or Placeholder
            Expanded(
              child: Container(
                width: 180,
                decoration: BoxDecoration(color: _getCategoryColor(place.category).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 22),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getCategoryColor(POICategory category) {
  switch (category) {
    case POICategory.hotel:
      return Colors.blue;
    case POICategory.restaurant:
      return Colors.orange;
    case POICategory.attraction:
      return Colors.green;
    case POICategory.guesthouse:
      return Colors.purple;
    default:
      return Colors.grey;
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
    default:
      return Icons.category;
  }
}

// Empty State
class _EmptyJourneysState extends StatelessWidget {
  final AppLocalizations loc;

  const _EmptyJourneysState({required this.loc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route_rounded, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.15)),
          const SizedBox(height: 16),

          Text(
            loc.translate('journeys_coming_soon'),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
