import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/pictures/bg.png"), fit: BoxFit.cover, opacity: 10),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.secondary]),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 120),
                // Logo / Icon
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),

                      color: const Color.fromARGB(0, 182, 34, 34),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 20, offset: const Offset(0, 5))],
                    ),
                    child: Image.asset('assets/pictures/logo.png', scale: 3),
                  ),
                ),
                const SizedBox(height: 40),
                // Welcome text
                Center(
                  child: Text(
                    loc.translate('welcome'),
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Center(
                  child: Text(
                    loc.translate('welcome_description'),
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withAlpha(200)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                // Buttons
                _buildButton(context, label: loc.translate('start_discovering'), onPressed: () => Navigator.of(context).pushNamed('/discover'), isPrimary: true),
                const SizedBox(height: 12),
                _buildButton(context, label: loc.translate('admin_login'), onPressed: () => Navigator.of(context).pushNamed('/admin'), isPrimary: false),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required VoidCallback onPressed, required bool isPrimary}) {
    final theme = Theme.of(context);
    return Container(
      decoration: isPrimary
          ? BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 10, offset: const Offset(0, 5))],
            )
          : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.white.withAlpha(200),
          foregroundColor: isPrimary ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isPrimary ? const Color.fromARGB(255, 255, 255, 255) : AppColors.primary),
        ),
      ),
    );
  }
}
