import 'package:flutter/material.dart';
import '../models/place.dart';

class PlacesProvider extends ChangeNotifier {
  final List<Place> _all = [
    const Place(
      id: 'p1',
      name: 'Old Town Hotel',
      description: 'A charming hotel in the historic center.',
      type: 'hotel',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p1/600/400',
      rating: 4.5,
    ),
    const Place(
      id: 'p2',
      name: 'Riverview Restaurant',
      description: 'Traditional cuisine with a riverside view.',
      type: 'restaurant',
      location: 'Aswan',
      imageUrl: 'https://picsum.photos/seed/p2/600/400',
      rating: 4.7,
    ),
    const Place(
      id: 'p3',
      name: 'Desert Oasis',
      description: 'Scenic attraction with guided tours.',
      type: 'attraction',
      location: 'Luxor',
      imageUrl: 'https://picsum.photos/seed/p3/600/400',
      rating: 4.8,
    ),
    const Place(
      id: 'p4',
      name: 'Harbor Inn',
      description: 'Cozy lodging near the harbor.',
      type: 'hotel',
      location: 'Alexandria',
      imageUrl: 'https://picsum.photos/seed/p4/600/400',
      rating: 4.2,
    ),
    const Place(
      id: 'p5',
      name: 'Spice Market',
      description: 'A bustling market and famous street food.',
      type: 'attraction',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p5/600/400',
      rating: 4.3,
    ),
    const Place(
      id: 'p6',
      name: 'Seaside Grill',
      description: 'Fresh seafood served daily.',
      type: 'restaurant',
      location: 'Alexandria',
      imageUrl: 'https://picsum.photos/seed/p6/600/400',
      rating: 4.6,
    ),
  ];

  String _query = '';
  final Set<String> _types = {}; // empty = all
  String _location = 'All';

  List<Place> get allPlaces => List.unmodifiable(_all);

  List<Place> get recommended =>
      _all..sort((a, b) => b.rating.compareTo(a.rating));

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
