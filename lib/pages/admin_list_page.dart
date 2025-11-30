import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/places_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'place_form_page.dart';

/// Admin list page — single, clean implementation using current models/providers.
class AdminListPage extends StatelessWidget {
  const AdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final placesProv = context.watch<PlacesProvider>();
    final favsProv = context.watch<FavoritesProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));

    final locations = placesProv.availableLocations;
    const allTypes = ['hotel', 'restaurant', 'attraction', 'store', 'other'];

    final filtered = placesProv.allPlaces.where((p) {
      final q = adminProv.searchQuery;
      final locale = Localizations.localeOf(context).languageCode;
      final name = (locale == 'ar' ? p.nameAR : p.nameFR).toLowerCase();
      final desc = (p.description ?? '').toLowerCase();
      final matchesQuery = q.isEmpty || name.contains(q) || desc.contains(q);
      final matchesLocation = adminProv.selectedLocation == 'All' || p.cityNameFR == adminProv.selectedLocation;
      final matchesType = adminProv.selectedType.isEmpty || p.category.name == adminProv.selectedType;
      return matchesQuery && matchesLocation && matchesType;
    }).toList()..sort((a, b) => a.nameFR.compareTo(b.nameFR));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: loc.translate('search_places'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: adminProv.setSearchQuery,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        value: adminProv.selectedLocation,
                        items: locations
                            .map(
                              (l) => DropdownMenuItem(
                                value: l,
                                child: Text(l, style: theme.textTheme.bodySmall),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => v != null ? adminProv.setLocation(v) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        value: adminProv.selectedType.isEmpty ? '' : adminProv.selectedType,
                        items: [
                          DropdownMenuItem(value: '', child: Text(loc.translate('all_types'))),
                          ...allTypes.map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(loc.translate('type_$t'), style: theme.textTheme.bodySmall),
                            ),
                          ),
                        ],
                        onChanged: (v) => v != null ? adminProv.setType(v) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(loc.translate('no_places_found'), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    final locale = Localizations.localeOf(context).languageCode;
                    final displayName = locale == 'ar' ? p.nameAR : p.nameFR;
                    final city = locale == 'ar' ? p.cityNameAR : p.cityNameFR;
                    final typeLabel = loc.translate('type_${p.category.name}');

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(displayName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: _getTypeColor(p.category.name).withAlpha(50), borderRadius: BorderRadius.circular(4)),
                                              child: Text(
                                                typeLabel,
                                                style: theme.textTheme.bodySmall?.copyWith(color: _getTypeColor(p.category.name), fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(city, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Text(loc.translate('add_to_rec'), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(p.id != null && favsProv.isFavorite(p.id!) ? Icons.star : Icons.star_border, color: p.id != null && favsProv.isFavorite(p.id!) ? Colors.amber : Colors.grey.shade600),
                                        onPressed: p.id == null ? null : () => favsProv.toggle(p.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: Text(loc.translate('edit')),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => PlaceFormPage(place: p)));
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: Text(loc.translate('delete')),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: ctx,
                                        builder: (dctx) => AlertDialog(
                                          title: Text(loc.translate('delete_place')),
                                          content: Text(loc.translate('confirm_delete_place').replaceAll('{name}', displayName)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(loc.translate('cancel'))),
                                            TextButton(
                                              onPressed: () => Navigator.pop(dctx, true),
                                              child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true && p.id != null) {
                                        await placesProv.deletePlace(p.id!);
                                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.translate('place_deleted').replaceAll('{name}', displayName))));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'attraction':
        return Colors.green;
      case 'store':
        return Colors.purple;
      case 'other':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
