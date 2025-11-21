import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_colors.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  final bool enableHero;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.enableHero = true,
  });

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
                    if (enableHero)
                      Hero(
                        tag: 'place_image_${place.id}',
                        child: Image.network(
                          place.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        ),
                      )
                    else
                      Image.network(
                        place.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300]),
                      ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.overlayGradient,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${place.location} • ${place.type}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<FavoritesProvider>(
                        builder: (ctx, favs, _) {
                          final isFav = favs.isFavorite(place.id);
                          return Material(
                            color: Colors.black26,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => favs.toggle(place.id),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: ValueKey<bool>(isFav),
                                    color: isFav
                                        ? theme.colorScheme.secondary
                                        : Colors.white,
                                  ),
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
                      Text(place.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),

                      Expanded(
                        child: Text(
                          place.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(place.rating.toString()),
                            backgroundColor: theme.colorScheme.onPrimaryFixedVariant,
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
