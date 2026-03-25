class Artist {
  final String? id; // Firestore document ID

  // Names
  final String name;

  // Location (store everything for translation & querying)
  final String wilayaCode;
  final String wilayaNameAR;
  final String wilayaNameFR;
  final String cityNameAR;
  final String cityNameFR;

  // Contact
  final String phone;
  final String email;

  // Multilingual descriptions
  final String? descriptionAR;
  final String? descriptionFR;
  final String? descriptionEN;

  // Backwards-compatible computed description (first available)
  String? get description => descriptionFR ?? descriptionEN ?? descriptionAR;

  // Media
  final List<String>? imageUrls; // Up to 6 images

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Artist({
    this.id,
    required this.name,
    required this.wilayaCode,
    required this.wilayaNameAR,
    required this.wilayaNameFR,
    required this.cityNameAR,
    required this.cityNameFR,
    required this.phone,
    required this.email,
    this.descriptionAR,
    this.descriptionFR,
    this.descriptionEN,
    this.imageUrls,

    this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'wilaya_code': wilayaCode,
      'wilaya_name_ar': wilayaNameAR,
      'wilaya_name_fr': wilayaNameFR,
      'city_name_ar': cityNameAR,
      'city_name_fr': cityNameFR,
      'phone': phone,
      'email': email,
      'description_ar': descriptionAR,
      'description_fr': descriptionFR,
      'description_en': descriptionEN,
      'description': descriptionFR ?? descriptionEN ?? descriptionAR,
      'image_urls': imageUrls,

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory Artist.fromMap(Map<String, dynamic> map, String docId) {
    List<String>? _fromImageUrls() => map['image_urls'] != null ? List<String>.from(map['image_urls']) : null;

    final _imageUrlsList = _fromImageUrls();

    return Artist(
      id: docId,
      name: map['name'] as String,
      wilayaCode: map['wilaya_code'] as String,
      wilayaNameAR: map['wilaya_name_ar'] as String,
      wilayaNameFR: map['wilaya_name_fr'] as String,
      cityNameAR: map['city_name_ar'] as String,
      cityNameFR: map['city_name_fr'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      descriptionAR: map['description_ar'] as String?,
      descriptionFR: map['description_fr'] as String?,
      descriptionEN: map['description_en'] as String?,
      imageUrls: _imageUrlsList,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }
}
