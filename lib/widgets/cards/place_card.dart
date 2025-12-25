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
    final loc = AppLocalizations(Localizations.localeOf(context));
    final langCode = Localizations.localeOf(context).languageCode;

    // Use the first image for the hero transition, or a unique placeholder tag if no image exists.
    final heroTag = enableHero ? 'place_image_${place.id}_0' : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
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
                    CategoryImage(
                      imageUrl: place.imageUrls.isNotEmpty ? place.imageUrls.first : null,
                      category: place.category,
                      enableHero: enableHero,
                      heroTag: heroTag, // Use the generated tag
                      fit: BoxFit.cover,
                    ),
                    Container(decoration: const BoxDecoration(gradient: AppColors.overlayGradient)),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      right: 12, // Added for text safety
                      child: Text(
                        '${langCode == 'ar' ? place.wilayaNameAR : place.wilayaNameFR} • ${loc.translate('type_${place.category.name}')}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, shadows: [const Shadow(blurRadius: 4)]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Consumer<FavoritesProvider>(
                        builder: (ctx, favs, _) {
                          final id = place.id;
                          final isFav = id != null && favs.isFavorite(id);
                          return Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: id == null ? null : () => favs.toggle(id),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, key: ValueKey<bool>(isFav), color: isFav ? theme.colorScheme.error : Colors.white),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(langCode == 'ar' ? place.nameAR : place.nameFR, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Expanded(child: Text(place.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            avatar: Icon(Icons.star, color: theme.colorScheme.onSecondaryContainer, size: 16),
                            label: Text(place.rating.toString()),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
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
