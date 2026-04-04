import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/models/artist.dart';
import 'package:traditional_gems/providers/artists_provider.dart';
import '../../services/firebase_services.dart';
import '../../models/place.dart';
import '../../widgets/category_image.dart';
import '../../providers/places_provider.dart';
import '../../theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Placeholder models for future categories (replace with real models later)
// ---------------------------------------------------------------------------

class _ArtistPlaceholder {
  final String id;
  final String nameFR;
  final String nameAR;
  final String? imageUrl;
  bool featured;
  _ArtistPlaceholder({required this.id, required this.nameFR, required this.nameAR, this.imageUrl, this.featured = false});
}

class _JourneyPlaceholder {
  final String id;
  final String nameFR;
  final String nameAR;
  final String? imageUrl;
  bool featured;
  _JourneyPlaceholder({required this.id, required this.nameFR, required this.nameAR, this.imageUrl, this.featured = false});
}

// ---------------------------------------------------------------------------
// Placeholder data (swap with real providers when ready)
// ---------------------------------------------------------------------------

final List<_ArtistPlaceholder> _mockArtists = [
  _ArtistPlaceholder(id: 'a1', nameFR: 'Aïcha Redouane', nameAR: 'عائشة ردوان', featured: true),
  _ArtistPlaceholder(id: 'a2', nameFR: 'Lounès Matoub', nameAR: 'لونيس معتوب', featured: true),
  _ArtistPlaceholder(id: 'a3', nameFR: 'Idir', nameAR: 'إيدير', featured: false),
  _ArtistPlaceholder(id: 'a4', nameFR: 'Souad Massi', nameAR: 'سعاد ماسي', featured: false),
];

