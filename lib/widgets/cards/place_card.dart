import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../l10n/app_localizations.dart';
import '../category_image.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_colors.dart';

class PlaceCard extends StatelessWidget {
  final PointOfInterest place;
  final VoidCallback? onTap;
  final bool enableHero;

  const PlaceCard({super.key, required this.place, this.onTap, this.enableHero = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 8,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CategoryImage(imageUrl: place.imageUrl, category: place.category, enableHero: enableHero, heroTag: enableHero ? 'place_image_${place.id}' : null, fit: BoxFit.cover),
                    Container(decoration: const BoxDecoration(gradient: AppColors.overlayGradient)),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${Localizations.localeOf(context).languageCode == 'ar' ? place.cityNameAR : place.cityNameFR} • ${AppLocalizations(Localizations.localeOf(context)).translate('type_${place.category.name}')}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<FavoritesProvider>(
                        builder: (ctx, favs, _) {
                          final id = place.id;
                          final isFav = id != null && favs.isFavorite(id);
                          return Material(
                            color: Colors.black26,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: id == null ? null : () => favs.toggle(id),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, key: ValueKey<bool>(isFav), color: isFav ? theme.colorScheme.secondary : Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Localizations.localeOf(context).languageCode == 'ar' ? place.nameAR : place.nameFR, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),

                      Expanded(child: Text(place.description ?? '', maxLines: 3, overflow: TextOverflow.ellipsis)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(place.rating.toString()), backgroundColor: theme.colorScheme.onPrimaryFixedVariant),
                          Icon(Icons.chevron_right, color: theme.hintColor),
                        ],
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
  }
}
