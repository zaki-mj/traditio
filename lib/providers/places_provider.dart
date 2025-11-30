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

  // Managed, ordered list of recommended place ids for guests.
  // Initialize to top 3 by rating.
  final List<String> _recommendedIds = [];

  List<PointOfInterest> get recommended {
    // Build ordered list from ids. If empty, return top-rated defaults.
    if (_recommendedIds.isEmpty) {
      final copy = List<PointOfInterest>.from(_all);
      copy.sort((a, b) => b.rating.compareTo(a.rating));
      return copy.take(3).toList();
    }
    return _recommendedIds.map((id) => _all.firstWhere((p) => p.id == id, orElse: () => _all[0])).toList();
  }

  bool isRecommended(String id) => _recommendedIds.contains(id);

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
        description: poi.description,
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
        description: poi.description,
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

  void moveRecommended(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _recommendedIds.length) return;
    if (newIndex < 0 || newIndex >= _recommendedIds.length) return;
    final item = _recommendedIds.removeAt(oldIndex);
    _recommendedIds.insert(newIndex, item);
    notifyListeners();
  }

  /// Delete a place by id (used by admin pages).
  Future<void> deletePlace(String id) async {
    await FirebaseServices().deletePOI(id);
  }

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var p in _all) {
      set.add(p.cityNameFR);
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

  List<PointOfInterest> get filteredPlaces {
    var list = _all.where((p) {
      final matchesQuery = _query.isEmpty || p.nameFR.toLowerCase().contains(_query) || (p.description ?? '').toLowerCase().contains(_query);
      final matchesType = _types.isEmpty || _types.contains(p.category.name);
      final matchesLocation = _location == 'All' || p.cityNameFR == _location;
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
      description: poi.description,
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
