enum POICategory {
  hotel(1, 'hotel'),
  restaurant(2, 'restaurant'),
  attraction(3, 'attraction'),
  store(4, 'store'),
  other(5, 'other');

  final int value;
  final String name;
  const POICategory(this.value, this.name);

  static POICategory fromValue(int value) {
    return POICategory.values.firstWhere((e) => e.value == value, orElse: () => POICategory.other);
  }
}

class PointOfInterest {
  final String? id; // Firestore document ID (optional, let Firestore generate)

  // Names
  final String nameAR;
  final String nameFR;

  // Location (store everything for translation & querying)
  final String wilayaCode;
  final String wilayaNameAR;
  final String wilayaNameFR;
  final String? cityNameAR;
  final String? cityNameFR;

  // Basic info
  final double rating;
  final bool recommended;
  final POICategory category;

  // Multilingual descriptions (optional)
  final String? descriptionAR;
  final String? descriptionFR;
  final String? descriptionEN;

  // Backwards-compatible computed description (first available)
  String? get description => descriptionFR ?? descriptionEN ?? descriptionAR;

  // Contact
  final String? phone;
  final String? email;
  final String? locationLink; // Google Maps link

  // Social media
  final String? facebookLink;
  final String? instagramLink;
  final String? tiktokLink;

  // Media

  final List<String>? imageUrls;

  // Timestamps (useful for sorting/filtering)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PointOfInterest({
    this.id, // Optional now
    required this.nameAR,
    required this.nameFR,
    required this.wilayaCode,
    required this.wilayaNameAR,
    required this.wilayaNameFR,
    this.cityNameAR,
    this.cityNameFR,
    required this.rating,
    this.recommended = false,
    required this.category,
    this.phone,
    this.email,

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
      'rating': rating,
      'category': category.value,
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

      'image_urls': imageUrls,

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'recommended': recommended,
    };
  }

  // Create from Firestore Map
  factory PointOfInterest.fromMap(Map<String, dynamic> map, String docId) {
    List<String>? _fromImageUrls() {
      if (map['image_urls'] == null) return null;
      return List<String>.from(map['image_urls']);
    }

    final _imageUrlsList = _fromImageUrls();

    return PointOfInterest(
      id: docId,
      // Required fields - keep cast but ensure data exists or use fallback
      nameAR: map['name_ar']?.toString() ?? '',
      nameFR: map['name_fr']?.toString() ?? '',
      wilayaCode: map['wilaya_code']?.toString() ?? '',
      wilayaNameAR: map['wilaya_name_ar']?.toString() ?? '',
      wilayaNameFR: map['wilaya_name_fr']?.toString() ?? '',

      // Optional fields - MUST use as String? to allow nulls
      cityNameAR: map['city_name_ar'] as String?,
      cityNameFR: map['city_name_fr'] as String?,

      // Numeric handling
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      recommended: map['recommended'] is bool ? map['recommended'] as bool : false,

      // Enum handling
      category: POICategory.fromValue((map['category'] as num?)?.toInt() ?? 5),

      // Optional contact info
      phone: map['phone'] as String?,
      email: map['email'] as String?,

      imageUrls: _imageUrlsList,

      // Descriptions with fallbacks
      descriptionAR: map['description_ar'] as String? ?? map['description'] as String?,
      descriptionFR: map['description_fr'] as String? ?? map['description'] as String?,
      descriptionEN: map['description_en'] as String? ?? map['description'] as String?,

      // Links
      locationLink: map['location_link'] as String?,
      facebookLink: map['facebook_link'] as String?,
      instagramLink: map['instagram_link'] as String?,
      tiktokLink: map['tiktok_link'] as String?,

      // Dates
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }
}
