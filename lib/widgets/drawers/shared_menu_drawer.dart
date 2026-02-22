import 'package:flutter/material.dart';
import 'package:traditional_gems/pages/favorites_page.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../pages/about_page.dart';

class SharedMenuDrawer extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onLogout;

  const SharedMenuDrawer({super.key, this.isAdmin = false, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(180)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  isAdmin ? loc.translate('admin_panel') : loc.translate('guest'),
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.primary),
                  title: Text(loc.translate('settings')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: AppColors.primary),
                  title: Text(loc.translate('favorites')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: Text(loc.translate('about_us')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage()));
                  },
                ),
              ],
            ),
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(loc.translate('logout')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: onLogout ?? () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
