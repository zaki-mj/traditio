import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:traditional_gems/services/firebase_services.dart';
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

  FirebaseServices firebaseServices = FirebaseServices();

  static final List<Widget> _pages = [const AdminDashboardPage(), const AdminListPage()];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_index == 0 ? loc.translate('dashboard') : loc.translate('places')), centerTitle: true),
      drawer: SharedMenuDrawer(
        isAdmin: true,
        onLogout: () {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).pushReplacementNamed('/'); // Return to welcome
        },
      ),
      body: SafeArea(child: _pages[_index]),
      // Use a sized FAB so the notch matches its diameter
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaceFormPage()));
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: BottomAppBar(
                color: Colors.transparent,
                notchMargin: 10,
                shape: const CircularNotchedRectangle(),
                elevation: 0,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      // Dashboard item
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _index = 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.dashboard, color: _index == 0 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(height: 4),
                              Text(loc.translate('dashboard'), style: TextStyle(fontSize: 12, color: _index == 0 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                      ),

                      // Spacer for FAB notch (center)
                      const SizedBox(width: 8),

                      // Places item
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _index = 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list, color: _index == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(height: 4),
                              Text(loc.translate('places'), style: TextStyle(fontSize: 12, color: _index == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
