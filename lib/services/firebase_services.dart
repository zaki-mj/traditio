import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String collectionName = 'places';

  Future<void> addDummyData(Dummy dummy) async {
    await _firestore.collection(collectionName).add(dummy.toMap());
  }
}
