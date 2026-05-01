import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/models/journey.dart';
import 'package:traditional_gems/models/place.dart';

import 'package:traditional_gems/providers/journey_provider.dart';
import 'package:traditional_gems/providers/places_provider.dart';
import 'package:traditional_gems/widgets/admin_search_bar.dart';

class JourneysAdminPage extends StatefulWidget {
  const JourneysAdminPage({super.key});

  @override
  State<JourneysAdminPage> createState() => _JourneysAdminPageState();
}

class _JourneysAdminPageState extends State<JourneysAdminPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final places = context.read<PlacesProvider>().allPlaces;
    context.read<JourneyProvider>().startListening(places);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final journeyProv = context.watch<JourneyProvider>();

    final filtered = journeyProv.filteredJourneys;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('journeys')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(icon: const Icon(Icons.add_rounded, size: 18), label: Text(loc.translate('add_journey')), onPressed: () => _showJourneyModal(context)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminSearchBar(hintText: loc.translate('search_journeys'), onChanged: (q) => setState(() => _searchQuery = q)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(loc: loc)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final journey = filtered[index];
                      return _JourneyCard(
                        journey: journey,
                        onEdit: () => _showJourneyModal(context, journey: journey),
                        onDelete: () => _confirmDelete(context, journey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Bottom Modal for Create / Edit Journey
  void _showJourneyModal(BuildContext context, {Journey? journey}) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final placesProv = context.read<PlacesProvider>();
    final journeyProv = context.read<JourneyProvider>();

    final nameARCtrl = TextEditingController(text: journey?.nameAR);
    final nameFRCtrl = TextEditingController(text: journey?.nameFR);
    final descARCtrl = TextEditingController(text: journey?.descriptionAR);
    final descFRCtrl = TextEditingController(text: journey?.descriptionFR);
    final descENCtrl = TextEditingController(text: journey?.descriptionEN);

    List<PointOfInterest> selectedPois = List.from(journey?.pois ?? []);
    bool showPlacePicker = false;
    String placeSearchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Filter available places (exclude already selected + search)
          final availablePlaces = placesProv.allPlaces.where((p) => !selectedPois.any((s) => s.id == p.id)).where((p) => placeSearchQuery.isEmpty || p.nameAR.toLowerCase().contains(placeSearchQuery.toLowerCase()) || p.nameFR.toLowerCase().contains(placeSearchQuery.toLowerCase())).toList();

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(journey == null ? loc.translate('add_journey') : loc.translate('edit_journey'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Journey Basic Info
                  if (!showPlacePicker) ...[
                    TextField(
                      controller: nameARCtrl,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: loc.translate('name_ar'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameFRCtrl,
                      decoration: InputDecoration(
                        labelText: loc.translate('name_fr'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: descARCtrl,
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.translate('description_ar'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descFRCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.translate('description_fr'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descENCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.translate('description_en'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selected Places Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${loc.translate('selected_places')} (${selectedPois.length}/7)", style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextButton.icon(icon: const Icon(Icons.add), label: Text(loc.translate('add_places')), onPressed: () => setModalState(() => showPlacePicker = true)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Selected Places List
                    if (selectedPois.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(loc.translate('no_places_selected'), style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...selectedPois.map((poi) => _JourneyPlaceCard(place: poi, isSelected: true, onTap: () => setModalState(() => selectedPois.remove(poi)))),
                  ],

                  // ==================== PLACE PICKER MODE ====================
                  if (showPlacePicker) ...[
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setModalState(() => showPlacePicker = false)),
                        Expanded(
                          child: Text(loc.translate('add_places'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sticky Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: loc.translate('search_places_to_add'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      onChanged: (value) {
                        setModalState(() => placeSearchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Full List of Available Places
                    SizedBox(
                      height: 420, // Takes most of the remaining space
                      child: availablePlaces.isEmpty
                          ? Center(child: Text(loc.translate('no_places_available')))
                          : ListView.builder(
                              itemCount: availablePlaces.length,
                              itemBuilder: (ctx, i) {
                                final place = availablePlaces[i];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: _JourneyPlaceCard(
                                    place: place,
                                    isSelected: false,
                                    onTap: () {
                                      if (selectedPois.length < 7) {
                                        setModalState(() => selectedPois.add(place));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('max_7_places'))));
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Save Button (always visible)
                  if (!showPlacePicker)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final nameAREmpty = nameARCtrl.text.trim().isEmpty;
                          final nameFREmpty = nameFRCtrl.text.trim().isEmpty;
                          final noPoisSelected = selectedPois.isEmpty;

                          if (nameAREmpty || nameFREmpty || noPoisSelected) {
                            final missing = <String>[];
                            if (nameAREmpty) missing.add(loc.translate('name_ar'));
                            if (nameFREmpty) missing.add(loc.translate('name_fr'));
                            if (noPoisSelected) missing.add(loc.translate('selected_places'));

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.translate('fill_all_fields')}: ${missing.join(", ")}'), backgroundColor: Colors.red));
                            return;
                          }

                          final newJourney = Journey(id: journey?.id, nameAR: nameARCtrl.text.trim(), nameFR: nameFRCtrl.text.trim(), descriptionAR: descARCtrl.text.trim(), descriptionFR: descFRCtrl.text.trim(), descriptionEN: descENCtrl.text.trim(), pois: selectedPois);

                          if (journey == null) {
                            await journeyProv.addJourney(newJourney);
                          } else {
                            await journeyProv.updateJourney(journey.id!, newJourney);
                          }

                          Navigator.pop(context);
                        },
                        child: Text(journey == null ? loc.translate('add') : loc.translate('save')),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Place Picker Modal
  void _showPlacePicker(BuildContext context, List<PointOfInterest> selected, StateSetter setModalState) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final allPlaces = context.read<PlacesProvider>().allPlaces;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(hintText: loc.translate('search_places')),
                onChanged: (q) {
                  /* add search logic if needed */
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: allPlaces.length,
                itemBuilder: (ctx, i) {
                  final p = allPlaces[i];
                  final alreadySelected = selected.any((s) => s.id == p.id);

                  return ListTile(
                    title: Text(p.nameAR),
                    subtitle: Text(p.nameFR),
                    trailing: alreadySelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: alreadySelected
                        ? null
                        : () {
                            setModalState(() => selected.add(p));
                            Navigator.pop(ctx);
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Journey journey) async {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(loc.translate('delete_journey')),
        content: Text(loc.translate('confirm_delete_journey')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<JourneyProvider>().deleteJourney(journey.id!);
    }
  }
}

// Simple Card for Journey List
class _JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JourneyCard({required this.journey, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(journey.nameAR),
        subtitle: Text(journey.nameFR),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations loc;
  const _EmptyState({required this.loc});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.route_rounded, size: 52, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(loc.translate('journeys_coming_soon')),
      ],
    ),
  );
}

class _JourneyPlaceCard extends StatelessWidget {
  final PointOfInterest place;
  final bool isSelected;
  final VoidCallback onTap;

  const _JourneyPlaceCard({super.key, required this.place, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context).languageCode;

    final title = locale == 'ar' ? place.nameAR : place.nameFR;
    final city = locale == 'ar' ? (place.wilayaNameAR != 'NULL' ? place.wilayaNameAR : '') : (place.cityNameFR != 'NULL' ? place.wilayaNameFR : "");

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.15), width: isSelected ? 2 : 1),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: _getCategoryColor(place.category).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(city, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(POICategory category) {
    switch (category) {
      case POICategory.hotel:
        return Colors.blue;
      case POICategory.restaurant:
        return Colors.orange;
      case POICategory.attraction:
        return Colors.green;
      case POICategory.guesthouse:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(POICategory category) {
    switch (category) {
      case POICategory.hotel:
        return Icons.hotel;
      case POICategory.restaurant:
        return Icons.restaurant;
      case POICategory.attraction:
        return Icons.place;
      case POICategory.guesthouse:
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
