class Place {
  final String id;
  final String name;
  final String description;
  final String type; // e.g. hotel, restaurant, attraction
  final String location; // city or area
  final String imageUrl;
  final double rating;
  final String? phone;
  final String? email;
  final String? address;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;

  const Place({required this.id, required this.name, required this.description, required this.type, required this.location, required this.imageUrl, required this.rating, this.phone, this.email, this.address, this.facebookUrl, this.instagramUrl, this.twitterUrl});
}

enum POICategory {
  hotel(1, 'hotel'),
  restaurant(2, 'restaurant'),
  amusement(3, 'amusement'),
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
  final String imageUrl;

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
    required this.category,
    required this.phone,
    required this.email,
    required this.imageUrl,
    this.description,
    this.locationLink,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    this.createdAt,
    this.updatedAt,
  });

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
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory PointOfInterest.fromMap(Map<String, dynamic> map, String docId) {
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
      category: POICategory.fromValue(map['category'] as int),
      phone: map['phone'] as String,
      email: map['email'] as String,
      imageUrl: map['image_url'] as String,
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
