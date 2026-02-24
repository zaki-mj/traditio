import 'dart:async';

import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firebase_services.dart';

class PlacesProvider extends ChangeNotifier {
  PlacesProvider() {
    startListening();
  }
  final List<PointOfInterest> _all = [];

  String _query = '';
  final Set<String> _types = {}; // empty = all
  String _location = 'All';

  List<PointOfInterest> get allPlaces => List.unmodifiable(_all);

  // Recommended places are those where the POI has its `recommended` flag set.
  List<PointOfInterest> get recommended {
    final rec = _all.where((p) => p.recommended).toList();
    if (rec.isEmpty) {
      // If there are no explicit recommended flags, return the top 3 by rating as a fallback
      final copy = List<PointOfInterest>.from(_all);
      copy.sort((a, b) => b.rating.compareTo(a.rating));
      return copy.take(3).toList();
    }
    // sort recommended by rating desc (you can change ordering if needed)
    rec.sort((a, b) => b.rating.compareTo(a.rating));
    return rec;
  }

  bool isRecommended(String id) => _all.any((p) => p.id == id && p.recommended);

  void addRecommended(String id) async {
    // Mark in Firestore (preferred) and local list will update via stream
    try {
      final poi = _all.firstWhere((p) => p.id == id);
      final updated = PointOfInterest(
        id: poi.id,
        nameAR: poi.nameAR,
        nameFR: poi.nameFR,
        wilayaCode: poi.wilayaCode,
        wilayaNameAR: poi.wilayaNameAR,
        wilayaNameFR: poi.wilayaNameFR,
        cityNameAR: poi.cityNameAR,
        cityNameFR: poi.cityNameFR,
        rating: poi.rating,
        recommended: true,
        category: poi.category,
        phone: poi.phone,
        email: poi.email,
        imageUrl: poi.imageUrl,
        descriptionAR: poi.descriptionAR,
        descriptionFR: poi.descriptionFR,
        descriptionEN: poi.descriptionEN,

        locationLink: poi.locationLink,
        facebookLink: poi.facebookLink,
        instagramLink: poi.instagramLink,
        tiktokLink: poi.tiktokLink,
        createdAt: poi.createdAt,
        updatedAt: DateTime.now(),
      );
      await FirebaseServices().updatePOI(updated);
    } catch (_) {}
  }

  void removeRecommended(String id) async {
    try {
      final poi = _all.firstWhere((p) => p.id == id);
      final updated = PointOfInterest(
        id: poi.id,
        nameAR: poi.nameAR,
        nameFR: poi.nameFR,
        wilayaCode: poi.wilayaCode,
        wilayaNameAR: poi.wilayaNameAR,
        wilayaNameFR: poi.wilayaNameFR,
        cityNameAR: poi.cityNameAR,
        cityNameFR: poi.cityNameFR,
        rating: poi.rating,
        recommended: false,
        category: poi.category,
        phone: poi.phone,
        email: poi.email,
        imageUrl: poi.imageUrl,
        descriptionAR: poi.descriptionAR,
        descriptionFR: poi.descriptionFR,
        descriptionEN: poi.descriptionEN,

        locationLink: poi.locationLink,
        facebookLink: poi.facebookLink,
        instagramLink: poi.instagramLink,
        tiktokLink: poi.tiktokLink,
        createdAt: poi.createdAt,
        updatedAt: DateTime.now(),
      );
      await FirebaseServices().updatePOI(updated);
    } catch (_) {}
  }

  // moveRecommended isn't meaningful when recommendations are stored as flags;
  // ordering should be handled explicitly in Firestore or by a separate ordering field if needed.

  /// Delete a place by id (used by admin pages).
  Future<void> deletePlace(String id) async {
    await FirebaseServices().deletePOI(id);
  }

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var p in _all) {
      set.add(p.wilayaNameFR);
    }
    return set.toList()..sort();
  }

  // Get wilaya name in the specified language
  String getWilayaName(String wilayaNameFR, String languageCode) {
    if (languageCode == 'ar') {
      try {
        final poi = _all.firstWhere((p) => p.wilayaNameFR == wilayaNameFR);
        return poi.wilayaNameAR;
      } catch (_) {
        return wilayaNameFR;
      }
    }
    return wilayaNameFR;
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

  Set<String> get types => _types;

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  String get currentLocation => _location;

  String get searchQuery => _query;

  bool get hasActiveFilters => _query.isNotEmpty || _types.isNotEmpty || _location != 'All';

  void clearFilters() {
    _query = '';
    _types.clear();
    _location = 'All';
    notifyListeners();
  }

  List<PointOfInterest> get filteredPlaces {
    var list = _all.where((p) {
      // Search query matches either name (AR or FR) or description
      final matchesQuery = _query.isEmpty || p.nameFR.toLowerCase().contains(_query) || p.nameAR.toLowerCase().contains(_query) || (p.description ?? '').toLowerCase().contains(_query);

      // Type filter
      final matchesType = _types.isEmpty || _types.contains(p.category.name);

      // Location filter by wilaya (not city)
      final matchesLocation = _location == 'All' || p.wilayaNameFR == _location;

      return matchesQuery && matchesType && matchesLocation;
    }).toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  PointOfInterest? byId(String id) {
    try {
      return _all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Firestore subscription
  StreamSubscription<List<PointOfInterest>>? _subscription;

  final FirebaseServices _svc = FirebaseServices();

  void startListening() {
    // If already listening, do nothing
    if (_subscription != null) return;
    _subscription = _svc.streamPOIs().listen((list) {
      _all
        ..clear()
        ..addAll(list);
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  /// Toggle recommended status (update in Firestore).
  Future<void> toggleRecommended(String id) async {
    final poi = _all.firstWhere((p) => p.id == id, orElse: () => throw StateError('POI not found'));
    final updated = PointOfInterest(
      id: poi.id,
      nameAR: poi.nameAR,
      nameFR: poi.nameFR,
      wilayaCode: poi.wilayaCode,
      wilayaNameAR: poi.wilayaNameAR,
      wilayaNameFR: poi.wilayaNameFR,
      cityNameAR: poi.cityNameAR,
      cityNameFR: poi.cityNameFR,
      rating: poi.rating,
      recommended: !poi.recommended,
      category: poi.category,
      phone: poi.phone,
      email: poi.email,
      imageUrl: poi.imageUrl,
      descriptionAR: poi.descriptionAR,
      descriptionFR: poi.descriptionFR,
      descriptionEN: poi.descriptionEN,

      locationLink: poi.locationLink,
      facebookLink: poi.facebookLink,
      instagramLink: poi.instagramLink,
      tiktokLink: poi.tiktokLink,
      createdAt: poi.createdAt,
      updatedAt: DateTime.now(),
    );
    await _svc.updatePOI(updated);
  }
}
