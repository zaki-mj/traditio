import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/place.dart';
import '../models/artist.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String poiCollection = 'points_of_interest';
  final String artistCollection = 'artists';

  // ====================== POI ======================

  Future<DocumentReference> createPOI(PointOfInterest poi) async {
    final map = poi.toMap();
    return await _firestore.collection(poiCollection).add(map);
  }

  Future<void> updatePOI(PointOfInterest poi) async {
    if (poi.id == null) throw ArgumentError('POI id is required to update');

    final map = poi.toMap();

    // CRITICAL FIX: Always send imageUrls as list (never null) on update
    if (map['image_urls'] == null) {
      map['image_urls'] = <String>[];
    }

    await _firestore.collection(poiCollection).doc(poi.id).update(map);
  }

  Stream<List<PointOfInterest>> streamPOIs() {
    return _firestore.collection(poiCollection).snapshots().map((snap) {
      return snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList();
    });
  }

  Stream<List<PointOfInterest>> streamRecommendedPOIs() {
    return _firestore.collection(poiCollection).where('recommended', isEqualTo: true).snapshots().map((snap) => snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList());
  }

  Stream<PointOfInterest?> streamPOIById(String id) {
    return _firestore.collection(poiCollection).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PointOfInterest.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> deletePOI(String id) async {
    await _firestore.collection(poiCollection).doc(id).delete();
  }

  // ====================== ARTIST ======================

  Future<DocumentReference> createArtist(Artist artist) async {
    final map = artist.toMap();
    return await _firestore.collection(artistCollection).add(map);
  }

  Future<void> updateArtist(Artist artist) async {
    if (artist.id == null) throw ArgumentError('Artist id is required to update');

    final map = artist.toMap();

    // CRITICAL FIX: Always send imageUrls / images as list (never null) on update
    if (map.containsKey('imageUrls') && map['imageUrls'] == null) {
      map['imageUrls'] = <String>[];
    }
    if (map.containsKey('images') && map['images'] == null) {
      map['images'] = <String>[];
    }

    await _firestore.collection(artistCollection).doc(artist.id).update(map);
  }

  Stream<List<Artist>> streamArtists() {
    return _firestore.collection(artistCollection).snapshots().map((snap) {
      return snap.docs.map((d) => Artist.fromMap(d.data(), d.id)).toList();
    });
  }

  Stream<Artist?> streamArtistById(String id) {
    return _firestore.collection(artistCollection).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Artist.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<Artist>> streamRecommendedArtists() {
    return _firestore.collection(artistCollection).where('recommended', isEqualTo: true).snapshots().map((snap) => snap.docs.map((d) => Artist.fromMap(d.data(), d.id)).toList());
  }

  Future<void> deleteArtist(String id) async {
    await _firestore.collection(artistCollection).doc(id).delete();
  }
}
