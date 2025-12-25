import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/place.dart';
import 'image_services.dart';

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
  final ImageService _imageService = ImageService();
  final String poiCollection = 'points_of_interest';

  Future<DocumentReference> createPOI(PointOfInterest poi, {List<XFile>? images}) async {
    final poiData = poi.toMap();
    final docRef = await _firestore.collection(poiCollection).add(poiData);
    if (images != null && images.isNotEmpty) {
      final imageUrls = await _imageService.uploadImages(images, docRef.id);
      await docRef.update({'image_urls': imageUrls});
    }
    return docRef;
  }

  Stream<List<PointOfInterest>> streamPOIs() {
    return _firestore.collection(poiCollection).snapshots().map((snap) {
      return snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList();
    });
  }

  Stream<List<PointOfInterest>> streamRecommendedPOIs() {
    return _firestore.collection(poiCollection).where('recommended', isEqualTo: true).snapshots().map((snap) {
      return snap.docs.map((d) => PointOfInterest.fromMap(d.data(), d.id)).toList();
    });
  }

  Stream<PointOfInterest?> streamPOIById(String id) {
    return _firestore.collection(poiCollection).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PointOfInterest.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> updatePOI(PointOfInterest poi, {List<XFile>? newImages, List<String>? removedImageUrls}) async {
    if (poi.id == null) throw ArgumentError('POI id is required to update');

    // Handle image deletions
    if (removedImageUrls != null && removedImageUrls.isNotEmpty) {
      await _imageService.deleteImages(removedImageUrls);
    }

    List<String> finalImageUrls = List.from(poi.imageUrls);

    // Handle image additions
    if (newImages != null && newImages.isNotEmpty) {
      final newImageUrls = await _imageService.uploadImages(newImages, poi.id!);
      finalImageUrls.addAll(newImageUrls);
    }

    final updatedPoi = poi.copyWith(imageUrls: finalImageUrls, updatedAt: DateTime.now());

    await _firestore.collection(poiCollection).doc(poi.id).update(updatedPoi.toMap());
  }

  Future<void> deletePOI(PointOfInterest poi) async {
    if (poi.id == null) return;
    await _imageService.deleteImages(poi.imageUrls);
    await _firestore.collection(poiCollection).doc(poi.id).delete();
  }

  Future<void> addDummyData(Dummy dummy) async {
    await _firestore.collection('places').add(dummy.toMap());
  }
}
