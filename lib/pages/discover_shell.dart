import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/drawers/shared_menu_drawer.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'favorites_page.dart';

class DiscoverShell extends StatefulWidget {
  const DiscoverShell({super.key});

  @override
  State<DiscoverShell> createState() => _DiscoverShellState();
}

class _DiscoverShellState extends State<DiscoverShell> {
  int _index = 0;

  static final List<Widget> _pages = [const HomePage(), const CategoriesPage(), const FavoritesPage()];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('discover_page')), centerTitle: true),
      drawer: const SharedMenuDrawer(isAdmin: false),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(child: _pages[_index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.category), label: loc.translate('categories')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: loc.translate('favorites')),
        ],
      ),
    );
  }
}
