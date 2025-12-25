class Place {
  final String id;
  final String name;
  final String description;
  final String type; // e.g. hotel, restaurant, attraction
  final String location; // city or area
  final String imageUrl;
  final double rating;
  final bool recommended;
  final String? phone;
  final String? email;
  final String? address;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;

  const Place({required this.id, required this.name, required this.description, required this.type, required this.location, required this.imageUrl, required this.rating, this.recommended = false, this.phone, this.email, this.address, this.facebookUrl, this.instagramUrl, this.twitterUrl});
}

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
  final String cityNameAR;
  final String cityNameFR;

  // Basic info
  final double rating;
  final bool recommended;
  final POICategory category;
  final String? description;

  // Contact
  final String phone;
  final String email;
  final String? locationLink; // Google Maps link

  // Social media
  final String? facebookLink;
  final String? instagramLink;
  final String? tiktokLink;

  // Media
  final List<String> imageUrls;

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
    required this.cityNameAR,
    required this.cityNameFR,
    required this.rating,
    this.recommended = false,
    required this.category,
    required this.phone,
    required this.email,
    this.imageUrls = const [],
    this.description,
    this.locationLink,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    this.createdAt,
    this.updatedAt,
  });

  PointOfInterest copyWith({
    String? id,
    String? nameAR,
    String? nameFR,
    String? wilayaCode,
    String? wilayaNameAR,
    String? wilayaNameFR,
    String? cityNameAR,
    String? cityNameFR,
    double? rating,
    bool? recommended,
    POICategory? category,
    String? phone,
    String? email,
    List<String>? imageUrls,
    String? description,
    String? locationLink,
    String? facebookLink,
    String? instagramLink,
    String? tiktokLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PointOfInterest(
      id: id ?? this.id,
      nameAR: nameAR ?? this.nameAR,
      nameFR: nameFR ?? this.nameFR,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      wilayaNameAR: wilayaNameAR ?? this.wilayaNameAR,
      wilayaNameFR: wilayaNameFR ?? this.wilayaNameFR,
      cityNameAR: cityNameAR ?? this.cityNameAR,
      cityNameFR: cityNameFR ?? this.cityNameFR,
      rating: rating ?? this.rating,
      recommended: recommended ?? this.recommended,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      locationLink: locationLink ?? this.locationLink,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      'description': description,
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
    List<String> images = [];
    if (map['image_urls'] != null && map['image_urls'] is List) {
      images = List<String>.from(map['image_urls']);
    } else if (map['image_url'] != null && map['image_url'] is String) {
      images = [map['image_url']];
    }

    return PointOfInterest(
      id: docId, // Get ID from document reference
      nameAR: map['name_ar'] as String,
      nameFR: map['name_fr'] as String,
      wilayaCode: map['wilaya_code'] as String,
      wilayaNameAR: map['wilaya_name_ar'] as String,
      wilayaNameFR: map['wilaya_name_fr'] as String,
      cityNameAR: map['city_name_ar'] as String,
      cityNameFR: map['city_name_fr'] as String,
      rating: (map['rating'] as num).toDouble(),
      recommended: map['recommended'] as bool? ?? false,
      category: POICategory.fromValue(map['category'] as int),
      phone: map['phone'] as String,
      email: map['email'] as String,
      imageUrls: images,
      description: map['description'] as String?,
      locationLink: map['location_link'] as String?,
      facebookLink: map['facebook_link'] as String?,
      instagramLink: map['instagram_link'] as String?,
      tiktokLink: map['tiktok_link'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }
}
