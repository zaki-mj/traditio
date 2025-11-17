import 'package:flutter/material.dart';
import '../models/place.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, favs, _) {
              final isFav = favs.isFavorite(place.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => favs.toggle(place.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'place_image_${place.id}',
              child: Image.network(
                place.imageUrl,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(height: 220, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(place.location),
                      const SizedBox(width: 10),
                      Chip(label: Text(place.type)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rating: ${place.rating}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(place.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
