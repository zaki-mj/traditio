import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traditional_gems/models/place.dart';
import '../models/journey.dart';

class FirebaseJourneyService {
  final CollectionReference _journeysCollection = FirebaseFirestore.instance.collection('journeys');

  Future<void> addJourney(Journey journey) async {
    await _journeysCollection.add(journey.toMap());
  }

  Future<void> updateJourney(String id, Journey journey) async {
    await _journeysCollection.doc(id).update(journey.toMap());
  }

  Future<void> deleteJourney(String id) async {
    await _journeysCollection.doc(id).delete();
  }

  Stream<List<Journey>> getJourneys(List<PointOfInterest> allPois) {
    return _journeysCollection.orderBy('created_at', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Journey.fromMap(doc.data() as Map<String, dynamic>, doc.id, allPois)).toList());
  }
}
