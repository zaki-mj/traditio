import 'package:flutter/material.dart';
import 'package:traditional_gems/services/firebase_services.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/drawers/shared_menu_drawer.dart';
import 'admin_dashboard_page.dart';
import 'admin_list_page.dart';
import '../place_form_page.dart';
import '../artist_form_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  final FirebaseServices _firebase = FirebaseServices();

  final List<Widget> _pages = const [AdminDashboardPage(), AdminListPage()];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() => _isFabExpanded = !_isFabExpanded);
    if (_isFabExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
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
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/pictures/bg2.png"), fit: BoxFit.cover, opacity: 0.2),
            ),
            child: _pages[_selectedIndex],
          ),

          // Background dim when menu is open
          if (_isFabExpanded)
            GestureDetector(
              onTap: _toggleFabMenu,
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),

          // Expandable Action Menu
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(scale: _scaleAnimation, alignment: Alignment.bottomCenter, child: child),
              );
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                // Responsive padding: above FAB + safe area
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 40),
                child: Material(
                  elevation: 8,
                  shape: const StadiumBorder(),
                  color: theme.colorScheme.surface.withOpacity(0.98),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: Icons.place,
                          label: loc.translate('new_place') ?? 'New Place',
                          color: const Color(0xFF3B7DD8),
                          onTap: () {
                            _toggleFabMenu();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaceFormPage()));
                          },
                        ),
                        const SizedBox(width: 28),
                        _ActionButton(
                          icon: Icons.brush,
                          label: loc.translate('artists') ?? 'Artists',
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            _toggleFabMenu();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArtistFormPage()));
                          },
                        ),
                        const SizedBox(width: 28),
                        _ActionButton(
                          icon: Icons.list,
                          label: loc.translate('view_places') ?? 'View Places',
                          color: const Color(0xFF0D9488),
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
        ],
      ),

      // Main FAB
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: _toggleFabMenu,
        shape: const CircleBorder(),
        child: AnimatedRotation(turns: _isFabExpanded ? 0.125 : 0, duration: const Duration(milliseconds: 280), child: const Icon(Icons.add, size: 30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        elevation: 12,
        shadowColor: Colors.black38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.dashboard,
              label: loc.translate('dashboard'),
              isSelected: _selectedIndex == 0,
              onTap: () {
                if (_isFabExpanded) _toggleFabMenu();
                setState(() => _selectedIndex = 0);
              },
            ),
            const SizedBox(width: 80),
            _NavItem(
              icon: Icons.list,
              label: loc.translate('places'),
              isSelected: _selectedIndex == 1,
              onTap: () {
                if (_isFabExpanded) _toggleFabMenu();
                setState(() => _selectedIndex = 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Nav Item (unchanged)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.55);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Button with better hit testing
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Important for reliable taps
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
