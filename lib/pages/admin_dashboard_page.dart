import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import '../../services/firebase_services.dart';
import '../../models/place.dart';
import '../../widgets/category_image.dart';
import '../../providers/places_provider.dart';
import '../../theme/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProv = context.watch<PlacesProvider>();
    final places = placesProv.allPlaces;
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));

    // Calculate statistics
    final totalPlaces = places.length;
    final hotelCount = places.where((p) => p.category.name == 'hotel').length;
    final restaurantCount = places.where((p) => p.category.name == 'restaurant').length;
    final attractionCount = places.where((p) => p.category.name == 'attraction').length;
    final storeCount = places.where((p) => p.category.name == 'store').length;
    final otherCount = places.where((p) => p.category.name == 'other').length;

    // Group by location
    final locationCounts = <String, int>{};
    for (var p in places) {
      final city = p.cityNameFR;
      locationCounts[city] = (locationCounts[city] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total places card
          _buildStatCard(
            context,
            title: loc.translate('total_places'),
            value: totalPlaces.toString(),
            icon: Icons.place,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Types breakdown
          Text(
            loc.translate('by_type'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              _buildTypeCard(context, label: loc.translate('type_hotel'), count: hotelCount, icon: Icons.hotel, color: Colors.blue),
              _buildTypeCard(context, label: loc.translate('type_restaurant'), count: restaurantCount, icon: Icons.restaurant, color: Colors.orange),
              _buildTypeCard(context, label: loc.translate('type_attraction'), count: attractionCount, icon: Icons.attractions, color: Colors.green),
              _buildTypeCard(context, label: loc.translate('type_store'), count: storeCount, icon: Icons.store, color: Colors.purple),
              _buildTypeCard(context, label: loc.translate('type_other'), count: otherCount, icon: Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),

          // Recommended management
          Text(
            loc.translate('manage_recommended'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    children: rec.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(child: Text(loc.translate('no_recommended_places'))),
                            ),
                          ]
                        : rec.map((p) {
                            final title = Localizations.localeOf(context).languageCode == 'ar' ? p.nameAR : p.nameFR;
                            return Padding(
                              key: ValueKey(p.id),
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: CategoryImage(imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : null, category: p.category, fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: p.id == null ? null : () => prov.removeRecommended(p.id!),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
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
              decoration: BoxDecoration(color: color.withAlpha(50), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(BuildContext context, {required String label, required int count, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(count.toString(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}