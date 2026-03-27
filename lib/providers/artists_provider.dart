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
    // Add test artists to avoid empty list issues (as you originally had)
    _addTestArtists();
    // Then start listening to Firestore
    startListening();
  }

  void _addTestArtists() {
    // Test data - will be replaced by Firestore data once stream connects
    _all.addAll([
      Artist(
        id: 'test_1',
        wilayaCode: '16',
        wilayaNameAR: 'الجزائر',
        wilayaNameFR: 'Alger',
        cityNameAR: 'الجزائر',
        cityNameFR: 'Alger',
        phone: '+213 555 123 456',
        email: 'ahmed@example.com',
        descriptionFR: 'Artiste traditionnel spécialisé en peinture',
        imageUrls: ['https://via.placeholder.com/400x300?text=Ahmed+Benali'],
        nameAR: '',
        nameFR: '',
      ),
      Artist(
        id: 'test_2',
        wilayaCode: '31',
        wilayaNameAR: 'وهران',
        wilayaNameFR: 'Oran',
        cityNameAR: 'وهران',
        cityNameFR: 'Oran',
        phone: '+213 555 234 567',
        email: 'fatima@example.com',
        descriptionFR: 'Danseuse et chorégraphe traditionnelle',
        imageUrls: ['https://via.placeholder.com/400x300?text=Fatima+Zahra'],
        nameAR: '',
        nameFR: '',
      ),
    ]);
  }

  // ====================== Getters ======================

  List<Artist> get allArtists => List.unmodifiable(_all);

  /// Recommended artists (using recommended flag)
  List<Artist> get recommended {
    final rec = _all.where((a) => a.recommended).toList();

    if (rec.isEmpty) {
      // Fallback: return first 6 artists if none are marked recommended
      final copy = List<Artist>.from(_all);
      // You can change sorting logic if you want (e.g. by createdAt)
      return copy.take(6).toList();
    }

    // Sort recommended artists (you can adjust ordering)
    rec.sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)));
    return rec;
  }

  bool isRecommended(String id) => _all.any((a) => a.id == id && a.recommended);

  List<String> get availableLocations {
    final set = <String>{'All'};
    for (var a in _all) {
      set.add(a.wilayaNameFR);
    }
    return set.toList()..sort();
  }

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

  // ====================== Filter Controls ======================

  void setSearchQuery(String q) {
    _query = q.toLowerCase().trim();
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

  // ====================== Filtered List ======================

  List<Artist> get filteredArtists {
    var list = _all.where((a) {
      // Search query matches name or description
      final matchesQuery = _query.isEmpty || a.nameAR.toLowerCase().contains(_query) || a.nameFR.toLowerCase().contains(_query) || (a.description ?? '').toLowerCase().contains(_query);

      // Location filter by wilaya
      final matchesLocation = _location == 'All' || a.wilayaNameFR == _location;

      return matchesQuery && matchesLocation;
    }).toList();

    // Sort by updatedAt descending (most recent first) - you can change this
    list.sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)));

    return list;
  }

  Artist? byId(String id) {
    try {
      return _all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ====================== Firestore ======================

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
          debugPrint('ArtistsProvider stream error: $e');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Error starting artists listener: $e');
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

  // ====================== CRUD ======================

  /// Delete an artist by id
  Future<void> deleteArtist(String id) async {
    await FirebaseServices().deleteArtist(id);
  }

  /// Toggle recommended status
  Future<void> toggleRecommended(String id) async {
    final artist = _all.firstWhere((a) => a.id == id, orElse: () => throw StateError('Artist not found'));

    final updated = Artist(
      id: artist.id,
      nameAR: artist.nameAR,
      nameFR: artist.nameFR,
      wilayaCode: artist.wilayaCode,
      wilayaNameAR: artist.wilayaNameAR,
      wilayaNameFR: artist.wilayaNameFR,
      cityNameAR: artist.cityNameAR,
      cityNameFR: artist.cityNameFR,
      recommended: !artist.recommended,
      phone: artist.phone,
      email: artist.email,
      imageUrl: artist.imageUrl,
      imageUrls: artist.imageUrls,
      descriptionAR: artist.descriptionAR,
      descriptionFR: artist.descriptionFR,
      descriptionEN: artist.descriptionEN,
      locationLink: artist.locationLink,
      facebookLink: artist.facebookLink,
      instagramLink: artist.instagramLink,
      tiktokLink: artist.tiktokLink,
      createdAt: artist.createdAt,
      updatedAt: DateTime.now(),
    );

    await _svc.updateArtist(updated); // ← Make sure this method exists in FirebaseServices
  }
}
