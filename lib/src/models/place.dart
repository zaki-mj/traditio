class Place {
  final String id;
  final String name;
  final String description;
  final String type; // e.g. hotel, restaurant, attraction
  final String location; // city or area
  final String imageUrl;
  final double rating;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.location,
    required this.imageUrl,
    required this.rating,
  });
}
