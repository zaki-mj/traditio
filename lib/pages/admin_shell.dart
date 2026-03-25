import 'package:flutter/material.dart';
import 'package:traditional_gems/services/firebase_services.dart';
import '../l10n/app_localizations.dart';
import '../widgets/drawers/shared_menu_drawer.dart';
import 'admin_dashboard_page.dart';
import 'admin_list_page.dart';
import 'place_form_page.dart';
import 'artist_form_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

  final FirebaseServices _firebase = FirebaseServices();

  final List<Widget> _pages = const [AdminDashboardPage(), AdminListPage()];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() => _isFabExpanded = !_isFabExpanded);
    if (_isFabExpanded) {
      _animationController?.forward();
    } else {
      _animationController?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_selectedIndex == 0 ? loc.translate('dashboard') : loc.translate('places')), centerTitle: true),
      drawer: SharedMenuDrawer(
        isAdmin: true,
        onLogout: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
        ),
        child: _pages[_selectedIndex],
      ),

      // FAB + actions
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -24), // ← raise higher into notch (adjust as needed)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expanded action buttons
            if (_isFabExpanded)
              FadeTransition(
                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(0),
                child: ScaleTransition(
                  scale: _scaleAnimation ?? const AlwaysStoppedAnimation(1),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Material(
                      elevation: 6,
                      shape: const StadiumBorder(),
                      color: theme.colorScheme.surface.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionButton(
                              icon: Icons.place,
                              onTap: () {
                                _toggleFabMenu();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceFormPage()));
                              },
                            ),
                            const SizedBox(width: 24),
                            _ActionButton(
                              icon: Icons.brush,
                              onTap: () {
                                _toggleFabMenu();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtistFormPage()));
                              },
                            ),
                            const SizedBox(width: 24),
                            _ActionButton(
                              icon: Icons.list,
                              onTap: () {
                                _toggleFabMenu();
                                setState(() => _selectedIndex = 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Main FAB
            FloatingActionButton(
              elevation: 8,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              onPressed: _toggleFabMenu,
              shape: const CircleBorder(),
              child: AnimatedRotation(turns: _isFabExpanded ? 0.125 : 0, duration: const Duration(milliseconds: 320), child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 32)),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        notchMargin: -16, // deeper notch — tune between -10 and -20
        shape: const CircularNotchedRectangle(),
        elevation: 12,
        shadowColor: Colors.black38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(icon: Icons.dashboard, label: loc.translate('dashboard'), isSelected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0)),
            const SizedBox(width: 80), // space for FAB
            _NavItem(icon: Icons.list, label: loc.translate('places'), isSelected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(mini: false, heroTag: null, onPressed: onTap, child: Icon(icon, size: 30));
  }
}
