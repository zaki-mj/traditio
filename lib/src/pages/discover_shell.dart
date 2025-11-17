import 'package:flutter/material.dart';
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

  static final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
