import 'package:flutter/material.dart';
import 'package:traditional_gems/l10n/app_localizations.dart';
import 'package:traditional_gems/pages/discover_shell.dart';
import '../widgets/home_page_card.dart';

class DiscoverTraditionalPlacesScreen extends StatefulWidget {
  const DiscoverTraditionalPlacesScreen({super.key});

  @override
  State<DiscoverTraditionalPlacesScreen> createState() => _DiscoverTraditionalPlacesScreenState();
}

class _DiscoverTraditionalPlacesScreenState extends State<DiscoverTraditionalPlacesScreen> {
  void _navigateToPlaces() {
    // Find the DiscoverShell and change its index to 1 (Places tab)
    final shellState = context.findAncestorStateOfType<DiscoverShellState>();
    if (shellState != null) {
      shellState.index = 1;
      shellState.updateUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _navigateToPlaces,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(20), child: Image.asset("assets/pictures/discover_banner.jpg")),
            ),
          ),

          const SizedBox(height: 32),

          // 2. Featured Artists section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Featured Artists', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _navigateToPlaces,
                      child: Text(
                        loc.translate('see_all'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Featured Trips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _navigateToPlaces,
                      child: Text(
                        loc.translate('see_all'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
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
