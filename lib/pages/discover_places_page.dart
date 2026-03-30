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

  // Recommended places
  List<PointOfInterest> get recommended {
    final rec = _all.where((p) => p.recommended).toList();
    if (rec.isEmpty) {
      final copy = List<PointOfInterest>.from(_all);
      copy.sort((a, b) => b.rating.compareTo(a.rating));
      return copy.take(3).toList();
    }
    rec.sort((a, b) => b.rating.compareTo(a.rating));
    return rec;
  }

  bool isRecommended(String id) => _all.any((p) => p.id == id && p.recommended);

  // ====================== RECOMMENDATION TOGGLE (Fixed) ======================
  Future<void> toggleRecommended(String id) async {
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
        recommended: !poi.recommended,
        category: poi.category,
        phone: poi.phone,
        email: poi.email,
        imageUrls: poi.imageUrls, // ← Important fix
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
    } catch (e) {
      print('Error toggling recommended: $e');
    }
  }

  void addRecommended(String id) => toggleRecommended(id);
  void removeRecommended(String id) => toggleRecommended(id);

  // ====================== GETTERS ======================
  Set<String> get types => _types; // ← This was missing!

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var p in _all) {
      if (p.wilayaNameFR != null) set.add(p.wilayaNameFR!);
    }
    return set.toList()..sort();
  }

  String get currentLocation => _location;
  String get searchQuery => _query;
  bool get hasActiveFilters => _query.isNotEmpty || _types.isNotEmpty || _location != 'All';

  // ====================== FILTER METHODS ======================
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

  void clearFilters() {
    _query = '';
    _types.clear();
    _location = 'All';
    notifyListeners();
  }

  List<PointOfInterest> get filteredPlaces {
    var list = _all.where((p) {
      final matchesQuery = _query.isEmpty || p.nameFR.toLowerCase().contains(_query) || p.nameAR.toLowerCase().contains(_query) || (p.description ?? '').toLowerCase().contains(_query);

      final matchesType = _types.isEmpty || _types.contains(p.category.name);
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

  // ====================== FIRESTORE ======================
  StreamSubscription<List<PointOfInterest>>? _subscription;

  void startListening() {
    if (_subscription != null) return;
    _subscription = FirebaseServices().streamPOIs().listen((list) {
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

  Future<void> deletePlace(String id) async {
    await FirebaseServices().deletePOI(id);
  }
}
