import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // ← new
import '../models/place.dart';
import '../widgets/category_image.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailPage extends StatefulWidget {
  final PointOfInterest place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(BuildContext context, String? url, {String? fallbackMessage}) async {
    // ← your existing _launchURL code (unchanged)
    if (url == null || url.trim().isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallbackMessage ?? AppLocalizations(Localizations.localeOf(context)).translate('link_not_available'))));
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallbackMessage ?? AppLocalizations(Localizations.localeOf(context)).translate('invalid_link'))));
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations(Localizations.localeOf(context)).translate('could_not_open_link'))));
      }
    } catch (e) {
      if (!context.mounted) return;
      final msg = AppLocalizations(Localizations.localeOf(context)).translate('failed_to_launch').replaceAll('{error}', e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildImageCarousel() {
    final images = widget.place.imageUrls ?? [];
    final hasImages = images.isNotEmpty;
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    if (!hasImages) {
      // Fallback when no images
      return ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        child: CategoryImage(
          imageUrl: widget.place.imageUrl, // old single image fallback
          category: widget.place.category,
          height: 260,
          fit: BoxFit.cover,
          enableHero: true,
          heroTag: 'place_image_${widget.place.id}',
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 260,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Dots indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: images.length,
              effect: ExpandingDotsEffect(dotHeight: 8, dotWidth: 8, spacing: 12, activeDotColor: theme.colorScheme.primary, dotColor: Colors.white.withOpacity(0.6), expansionFactor: 3),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? widget.place.nameAR : widget.place.nameFR),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, favs, _) {
              final id = widget.place.id;
              final isFav = id != null && favs.isFavorite(id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                onPressed: id == null ? null : () => favs.toggle(id),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
        ),
        child: ListView(
          children: [
            // ── Carousel or fallback ────────────────────────────────
            _buildImageCarousel(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card (unchanged)
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
                            Localizations.localeOf(context).languageCode == 'ar' ? widget.place.nameAR : widget.place.nameFR,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(child: Text(Localizations.localeOf(context).languageCode == 'ar' ? '${widget.place.cityNameAR}، ${widget.place.wilayaNameAR}' : '${widget.place.cityNameFR}, ${widget.place.wilayaNameFR}', style: theme.textTheme.bodyLarge)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.category, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(loc.translate('type_${widget.place.category.name}'), style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.star, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text('${widget.place.rating}', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ... rest of your cards (Description, Contact, Address, Social) remain unchanged ...
                  const SizedBox(height: 32),

                  // Description Card
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
                            AppLocalizations(Localizations.localeOf(context)).translate('about'),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(widget.place.description ?? '', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Card
                  // phone/email are required in POI model, guard against empty strings instead
                  if ((widget.place.phone.isNotEmpty) || (widget.place.email.isNotEmpty))
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
                            const SizedBox(height: 12),
                            if (widget.place.phone.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: theme.colorScheme.primary),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _launchURL(context, 'tel:${widget.place.phone}'),
                                        child: Text(
                                          widget.place.phone,
                                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.place.email.isNotEmpty) const SizedBox(height: 12),
                                ],
                              ),
                            if (widget.place.email.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.email, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _launchURL(context, 'mailto:${widget.place.email}'),
                                    child: Text(
                                      widget.place.email,
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Address Card
                  if (widget.place.locationLink != null && widget.place.locationLink!.isNotEmpty)
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
                                icon: Icon(Icons.map, color: theme.colorScheme.onPrimary),
                                label: Text(loc.translate('open_map'), style: TextStyle(color: theme.colorScheme.onPrimary)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                onPressed: () => _launchURL(context, widget.place.locationLink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Social links card (Facebook, Instagram, TikTok)
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
                              // Facebook
                              _SocialIconButton(
                                assetPath: 'assets/pictures/facebook.png',
                                tooltip: 'Facebook',
                                enabled: widget.place.facebookLink != null && widget.place.facebookLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.place.facebookLink, fallbackMessage: loc.translate('link_not_available')),
                              ),

                              // Instagram
                              _SocialIconButton(
                                assetPath: 'assets/pictures/instagram.png',
                                tooltip: 'Instagram',
                                enabled: widget.place.instagramLink != null && widget.place.instagramLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.place.instagramLink, fallbackMessage: loc.translate('link_not_available')),
                              ),

                              // TikTok
                              _SocialIconButton(
                                assetPath: 'assets/pictures/tiktok.png',
                                tooltip: 'TikTok',
                                enabled: widget.place.tiktokLink != null && widget.place.tiktokLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.place.tiktokLink, fallbackMessage: loc.translate('link_not_available')),
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
          Image.asset(assetPath, width: 48, height: 48, color: enabled ? null : Colors.grey.withAlpha(120)),
          const SizedBox(height: 6),
          Text(tooltip, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: enabled ? null : Colors.grey)),
        ],
      ),
    );
  }
}