final List<_JourneyPlaceholder> _mockJourneys = [
  _JourneyPlaceholder(id: 'j1', nameFR: 'Route des Zianides', nameAR: 'طريق الزيانيين', featured: true),
  _JourneyPlaceholder(id: 'j2', nameFR: 'Circuit Sahara', nameAR: 'جولة الصحراء', featured: false),
  _JourneyPlaceholder(id: 'j3', nameFR: 'Balcon du Djurdjura', nameAR: 'شرفة جرجرة', featured: false),
];

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Expansion state for each featured section
  bool _placesExpanded = false;
  bool _artistsExpanded = false;
  bool _journeysExpanded = false;

  // Local mutable copies of placeholders (real providers will replace these)
  final List<_ArtistPlaceholder> _artists = List.from(_mockArtists);
  final List<_JourneyPlaceholder> _journeys = List.from(_mockJourneys);

  @override
  Widget build(BuildContext context) {
    final placesProv = context.watch<PlacesProvider>();
    final artistsProv = context.watch<ArtistsProvider>();
    final places = placesProv.allPlaces;
    final artists = artistsProv.allArtists;
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context).languageCode;

    final int totalPlaces = places.length;
    final int totalArtists = artists.length;
    final int totalJourneys = _journeys.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Stat cards ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(title: loc.translate('total_places'), value: totalPlaces.toString(), icon: Icons.place, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(title: loc.translate('artists'), value: totalArtists.toString(), icon: Icons.brush, color: Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(title: loc.translate('journeys'), value: totalJourneys.toString(), icon: Icons.route, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()),
            ],
          ),
          const SizedBox(height: 24),

          // ── Places by type ────────────────────────────────────────────────
          Text(loc.translate('by_type'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              _TypeCard(context, label: loc.translate('hotels'), count: places.where((p) => p.category.name == 'hotel').length, icon: Icons.hotel, color: Colors.blue),
              _TypeCard(context, label: loc.translate('restaurants'), count: places.where((p) => p.category.name == 'restaurant').length, icon: Icons.restaurant, color: Colors.orange),
              _TypeCard(context, label: loc.translate('attractions'), count: places.where((p) => p.category.name == 'attraction').length, icon: Icons.attractions, color: Colors.green),
              _TypeCard(context, label: loc.translate('guesthouses'), count: places.where((p) => p.category.name == 'guesthouse').length, icon: Icons.home, color: Colors.purple),
              _TypeCard(context, label: loc.translate('other'), count: places.where((p) => p.category.name == 'other').length, icon: Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),

          // ── Featured management ───────────────────────────────────────────
          Text(loc.translate('manage_featured'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Places section
          _FeaturedSection(
            title: loc.translate('places'),
            icon: Icons.place,
            accentColor: Colors.blue,
            isExpanded: _placesExpanded,
            onToggle: () => setState(() => _placesExpanded = !_placesExpanded),
            featuredCount: places.where((p) => p.id != null && placesProv.isRecommended(p.id!)).length,
            child: StreamBuilder<List<PointOfInterest>>(
              stream: FirebaseServices().streamRecommendedPOIs(),
              builder: (_, snap) {
                final rec = snap.hasData ? snap.data! : placesProv.recommended;

                if (rec.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(loc.translate('no_places_found'), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: rec.map((p) {
                    final title = locale == 'ar' ? p.nameAR : p.nameFR;

                    // Safe image URL handling
                    final imageUrl = (p.imageUrls != null && p.imageUrls!.isNotEmpty) ? p.imageUrls![0] : null; // or a default placeholder URL

                    final subtitle = locale == 'ar' ? (p.cityNameAR ?? '') : (p.cityNameFR ?? '');

                    return _FeaturedRow(key: ValueKey(p.id), imageUrl: imageUrl, title: title, subtitle: subtitle, onRemove: p.id == null ? null : () => placesProv.removeRecommended(p.id!));
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Artists section (placeholder)
          _FeaturedSection(
            title: loc.translate('artists'),
            icon: Icons.brush,
            accentColor: Colors.purple,
            isExpanded: _artistsExpanded,
            onToggle: () => setState(() => _artistsExpanded = !_artistsExpanded),
            featuredCount: artists.where((a) => a.id != null && artistsProv.isRecommended(a.id!)).length,
            child: StreamBuilder<List<Artist>>(
              stream: FirebaseServices().streamRecommendedArtists(),
              builder: (_, snap) {
                final rec = snap.hasData ? snap.data! : ArtistsProvider().recommended;
                if (rec.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(loc.translate('no_artists_found'), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    ),
                  );
                }
                return Column(
                  children: rec.map((a) {
                    final title = locale == 'ar' ? a.nameAR : a.nameFR;
                    return _FeaturedRow(key: ValueKey(a.id), imageUrl: a.imageUrl, title: title, subtitle: locale == 'ar' ? a.cityNameAR : a.cityNameFR, onRemove: a.id == null ? null : () => artistsProv.toggleRecommended(a.id!));
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Journeys section (placeholder)
          _FeaturedSection(
            title: loc.translate('journeys'),
            icon: Icons.route,
            accentColor: Colors.teal,
            isExpanded: _journeysExpanded,
            onToggle: () => setState(() => _journeysExpanded = !_journeysExpanded),
            featuredCount: _journeys.where((j) => j.featured).length,
            child: Column(
              children: _journeys.where((j) => j.featured).map((j) {
                final title = locale == 'ar' ? j.nameAR : j.nameFR;
                return _FeaturedRow(key: ValueKey(j.id), title: title, subtitle: loc.translate('placeholder_data'), onRemove: () => setState(() => j.featured = false));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _TypeCard(BuildContext context, {required String label, required int count, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            Icon(icon, color: color, size: 32),
            Text(count.toString(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible section card for a featured category.
class _FeaturedSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int featuredCount;
  final Widget child;

  const _FeaturedSection({required this.title, required this.icon, required this.accentColor, required this.isExpanded, required this.onToggle, required this.featuredCount, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: accentColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withAlpha(40), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '$featuredCount',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more)),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: child),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

/// One row inside a featured section.
class _FeaturedRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onRemove;

  const _FeaturedRow({super.key, required this.title, required this.subtitle, this.imageUrl, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: imageUrl != null ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()) : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}
