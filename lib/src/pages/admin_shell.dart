import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/drawers/shared_menu_drawer.dart';
import 'admin_dashboard_page.dart';
import 'admin_list_page.dart';
import 'place_form_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _index == 0 ? loc.translate('dashboard') : loc.translate('places'),
        ),
        centerTitle: true,
      ),
      drawer: SharedMenuDrawer(
        isAdmin: true,
        onLogout: () {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).pushReplacementNamed('/'); // Return to welcome
        },
      ),
      body: SafeArea(child: _pages[_index]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PlaceFormPage()));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: loc.translate('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: loc.translate('places'),
            ),
          ],
        ),
      ),
    );
  }
}
