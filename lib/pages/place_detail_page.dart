import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../providers/favorites_provider.dart';
import '../widgets/category_image.dart';

class PlaceDetailPage extends StatefulWidget {
  final PointOfInterest place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  int _currentImageIndex = 0;

  Future<void> _launchURL(BuildContext context, String? url, {String? fallbackMessage}) async {
    final loc = AppLocalizations(Localizations.localeOf(context));
    if (url == null || url.trim().isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallbackMessage ?? loc.translate('link_not_available'))));
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('invalid_link'))));
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('could_not_open_link'))));
      }
    } catch (e) {
      if (!context.mounted) return;
      final msg = loc.translate('failed_to_launch').replaceAll('{error}', e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildImageCarousel(ThemeData theme) {
    final heroTag = 'place_image_${widget.place.id}_0';

    if (widget.place.imageUrls.isEmpty) {
      return CategoryImage(
        category: widget.place.category,
        height: 250,
        fit: BoxFit.cover,
        enableHero: true,
        heroTag: heroTag,
        imageUrl: null,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: widget.place.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageWidget = Image.network(
                widget.place.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => CategoryImage(category: widget.place.category, height: 250, fit: BoxFit.cover, imageUrl: null),
              );

              // Only the first image participates in the Hero animation
              if (index == 0) {
                return Hero(tag: heroTag, child: imageWidget);
              }
              return imageWidget;
            },
          ),
        ),
        if (widget.place.imageUrls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.place.imageUrls.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? theme.colorScheme.primary : Colors.white70,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final place = widget.place;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(langCode == 'ar' ? place.nameAR : place.nameFR),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, favs, _) {
              final id = place.id;
              final isFav = id != null && favs.isFavorite(id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? theme.colorScheme.error : null),
                onPressed: id == null ? null : () => favs.toggle(id),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
        ),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              child: _buildImageCarousel(theme),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langCode == 'ar' ? place.nameAR : place.nameFR,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(langCode == 'ar' ? ('${place.cityNameAR}, ${place.wilayaNameAR}') : ('${place.cityNameFR}, ${place.wilayaNameFR}'), style: theme.textTheme.bodyLarge),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.category, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(loc.translate('type_${place.category.name}'), style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.star, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text('${place.rating}', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  if (place.description?.isNotEmpty ?? false)
                    Card(
                      color: theme.colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('about'),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(place.description!, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Contact Card
                  if (place.phone.isNotEmpty || place.email.isNotEmpty)
                    Card(
                      color: theme.colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('contact'),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                            if (place.phone.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _launchURL(context, 'tel:${place.phone}'),
                                    child: Text(
                                      place.phone,
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (place.email.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.email, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _launchURL(context, 'mailto:${place.email}'),
                                    child: Text(
                                      place.email,
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Address Card
                  if (place.locationLink?.isNotEmpty ?? false)
                    Card(
                      color: theme.colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('address'),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.map),
                                label: Text(loc.translate('open_map')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _launchURL(context, place.locationLink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Social links card
                  Card(
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('social'),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _SocialIconButton(
                                assetPath: 'assets/pictures/facebook.png',
                                tooltip: 'Facebook',
                                enabled: place.facebookLink?.isNotEmpty ?? false,
                                onTap: () => _launchURL(context, place.facebookLink),
                              ),
                              _SocialIconButton(
                                assetPath: 'assets/pictures/instagram.png',
                                tooltip: 'Instagram',
                                enabled: place.instagramLink?.isNotEmpty ?? false,
                                onTap: () => _launchURL(context, place.instagramLink),
                              ),
                              _SocialIconButton(
                                assetPath: 'assets/pictures/tiktok.png',
                                tooltip: 'TikTok',
                                enabled: place.tiktokLink?.isNotEmpty ?? false,
                                onTap: () => _launchURL(context, place.tiktokLink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _SocialIconButton extends StatelessWidget {
  final String assetPath;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _SocialIconButton({required this.assetPath, required this.tooltip, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    return InkWell(
      onTap: enabled ? onTap : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('link_not_available')))),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, width: 48, height: 48, color: enabled ? null : Colors.grey.withAlpha(120), colorBlendMode: BlendMode.srcATop),
          const SizedBox(height: 6),
          Text(tooltip, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: enabled ? null : Colors.grey)),
        ],
      ),
    );
  }
}
