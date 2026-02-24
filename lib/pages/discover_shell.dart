import 'package:flutter/material.dart';
import 'package:traditional_gems/pages/explore_page.dart';
import '../l10n/app_localizations.dart';
import '../widgets/drawers/shared_menu_drawer.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'favorites_page.dart';

class DiscoverShell extends StatefulWidget {
  const DiscoverShell({super.key});

  @override
  State<DiscoverShell> createState() => DiscoverShellState();
}

class DiscoverShellState extends State<DiscoverShell> {
  int index = 0;

  static final List<Widget> _pages = [const DiscoverTraditionalPlacesScreen(), const ExplorePage(), const ExplorePage()];

  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('discover_page')), centerTitle: true, elevation: 5, shadowColor: Colors.black12),
      drawer: const SharedMenuDrawer(isAdmin: false),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.1),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(child: _pages[index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.location_on), label: loc.translate('places')),
          BottomNavigationBarItem(icon: const Icon(Icons.brush), label: loc.translate('artists')),
        ],
      ),
    );
  }
}
