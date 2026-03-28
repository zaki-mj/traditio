import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/pages/place_form_page.dart';
import 'package:traditional_gems/providers/places_provider.dart';
import 'package:traditional_gems/widgets/admin_search_bar.dart';

class PlacesAdminPage extends StatefulWidget {
  const PlacesAdminPage({super.key});

  @override
  State<PlacesAdminPage> createState() => _PlacesAdminPageState();
}

class _PlacesAdminPageState extends State<PlacesAdminPage> {
  static const _allTypes = ['hotel', 'restaurant', 'attraction', 'store', 'other'];
  static const _typeColors = {'hotel': Color(0xFF3B7DD8), 'restaurant': Color(0xFFE07B39), 'attraction': Color(0xFF16A34A), 'store': Color(0xFF8B5CF6), 'other': Color(0xFF6B7280)};
  static const _typeIcons = {'hotel': Icons.hotel_rounded, 'restaurant': Icons.restaurant_rounded, 'attraction': Icons.attractions_rounded, 'store': Icons.store_rounded, 'other': Icons.more_horiz_rounded};

  String _searchQuery = '';
  String _selectedType = '';
  String _selectedLocation = 'All';

  @override
  Widget build(BuildContext context) {
    final placesProv = context.watch<PlacesProvider>();
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final locations = placesProv.availableLocations;

    final filtered = placesProv.allPlaces.where((p) {
      final name = (locale == 'ar' ? p.nameAR : p.nameFR).toLowerCase();
      final desc = (p.description ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty || name.contains(q) || desc.contains(q);
      final matchesLocation = _selectedLocation == 'All' || p.cityNameFR == _selectedLocation;
      final matchesType = _selectedType.isEmpty || p.category.name == _selectedType;
      return matchesQuery && matchesLocation && matchesType;
    }).toList()..sort((a, b) => a.nameFR.compareTo(b.nameFR));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('places')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(loc.translate('add_new_place')),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceFormPage())),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filters ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminSearchBar(
              hintText: loc.translate('search_places'),
              onChanged: (q) => setState(() => _searchQuery = q),
              filters: [
                AdminFilterChip(label: loc.translate('all_types'), value: '', selected: _selectedType.isEmpty, onTap: () => setState(() => _selectedType = '')),
                ..._allTypes.map((t) => AdminFilterChip(label: loc.translate('type_$t'), value: t, selected: _selectedType == t, onTap: () => setState(() => _selectedType = _selectedType == t ? '' : t), icon: _typeIcons[t], activeColor: _typeColors[t])),
              ],
              trailing: [_LocationButton(locations: locations, selected: _selectedLocation, onChanged: (v) => setState(() => _selectedLocation = v))],
            ),
          ),

          // ── Result count pill ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${filtered.length} ${loc.translate('results_found')}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.55), fontWeight: FontWeight.w500),
                  ),
                ),
                if (_selectedType.isNotEmpty || _selectedLocation != 'All' || _searchQuery.isNotEmpty) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _selectedType = '';
                      _selectedLocation = 'All';
                    }),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      loc.translate('clear_filters'),
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(message: loc.translate('no_places_found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      final displayName = locale == 'ar' ? p.nameAR : p.nameFR;
                      final city = locale == 'ar' ? p.cityNameAR + " ، " + p.wilayaNameAR : p.cityNameFR + " , " + p.wilayaNameFR;
                      final type = p.category.name;
                      final typeColor = _typeColors[type] ?? const Color(0xFF6B7280);
                      final typeIcon = _typeIcons[type] ?? Icons.place_rounded;
                      final isRec = p.id != null && placesProv.isRecommended(p.id!);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PlaceCard(
                          name: displayName,
                          city: city,
                          typeLabel: loc.translate('type_$type'),
                          typeColor: typeColor,
                          typeIcon: typeIcon,
                          isRecommended: isRec,
                          onToggleRecommended: p.id == null ? null : () => placesProv.toggleRecommended(p.id!),
                          onEdit: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlaceFormPage(place: p))),
                          onDelete: () async {
                            final confirmed = await _confirmDelete(ctx, loc, displayName);
                            if (confirmed == true && p.id != null) {
                              await placesProv.deletePlace(p.id!);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.translate('place_deleted').replaceAll('{name}', displayName)), behavior: SnackBarBehavior.floating));
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext ctx, AppLocalizations loc, String name) {
    return showDialog<bool>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: Text(loc.translate('delete_place')),
        content: Text(loc.translate('confirm_delete_place').replaceAll('{name}', name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Place card
// ---------------------------------------------------------------------------

class _PlaceCard extends StatelessWidget {
  final String name;
  final String city;
  final String typeLabel;
  final Color typeColor;
  final IconData typeIcon;
  final bool isRecommended;
  final VoidCallback? onToggleRecommended;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlaceCard({required this.name, required this.city, required this.typeLabel, required this.typeColor, required this.typeIcon, required this.isRecommended, required this.onToggleRecommended, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon bubble
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: typeColor.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(typeIcon, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.1)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _MiniChip(label: typeLabel, color: typeColor),
                        const SizedBox(width: 6),
                        Icon(Icons.location_on_rounded, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 2),
                        Text(city, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ActionChip(label: 'Edit', icon: Icons.edit_rounded, onTap: onEdit, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        _ActionChip(label: 'Delete', icon: Icons.delete_outline_rounded, onTap: onDelete, color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              // Star toggle
              GestureDetector(
                onTap: onToggleRecommended,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isRecommended ? Colors.amber.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isRecommended ? Colors.amber.withOpacity(0.5) : theme.colorScheme.outline.withOpacity(0.15), width: 1),
                  ),
                  child: Icon(isRecommended ? Icons.star_rounded : Icons.star_border_rounded, color: isRecommended ? Colors.amber : theme.colorScheme.onSurface.withOpacity(0.3), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location filter button (popup menu)
// ---------------------------------------------------------------------------

class _LocationButton extends StatelessWidget {
  final List<String> locations;
  final String selected;
  final ValueChanged<String> onChanged;

  const _LocationButton({required this.locations, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = selected != 'All';

    return PopupMenuButton<String>(
      tooltip: 'Filter by location',
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => locations
          .map(
            (l) => PopupMenuItem<String>(
              value: l,
              child: Row(
                children: [
                  Icon(l == selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: l == selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 10),
                  Text(l, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
          .toList(),
      onSelected: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? theme.colorScheme.primary.withOpacity(0.35) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.45)),
            if (active) ...[
              const SizedBox(width: 4),
              Text(
                selected,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionChip({required this.label, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
        ],
      ),
    );
  }
}
