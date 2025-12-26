import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/place.dart';

class Dummy {
  final String name;
  final String place;
  final double? rating;

  const Dummy({required this.name, required this.place, this.rating});

  Map<String, dynamic> toMap() {
    return {'name': name, 'place': place, 'rating': rating};
  }
}

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Collection name for PointOfInterest records. Keep this centralized.
  final String poiCollection = 'points_of_interest';

  /// Create a new Point of Interest in Firestore.
  Future<DocumentReference> createPOI(PointOfInterest poi) async {
    final map = poi.toMap();
    return await _firestore.collection(poiCollection).add(map);
  }

  /// Stream all POIs as a list. Useful for providing to UI via provider/streambuilder.
  Stream<List<PointOfInterest>> streamPOIs() {
    return _firestore.collection(poiCollection).snapshots().map((snap) {
      return snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList();
    });
  }

  /// Stream only POIs that are marked as recommended.
  Stream<List<PointOfInterest>> streamRecommendedPOIs() {
    return _firestore.collection(poiCollection).where('recommended', isEqualTo: true).snapshots().map((snap) {
      return snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList();
    });
  }

  /// Get a single POI stream by id
  Stream<PointOfInterest?> streamPOIById(String id) {
    return _firestore.collection(poiCollection).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PointOfInterest.fromMap(doc.data()!, doc.id);
    });
  }

  /// Update an existing POI (requires poi.id to be non-null)
  Future<void> updatePOI(PointOfInterest poi) async {
    if (poi.id == null) throw ArgumentError('POI id is required to update');
    final map = poi.toMap();
    await _firestore.collection(poiCollection).doc(poi.id).update(map);
  }

  /// Delete a POI by id
  Future<void> deletePOI(String id) async {
    await _firestore.collection(poiCollection).doc(id).delete();
  }

  /// Backwards-compat helper: add the simple Dummy type to a default collection
  Future<void> addDummyData(Dummy dummy) async {
    await _firestore.collection('places').add(dummy.toMap());
  }
}
