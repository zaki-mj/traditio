import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/places_provider.dart';
import '../providers/admin_provider.dart';
import '../theme/app_colors.dart';
import 'place_form_page.dart';
import '../l10n/app_localizations.dart';
import '../providers/favorites_provider.dart';

class AdminListPage extends StatelessWidget {
  const AdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final placesProv = context.watch<PlacesProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));
    final favsProv = context.watch<FavoritesProvider>();

    // Get all available locations from provider (provider already includes 'All')
    final locations = placesProv.availableLocations;

    // Static list of known types
    final allTypes = ['hotel', 'restaurant', 'attraction', 'store', 'other'];

    // Filter places
    var filteredPlaces = placesProv.allPlaces.where((p) {
      final query = adminProv.searchQuery.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
      final matchesLocation =
          adminProv.selectedLocation == 'All' ||
          p.location == adminProv.selectedLocation;
      final matchesType =
          adminProv.selectedType.isEmpty || p.type == adminProv.selectedType;
      return matchesQuery && matchesLocation && matchesType;
    }).toList();

    // Sort alphabetically by name
    filteredPlaces.sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: loc.translate('search_places'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) => adminProv.setSearchQuery(val),
              ),
              const SizedBox(height: 12),

              // Filters row
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
                                child: Text(
                                  l,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) adminProv.setLocation(val);
                        },
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
                        value: adminProv.selectedType.isEmpty
                            ? ''
                            : adminProv.selectedType,
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(loc.translate('all_types')),
                          ),
                          ...allTypes.map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t[0].toUpperCase() + t.substring(1),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) adminProv.setType(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filteredPlaces.isEmpty
              ? Center(
                  child: Text(
                    loc.translate('no_places_found'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (ctx, idx) {
                    final place = filteredPlaces[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getTypeColor(
                                                  place.type,
                                                ).withAlpha(50),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                place.type[0].toUpperCase() +
                                                    place.type.substring(1),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: _getTypeColor(
                                                        place.type,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              place.location,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey.shade600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      // Replace rating display with a tappable star that
                                      // toggles favorite status (behaves like favorites system)
                                      
                                      
                                      Text(
                                        loc.translate('add_to_rec'),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.grey.shade700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          favsProv.isFavorite(place.id)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: favsProv.isFavorite(place.id)
                                              ? Colors.amber
                                              : Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          favsProv.toggle(place.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Removed: direct "Add to Recommended" button.
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: Text(loc.translate('edit')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PlaceFormPage(place: place),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: Text(loc.translate('delete')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: ctx,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: Text(
                                            loc.translate('delete_place'),
                                          ),
                                          content: Text(
                                            loc
                                                .translate(
                                                  'confirm_delete_place',
                                                )
                                                .replaceAll(
                                                  '{name}',
                                                  place.name,
                                                ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogCtx),
                                              child: Text(
                                                loc.translate('cancel'),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // For now simulate deletion
                                                placesProv.deletePlace(
                                                  place.id,
                                                );
                                                Navigator.pop(dialogCtx);
                                                ScaffoldMessenger.of(
                                                  ctx,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      loc
                                                          .translate(
                                                            'place_deleted',
                                                          )
                                                          .replaceAll(
                                                            '{name}',
                                                            place.name,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text(
                                                loc.translate('delete'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
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
