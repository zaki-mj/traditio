import 'package:flutter/material.dart';
import '../models/place.dart';

class PlacesProvider extends ChangeNotifier {
  final List<Place> _all = [
    const Place(
      id: 'p1',
      name: 'Old Town Hotel',
      description:
          'A charming hotel in the historic center with modern amenities.',
      type: 'hotel',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p1/600/400',
      rating: 4.5,
      phone: '+20 1000 123 456',
      email: 'info@oldtownhotel.com',
      address: 'https://maps.google.com/?q=Old+Town+Hotel+Cairo',
      facebookUrl: 'https://facebook.com/oldtownhotel',
      instagramUrl: 'https://instagram.com/oldtownhotel',
      twitterUrl: 'https://twitter.com/oldtownhotel',
    ),
    const Place(
      id: 'p2',
      name: 'Riverview Restaurant',
      description:
          'Traditional cuisine with a riverside view and authentic recipes.',
      type: 'restaurant',
      location: 'Aswan',
      imageUrl: 'https://picsum.photos/seed/p2/600/400',
      rating: 4.7,
      phone: '+20 1100 234 567',
      email: 'reservations@riverviewrest.com',
      address: 'https://maps.google.com/?q=Riverview+Restaurant+Aswan',
    ),
    const Place(
      id: 'p3',
      name: 'Desert Oasis',
      description: 'Scenic attraction with guided tours and desert activities.',
      type: 'attraction',
      location: 'Luxor',
      imageUrl: 'https://picsum.photos/seed/p3/600/400',
      rating: 4.8,
      phone: '+20 1200 345 678',
      email: 'tours@desertoasis.com',
      address: 'https://maps.google.com/?q=Desert+Oasis+Luxor',
    ),
    const Place(
      id: 'p4',
      name: 'Harbor Inn',
      description: 'Cozy lodging near the harbor with Mediterranean views.',
      type: 'hotel',
      location: 'Alexandria',
      imageUrl: 'https://picsum.photos/seed/p4/600/400',
      rating: 4.2,
      phone: '+20 1300 456 789',
      email: 'bookings@harborinn.com',
      address: 'https://maps.google.com/?q=Harbor+Inn+Alexandria',
    ),
    const Place(
      id: 'p5',
      name: 'Spice Market',
      description: 'A bustling market and famous street food destination.',
      type: 'attraction',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p5/600/400',
      rating: 4.3,
      phone: '+20 1400 567 890',
      email: 'contact@spicemarket.com',
      address: 'https://maps.google.com/?q=Spice+Market+Cairo',
    ),
    const Place(
      id: 'p6',
      name: 'Seaside Grill',
      description: 'Fresh seafood served daily in a beachfront setting.',
      type: 'restaurant',
      location: 'Alexandria',
      imageUrl: 'https://picsum.photos/seed/p6/600/400',
      rating: 4.6,
      phone: '+20 1500 678 901',
      email: 'dine@seasidegrill.com',
      address: 'https://maps.google.com/?q=Seaside+Grill+Alexandria',
    ),
    const Place(
      id: 'p7',
      name: 'Khan El-Khalili Bazaar',
      description:
          'Traditional souvenirs and crafts store with authentic items.',
      type: 'store',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p7/600/400',
      rating: 4.4,
      phone: '+20 1600 789 012',
      email: 'shop@khanbazaar.com',
      address: 'https://maps.google.com/?q=Khan+El-Khalili+Cairo',
    ),
    const Place(
      id: 'p8',
      name: 'Modern Shopping Center',
      description:
          'Contemporary shopping mall with local and international brands.',
      type: 'store',
      location: 'Giza',
      imageUrl: 'https://picsum.photos/seed/p8/600/400',
      rating: 4.3,
      phone: '+20 1700 890 123',
      email: 'info@moderncenter.com',
      address: 'https://maps.google.com/?q=Modern+Shopping+Center+Giza',
    ),
    const Place(
      id: 'p9',
      name: 'Historic Citadel',
      description:
          'Ancient fortress with panoramic city views and rich history.',
      type: 'other',
      location: 'Cairo',
      imageUrl: 'https://picsum.photos/seed/p9/600/400',
      rating: 4.9,
      phone: '+20 1800 901 234',
      email: 'visit@historiccitadel.com',
      address: 'https://maps.google.com/?q=Citadel+Cairo',
    ),
    const Place(
      id: 'p10',
      name: 'Cultural Museum',
      description:
          'Museum showcasing traditional artifacts and cultural heritage.',
      type: 'other',
      location: 'Luxor',
      imageUrl: 'https://picsum.photos/seed/p10/600/400',
      rating: 4.7,
      phone: '+20 1900 012 345',
      email: 'info@culturalmuseum.com',
      address: 'https://maps.google.com/?q=Cultural+Museum+Luxor',
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
