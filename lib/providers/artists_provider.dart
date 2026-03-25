import 'dart:async';

import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../services/firebase_services.dart';

class ArtistsProvider extends ChangeNotifier {
  ArtistsProvider() {
    _initialize();
  }

  final List<Artist> _all = [];

  String _query = '';
  String _location = 'All';

  void _initialize() {
    // Add test artists to avoid empty list issues
    _addTestArtists();
    // Then start listening to Firestore for real updates
    startListening();
  }

  void _addTestArtists() {
    // Test data - will be replaced by Firestore data once stream connects
    _all.addAll([
      Artist(
        id: 'test_1',
        name: 'Ahmed Benali',
        wilayaCode: '16',
        wilayaNameAR: 'الجزائر',
        wilayaNameFR: 'Alger',
        cityNameAR: 'الجزائر',
        cityNameFR: 'Alger',
        phone: '+213 555 123 456',
        email: 'ahmed@example.com',
        descriptionFR: 'Artiste traditionnel spécialisé en peinture',
        imageUrls: ['https://via.placeholder.com/400x300?text=Ahmed+Benali'],
      ),
      Artist(
        id: 'test_2',
        name: 'Fatima Zahra',
        wilayaCode: '31',
        wilayaNameAR: 'وهران',
        wilayaNameFR: 'Oran',
        cityNameAR: 'وهران',
        cityNameFR: 'Oran',
        phone: '+213 555 234 567',
        email: 'fatima@example.com',
        descriptionFR: 'Danseuse et chorégraphe traditionnelle',
        imageUrls: ['https://via.placeholder.com/400x300?text=Fatima+Zahra'],
      ),
    ]);
  }

  List<Artist> get allArtists => List.unmodifiable(_all);

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var a in _all) {
      set.add(a.wilayaNameFR);
    }
    return set.toList()..sort();
  }

  // Get wilaya name in the specified language
  String getWilayaName(String wilayaNameFR, String languageCode) {
    if (languageCode == 'ar') {
      try {
        final artist = _all.firstWhere((a) => a.wilayaNameFR == wilayaNameFR);
        return artist.wilayaNameAR;
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

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  String get currentLocation => _location;
  String get searchQuery => _query;

  bool get hasActiveFilters => _query.isNotEmpty || _location != 'All';

  void clearFilters() {
    _query = '';
    _location = 'All';
    notifyListeners();
  }

  List<Artist> get filteredArtists {
    var list = _all.where((a) {
      // Search query matches name or description
      final matchesQuery = _query.isEmpty || a.name.toLowerCase().contains(_query) || (a.description ?? '').toLowerCase().contains(_query);

      // Location filter by wilaya
      final matchesLocation = _location == 'All' || a.wilayaNameFR == _location;

      return matchesQuery && matchesLocation;
    }).toList();
    return list;
  }

  Artist? byId(String id) {
    try {
      return _all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Firestore subscription
  StreamSubscription<List<Artist>>? _subscription;
  final FirebaseServices _svc = FirebaseServices();

  void startListening() {
    if (_subscription != null) return;
    try {
      _subscription = _svc.streamArtists().listen(
        (list) {
          _all
            ..clear()
            ..addAll(list);
          notifyListeners();
        },
        onError: (e) {
          print('ArtistsProvider stream error: $e');
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error starting artists listener: $e');
    }
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

  /// Delete an artist by id
  Future<void> deleteArtist(String id) async {
    await FirebaseServices().deleteArtist(id);
  }
}
