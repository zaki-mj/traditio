import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/artist.dart';
import '../../l10n/app_localizations.dart';
import '../category_image.dart'; // You can keep it for placeholder
import '../../providers/favorites_provider.dart';
import '../../theme/app_colors.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final bool enableHero;

  const ArtistCard({super.key, required this.artist, this.onTap, this.enableHero = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    // Safe name display (handles empty nameAR/nameFR as in your test data)
    final displayName = languageCode == 'ar' ? (artist.nameAR.isNotEmpty ? artist.nameAR : artist.nameFR) : (artist.nameFR.isNotEmpty ? artist.nameFR : artist.nameAR);

    // Get first image from imageUrls or fallback to imageUrl
    final imageUrl = artist.imageUrls?.isNotEmpty == true ? artist.imageUrls![0] : artist.imageUrl;

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
              // Image Section
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Use CategoryImage as fallback/placeholder or replace with simple Image.network if you prefer
                    Builder(
                      builder: (context) {
                        final imageUrl = artist.imageUrls?.isNotEmpty == true ? artist.imageUrls![0] : artist.imageUrl;

                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPersonPlaceholder(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildLoadingPlaceholder();
                            },
                          );
                        }
                        return _buildPersonPlaceholder();
                      },
                    ),

                    // Overlay gradient
                    Container(decoration: const BoxDecoration(gradient: AppColors.overlayGradient)),

                    // Location at bottom left
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Text(languageCode == 'ar' ? artist.wilayaNameAR : artist.wilayaNameFR, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    ),

                    // Favorite button (top right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<FavoritesProvider>(
                        builder: (ctx, favs, _) {
                          final id = artist.id;
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

              // Text Content Section
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artist Name
                      Text(displayName, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),

                      // Description (truncated)
                      Expanded(
                        child: Text(artist.description ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                      ),

                      const SizedBox(height: 8),

                      // Bottom row: No rating for artists → replaced with simple indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // You can replace this Chip with something else if you want
                          // e.g. "Artiste" label, recommended badge, etc.
                          if (artist.recommended) Chip(label: Text(AppLocalizations(Localizations.localeOf(context)).translate('recommended')), backgroundColor: Colors.amber.withAlpha(80), labelStyle: const TextStyle(fontSize: 12)) else const SizedBox.shrink(),

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

Widget _buildPersonPlaceholder() {
  return Container(
    color: Colors.grey.shade100,
    child: const Icon(Icons.person, size: 90, color: Colors.grey),
  );
}

Widget _buildLoadingPlaceholder() {
  return Container(
    color: Colors.grey.shade200,
    child: const Center(child: CircularProgressIndicator()),
  );
}
