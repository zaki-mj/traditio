import 'package:flutter/material.dart';
import '../widgets/home_page_card.dart';

HomePageCard _homePageCard = HomePageCard();

class DiscoverTraditionalPlacesScreen extends StatelessWidget {
  const DiscoverTraditionalPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Big banner header
          Stack(
            alignment: Alignment.center,
            children: [
              // Background image (replace with your own traditional place image)
              Container(
                width: double.infinity,
                height: 280, // Adjust height as needed
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1549877452-8b0a4d8f3c1e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80', // Example: traditional architecture
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Semi-transparent overlay for better text readability
              Container(width: double.infinity, height: 280, color: Colors.black.withOpacity(0.45)),
              // Text overlay
              const Text(
                'Discover Traditional Places',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black87, offset: Offset(2, 2))],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 2. Featured Artists section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Featured Artists', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240, // Card height + some padding
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6, // Replace with your data length
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: HomePageCard.buildCard(
                          title: 'Artist ${index + 1}',
                          subtitle: 'Traditional Crafts',
                          imageUrl: 'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80', // Placeholder
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Featured Trips section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Featured Trips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: HomePageCard.buildCard(
                          title: 'Trip to ${['Kasbah', 'Medina', 'Oasis', 'Ancient Village', 'Souk'][index]}',
                          subtitle: '3 days • Cultural immersion',
                          imageUrl: 'https://images.unsplash.com/photo-1585208798174-6cedd78e0198?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80', // Placeholder
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40), // Bottom spacing
        ],
      ),
    );
  }
}
