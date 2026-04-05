import 'package:flutter/material.dart';
import 'package:traditional_gems/models/place.dart';
import '../models/journey.dart';

import '../services/firebase_journey_service.dart';

class JourneyProvider extends ChangeNotifier {
  final FirebaseJourneyService _service = FirebaseJourneyService();

  List<Journey> _journeys = [];
  String _searchQuery = '';
  final List<Journey> _all = [];

  List<Journey> get filteredJourneys {
    if (_searchQuery.isEmpty) return _journeys;
    final q = _searchQuery.toLowerCase();
    return _journeys.where((j) => j.nameAR.toLowerCase().contains(q) || j.nameFR.toLowerCase().contains(q)).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void startListening(List<PointOfInterest> allPois) {
    _service.getJourneys(allPois).listen((journeys) {
      _journeys = journeys;
      notifyListeners();
    });
  }

  List<Journey> get allJourneys => List.unmodifiable(_all);

  int get totalJourneys => _journeys.length;

  Future<void> addJourney(Journey journey) async {
    await _service.addJourney(journey);
  }

  Future<void> updateJourney(String id, Journey journey) async {
    await _service.updateJourney(id, journey);
  }

  Future<void> deleteJourney(String id) async {
    await _service.deleteJourney(id);
  }
}
