import 'package:flutter/material.dart';
import '../models/place.dart';

class PlacesProvider extends ChangeNotifier {
  final List<Place> _all = [
    const Place(
      id: 'p1',
      name: 'Casbah of Algiers',
      description:
          'Historic medina and UNESCO site with narrow alleys, Ottoman palaces and local life.',
      type: 'attraction',
      location: 'Algiers',
      imageUrl: 'https://picsum.photos/seed/p1/600/400',
      rating: 4.8,
      phone: '+213 21 123 456',
      email: 'info@casbah.dz',
      address: 'https://maps.google.com/?q=Casbah+of+Algiers',
    ),
    const Place(
      id: 'p2',
      name: 'Martyrs\' Memorial (Maqam Echahid)',
      description:
          'Iconic concrete monument commemorating Algeria\'s independence with panoramic city views.',
      type: 'attraction',
      location: 'Algiers',
      imageUrl: 'https://picsum.photos/seed/p2/600/400',
      rating: 4.7,
      phone: '+213 21 234 567',
      email: 'visit@maqamechahid.dz',
      address: 'https://maps.google.com/?q=Maqam+Echahid+Algiers',
    ),
    const Place(
      id: 'p3',
      name: 'Santa Cruz Fortress',
      description:
          'Historic Spanish-built fortress above Oran offering sweeping views of the bay.',
      type: 'attraction',
      location: 'Oran',
      imageUrl: 'https://picsum.photos/seed/p3/600/400',
      rating: 4.6,
      phone: '+213 41 345 678',
      email: 'info@santacruzoran.dz',
      address: 'https://maps.google.com/?q=Santa+Cruz+Fortress+Oran',
    ),
    const Place(
      id: 'p4',
      name: 'Hotel El Djazaïr',
      description:
          'A landmark hotel in the heart of Algiers combining colonial charm and modern comfort.',
      type: 'hotel',
      location: 'Algiers',
      imageUrl: 'https://picsum.photos/seed/p4/600/400',
      rating: 4.4,
      phone: '+213 21 456 789',
      email: 'reservations@eldjazair.dz',
      address: 'https://maps.google.com/?q=Hotel+El+Djazair+Algiers',
    ),
    const Place(
      id: 'p5',
      name: 'Le Méditerranée',
      description:
          'Seafood and Mediterranean dishes popular with locals and visitors in Oran.',
      type: 'restaurant',
      location: 'Oran',
      imageUrl: 'https://picsum.photos/seed/p5/600/400',
      rating: 4.5,
      phone: '+213 41 567 890',
      email: 'contact@lemediterranee.dz',
      address: 'https://maps.google.com/?q=Le+Mediterranee+Oran',
    ),
    const Place(
      id: 'p6',
      name: 'Tipasa Archaeological Park',
      description:
          'Coastal Roman ruins set against cliffs and Mediterranean sea views, a UNESCO site.',
      type: 'attraction',
      location: 'Tipasa',
      imageUrl: 'https://picsum.photos/seed/p6/600/400',
      rating: 4.7,
      phone: '+213 24 678 901',
      email: 'info@tipasa.dz',
      address: 'https://maps.google.com/?q=Tipasa+Archaeological+Park',
    ),
    const Place(
      id: 'p7',
      name: 'M\'Zab Valley (Ghardaïa)',
      description:
          'Unique fortified cities in the Sahara with traditional architecture and a living cultural landscape.',
      type: 'attraction',
      location: 'Ghardaïa',
      imageUrl: 'https://picsum.photos/seed/p7/600/400',
      rating: 4.8,
      phone: '+213 29 789 012',
      email: 'visit@mzab.dz',
      address: 'https://maps.google.com/?q=MZAB+Valley+Ghardaia',
    ),
    const Place(
      id: 'p8',
      name: 'Souk El Fellah (Bejaïa)',
      description:
          'Traditional market offering local produce, crafts and Kabyle handmade goods.',
      type: 'store',
      location: 'Béjaïa',
      imageUrl: 'https://picsum.photos/seed/p8/600/400',
      rating: 4.4,
      phone: '+213 34 890 123',
      email: 'info@soukelfellah.dz',
      address: 'https://maps.google.com/?q=Souk+El+Fellah+Bejaia',
    ),
    const Place(
      id: 'p9',
      name: 'Tizi Ouzou Crafts Market',
      description: 'Local crafts and textile market in the Kabylie region.',
      type: 'store',
      location: 'Tizi Ouzou',
      imageUrl: 'https://picsum.photos/seed/p9/600/400',
      rating: 4.3,
      phone: '+213 26 901 234',
      email: 'crafts@tiziouzou.dz',
      address: 'https://maps.google.com/?q=Tizi+Ouzou+Crafts+Market',
    ),
    const Place(
      id: 'p10',
      name: 'Sahara Adventure (Tamanrasset)',
      description:
          'Desert expedition company offering tours into the Hoggar Mountains and Sahara landscapes.',
      type: 'other',
      location: 'Tamanrasset',
      imageUrl: 'https://picsum.photos/seed/p10/600/400',
      rating: 4.6,
      phone: '+213 29 012 345',
      email: 'bookings@saharaadventure.dz',
      address: 'https://maps.google.com/?q=Tamanrasset+Sahara+Tours',
    ),
  ];

  String _query = '';
  final Set<String> _types = {}; // empty = all
  String _location = 'All';

  List<Place> get allPlaces => List.unmodifiable(_all);

  // Managed, ordered list of recommended place ids for guests.
  // Initialize to top 3 by rating.
  final List<String> _recommendedIds = [];

  List<Place> get recommended {
    // Build ordered list from ids. If empty, return top-rated defaults.
    if (_recommendedIds.isEmpty) {
      final copy = List<Place>.from(_all);
      copy.sort((a, b) => b.rating.compareTo(a.rating));
      return copy.take(3).toList();
    }
    return _recommendedIds
        .map((id) => _all.firstWhere((p) => p.id == id, orElse: () => _all[0]))
        .toList();
  }

  bool isRecommended(String id) => _recommendedIds.contains(id);

  void addRecommended(String id) {
    if (!_recommendedIds.contains(id)) {
      _recommendedIds.add(id);
      notifyListeners();
    }
  }

  void removeRecommended(String id) {
    if (_recommendedIds.remove(id)) {
      notifyListeners();
    }
  }

  void moveRecommended(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _recommendedIds.length) return;
    if (newIndex < 0 || newIndex >= _recommendedIds.length) return;
    final item = _recommendedIds.removeAt(oldIndex);
    _recommendedIds.insert(newIndex, item);
    notifyListeners();
  }

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var p in _all) {
      set.add(p.location);
    }
    return set.toList();
  }

  void setSearchQuery(String q) {
    _query = q.toLowerCase();
    notifyListeners();
  }

  void toggleType(String type) {
    if (_types.contains(type)) {
      _types.remove(type);
    } else {
      _types.add(type);
    }
    notifyListeners();
  }

  bool isTypeSelected(String type) => _types.contains(type);

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  String get currentLocation => _location;

  List<Place> get filteredPlaces {
    var list = _all.where((p) {
      final matchesQuery =
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query) ||
          p.description.toLowerCase().contains(_query);
      final matchesType = _types.isEmpty || _types.contains(p.type);
      final matchesLocation = _location == 'All' || p.location == _location;
      return matchesQuery && matchesType && matchesLocation;
    }).toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  Place? byId(String id) =>
      _all.firstWhere((p) => p.id == id, orElse: () => _all[0]);
}
