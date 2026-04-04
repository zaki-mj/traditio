import 'package:traditional_gems/models/place.dart';

class Journey {
  final String? id;
  final String nameAR;
  final String nameFR;
  final String descriptionAR;
  final String descriptionFR;
  final String descriptionEN;
  final List<PointOfInterest> pois; // Embedded POIs for easy display

  Journey({this.id, required this.nameAR, required this.nameFR, required this.descriptionAR, required this.descriptionFR, required this.descriptionEN, required this.pois});

  Map<String, dynamic> toMap() {
    return {
      'name_ar': nameAR.trim(),
      'name_fr': nameFR.trim(),
      'description_ar': descriptionAR.trim(),
      'description_fr': descriptionFR.trim(),
      'description_en': descriptionEN.trim(),
      'poi_ids': pois.map((p) => p.id).where((id) => id != null).toList(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory Journey.fromMap(Map<String, dynamic> map, String id, List<PointOfInterest> allPois) {
    final poiIds = List<String>.from(map['poi_ids'] ?? []);
    final selectedPois = allPois.where((p) => poiIds.contains(p.id)).toList();

    return Journey(id: id, nameAR: map['name_ar'] ?? '', nameFR: map['name_fr'] ?? '', descriptionAR: map['description_ar'] ?? '', descriptionFR: map['description_fr'] ?? '', descriptionEN: map['description_en'] ?? '', pois: selectedPois);
  }
}
