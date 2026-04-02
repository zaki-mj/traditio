import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/artist.dart';
import '../widgets/category_image.dart'; // You can keep or remove if not needed
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistDetailPage extends StatefulWidget {
  final Artist artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
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
    if (url == null || url.trim().isEmpty) {
      if (!context.mounted) return;
      final loc = AppLocalizations(Localizations.localeOf(context));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fallbackMessage ?? loc.translate('link_not_available'))));
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      final loc = AppLocalizations(Localizations.localeOf(context));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('invalid_link'))));
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('could_not_open_link'))));
      }
    } catch (e) {
      if (!context.mounted) return;
      final loc = AppLocalizations(Localizations.localeOf(context));
      final msg = loc.translate('failed_to_launch').replaceAll('{error}', e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildImageCarousel() {
    final images = widget.artist.imageUrls ?? [];
    final hasImages = images.isNotEmpty;
    final theme = Theme.of(context);

    if (!hasImages) {
      // Fallback when no multiple images (use single imageUrl or placeholder)
      return ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        child: widget.artist.imageUrl != null && widget.artist.imageUrl!.isNotEmpty
            ? Image.network(
                widget.artist.imageUrl!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              )
            : Container(height: 260, color: theme.colorScheme.primary.withAlpha(30), child: const Icon(Icons.person, size: 100)),
      );
    }

    // Multiple images carousel
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

        // Smooth page indicator
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
    final languageCode = Localizations.localeOf(context).languageCode;

    final displayName = languageCode == 'ar' ? (widget.artist.nameAR.isNotEmpty ? widget.artist.nameAR : widget.artist.nameFR) : (widget.artist.nameFR.isNotEmpty ? widget.artist.nameFR : widget.artist.nameAR);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, favs, _) {
              final id = widget.artist.id;
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
          image: DecorationImage(image: const AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
        ),
        child: ListView(
          children: [
            // Image Carousel
            _buildImageCarousel(),

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
                            displayName,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(child: Text(languageCode == 'ar' ? '${widget.artist.cityNameAR}، ${widget.artist.wilayaNameAR}' : '${widget.artist.cityNameFR}, ${widget.artist.wilayaNameFR}', style: theme.textTheme.bodyLarge)),
                            ],
                          ),
                          // No category or rating for artists
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Card
                  if (widget.artist.description != null && widget.artist.description!.isNotEmpty)
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
                            Text(widget.artist.description ?? '', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Contact Card
                  if (widget.artist.phone.isNotEmpty || widget.artist.email.isNotEmpty)
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
                            if (widget.artist.phone.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: theme.colorScheme.primary),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _launchURL(context, 'tel:${widget.artist.phone}'),
                                        child: Text(
                                          widget.artist.phone,
                                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.artist.email.isNotEmpty) const SizedBox(height: 12),
                                ],
                              ),
                            if (widget.artist.email.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.email, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _launchURL(context, 'mailto:${widget.artist.email}'),
                                    child: Text(
                                      widget.artist.email,
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

                  // Address / Location Card
                  if (widget.artist.locationLink != null && widget.artist.locationLink!.isNotEmpty)
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
                                onPressed: () => _launchURL(context, widget.artist.locationLink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Social Media Card
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
                                tooltip: loc.translate('social_facebook'),
                                enabled: widget.artist.facebookLink != null && widget.artist.facebookLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.artist.facebookLink, fallbackMessage: loc.translate('link_not_available')),
                              ),
                              _SocialIconButton(
                                assetPath: 'assets/pictures/instagram.png',
                                tooltip: loc.translate('social_instagram'),
                                enabled: widget.artist.instagramLink != null && widget.artist.instagramLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.artist.instagramLink, fallbackMessage: loc.translate('link_not_available')),
                              ),
                              _SocialIconButton(
                                assetPath: 'assets/pictures/tiktok.png',
                                tooltip: loc.translate('social_tiktok'),
                                enabled: widget.artist.tiktokLink != null && widget.artist.tiktokLink!.isNotEmpty,
                                onTap: () => _launchURL(context, widget.artist.tiktokLink, fallbackMessage: loc.translate('link_not_available')),
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

// Keep the same _SocialIconButton widget (unchanged)
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
