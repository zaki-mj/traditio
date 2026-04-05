import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/pages/admin/artists_admin_page.dart';
import 'package:traditional_gems/pages/admin/dictionary_admin_page.dart';
import 'package:traditional_gems/pages/admin/journeys_admin_page.dart';
import 'package:traditional_gems/pages/admin/places_admin_page.dart' hide DictionaryAdminPage;
import '../../l10n/app_localizations.dart';
import '../../providers/places_provider.dart';

class AdminListPage extends StatelessWidget {
  const AdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final placesProv = context.watch<PlacesProvider>();
    final theme = Theme.of(context);

    final categories = [
      _CategoryTile(
        label: loc.translate('places'),
        icon: Icons.place_rounded,
        color: const Color(0xFF3B7DD8),
        count: placesProv.allPlaces.length,
        countLabel: loc.translate('total_places_short'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacesAdminPage())),
      ),
      _CategoryTile(
        label: loc.translate('artists'),
        icon: Icons.brush_rounded,
        color: const Color(0xFF8B5CF6),
        count: 18, // placeholder
        countLabel: loc.translate('total_artists_short'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtistsAdminPage())),
      ),
      _CategoryTile(
        label: loc.translate('journeys'),
        icon: Icons.route_rounded,
        color: const Color(0xFF0D9488),
        count: 7, // placeholder
        countLabel: loc.translate('total_journeys_short'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JourneysAdminPage())),
      ),
      _CategoryTile(
        label: loc.translate('dictionary'),
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFE07B39),
        count: 124, // placeholder
        countLabel: loc.translate('total_entries_short'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DictionaryAdminPage())),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.05, children: categories.map((c) => _buildTile(context, c)).toList())),
    );
  }

  Widget _buildTile(BuildContext context, _CategoryTile cat) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cat.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? cat.color.withOpacity(0.15) : cat.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cat.color.withOpacity(isDark ? 0.3 : 0.18), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(color: cat.color.withOpacity(isDark ? 0.25 : 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(cat.icon, color: cat.color, size: 45),
                  ),

                  // Label + count
                  Text(
                    cat.label,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile {
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final String countLabel;
  final VoidCallback onTap;

  const _CategoryTile({required this.label, required this.icon, required this.color, required this.count, required this.countLabel, required this.onTap});
}
