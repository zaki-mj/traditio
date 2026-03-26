class Artist {
  final String? id; // Firestore document ID (optional, let Firestore generate)

  // Names
  final String nameAR;
  final String nameFR;

  // Location (store everything for translation & querying)
  final String wilayaCode;
  final String wilayaNameAR;
  final String wilayaNameFR;
  final String cityNameAR;
  final String cityNameFR;

  final bool recommended;

  // Multilingual descriptions (optional)
  final String? descriptionAR;
  final String? descriptionFR;
  final String? descriptionEN;

  // Backwards-compatible computed description (first available)
  String? get description => descriptionFR ?? descriptionEN ?? descriptionAR;

  // Contact
  final String phone;
  final String email;
  final String? locationLink; // Google Maps link

  // Social media
  final String? facebookLink;
  final String? instagramLink;
  final String? tiktokLink;

  // Media
  final String? imageUrl;
  final List<String>? imageUrls;

  // Timestamps (useful for sorting/filtering)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Artist({
    this.id, // Optional now
    required this.nameAR,
    required this.nameFR,
    required this.wilayaCode,
    required this.wilayaNameAR,
    required this.wilayaNameFR,
    required this.cityNameAR,
    required this.cityNameFR,
    this.recommended = false,
    required this.phone,
    required this.email,
    this.imageUrl,
    this.imageUrls,
    this.descriptionAR,
    this.descriptionFR,
    this.descriptionEN,
    this.locationLink,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    this.createdAt,
    this.updatedAt,
  });

  // Validate rating bounds
  // (ensures rating is within 0..5 at construction time)
  // Note: this assert runs in debug mode.

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name_ar': nameAR,
      'name_fr': nameFR,
      'wilaya_code': wilayaCode,
      'wilaya_name_ar': wilayaNameAR,
      'wilaya_name_fr': wilayaNameFR,
      'city_name_ar': cityNameAR,
      'city_name_fr': cityNameFR,

      // Write multilingual descriptions and keep legacy 'description' for compatibility
      'description_ar': descriptionAR,
      'description_fr': descriptionFR,
      'description_en': descriptionEN,
      'description': descriptionFR ?? descriptionEN ?? descriptionAR,
      'phone': phone,
      'email': email,
      'location_link': locationLink,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'tiktok_link': tiktokLink,
      'image_url': imageUrl,
      'image_urls': imageUrls,

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'recommended': recommended,
    };
  }

  // Create from Firestore Map
  factory Artist.fromMap(Map<String, dynamic> map, String docId) {
    // Helper: load up to 6 image links from explicit keys or fallback to image_urls list
    String? _safeString(Map m, String k) => m[k] as String?;

    List<String>? _fromImageUrls() => map['image_urls'] != null ? List<String>.from(map['image_urls']) : null;

    final _imageUrlsList = _fromImageUrls();

    String? _linkAt(int idx) {
      final key = 'image_link_\$idx';
      // try explicit key
      final val = map[key];
      if (val != null) return val as String;
      // fallback to image_urls list
      if (_imageUrlsList != null && _imageUrlsList.length > idx) return _imageUrlsList[idx];
      return null;
    }

    return Artist(
      id: docId, // Get ID from document reference
      nameAR: map['name_ar'] as String,
      nameFR: map['name_fr'] as String,
      wilayaCode: map['wilaya_code'] as String,
      wilayaNameAR: map['wilaya_name_ar'] as String,
      wilayaNameFR: map['wilaya_name_fr'] as String,
      cityNameAR: map['city_name_ar'] as String,
      cityNameFR: map['city_name_fr'] as String,

      recommended: map['recommended'] == null ? false : (map['recommended'] as bool),

      phone: map['phone'] as String,
      email: map['email'] as String,
      imageUrl: map['image_url'] as String?,
      imageUrls: _imageUrlsList,
      descriptionAR: map['description_ar'] as String? ?? map['description'] as String?,
      descriptionFR: map['description_fr'] as String? ?? map['description'] as String?,
      descriptionEN: map['description_en'] as String? ?? map['description'] as String?,
      locationLink: map['location_link'] as String?,
      facebookLink: map['facebook_link'] as String?,
      instagramLink: map['instagram_link'] as String?,
      tiktokLink: map['tiktok_link'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }
}
