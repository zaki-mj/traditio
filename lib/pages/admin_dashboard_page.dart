import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import '../providers/places_provider.dart';
import '../theme/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProv = context.watch<PlacesProvider>();
    final places = placesProv.allPlaces;
    final theme = Theme.of(context);
    final loc = AppLocalizations(
      Localizations.localeOf(context),
    ); // Ensure loc is initialized

    // Calculate statistics
    final totalPlaces = places.length;
    final hotelCount = places.where((p) => p.type == 'hotel').length;
    final restaurantCount = places.where((p) => p.type == 'restaurant').length;
    final attractionCount = places.where((p) => p.type == 'attraction').length;

    // Group by location
    final locationCounts = <String, int>{};
    for (var p in places) {
      locationCounts[p.location] = (locationCounts[p.location] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total places card
          _buildStatCard(
            context,
            title: loc.translate('total_places'), // Localized
            value: totalPlaces.toString(),
            icon: Icons.place,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Types breakdown (includes store and other)
          Text(
            loc.translate('by_type'), // Localized
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              _buildTypeCard(
                context,
                label: loc.translate('hotels'), // Localized
                count: hotelCount,
                icon: Icons.hotel,
                color: Colors.blue,
              ),
              _buildTypeCard(
                context,
                label: loc.translate('restaurants'), // Localized
                count: restaurantCount,
                icon: Icons.restaurant,
                color: Colors.orange,
              ),
              _buildTypeCard(
                context,
                label: loc.translate('attractions'), // Localized
                count: attractionCount,
                icon: Icons.attractions,
                color: Colors.green,
              ),
              _buildTypeCard(
                context,
                label: loc.translate('stores'), // Localized
                count: places.where((p) => p.type == 'store').length,
                icon: Icons.store,
                color: Colors.purple,
              ),
              _buildTypeCard(
                context,
                label: loc.translate('other'), // Localized
                count: places.where((p) => p.type == 'other').length,
                icon: Icons.more_horiz,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recommended management - simplified
          Text(
            loc.translate('manage_recommended'), // Localized
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<PlacesProvider>(
            builder: (ctx, prov, _) {
              final rec = prov.recommended;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 220,
                        child: ReorderableListView.builder(
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;
                            prov.moveRecommended(oldIndex, newIndex);
                          },
                          itemCount: rec.length,
                          buildDefaultDragHandles: true,
                          itemBuilder: (context, index) {
                            final p = rec[index];
                            return ListTile(
                              key: ValueKey(p.id),
                              leading: SizedBox(
                                width: 56,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(p.name),
                              subtitle: Text("معالم سياحية"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => prov.removeRecommended(p.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Locations breakdown
          Text(
            loc.translate('by_location'), // Localized
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...locationCounts.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLocationTile(
                context,
                location: entry.key,
                count: entry.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildTypeCard(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Icon(icon, color: color, size: 32),

            Text(
              count.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context, {
    required String location,
    required int count,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                location,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
