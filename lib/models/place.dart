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

class PointOfInterest {
  final String nameAR;
  final String nameFR;
  final int stateCode;
  final int cityFr;
  final double rating;
  final int category; // (1=hotel, 2=restaurant, 3=ammusement, 4=store, 5=other, -1=null)
  final String? description;

  final String phone;
  final String email;
  final String? locationLink; //(from Google maps)

  final String? facebookLink;
  final String? instagramLink;
  final String? tiktokLink;

  final String imageUrl;

  const PointOfInterest({
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.phone,
    required this.email,
    required this.nameAR,
    required this.nameFR,
    required this.stateCode,
    required this.cityFr,
    this.locationLink,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
  });
}
