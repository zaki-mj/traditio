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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1a1a1a), const Color(0xFF0d3b35)]
                  : [const Color(0xFF00796B), const Color(0xFF26A69A)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo / Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(220),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Welcome text
                Center(
                  child: Text(
                    loc.translate('welcome'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Center(
                  child: Text(
                    loc.translate('welcome_description'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                // Buttons
                _buildButton(
                  context,
                  label: loc.translate('start_discovering'),
                  onPressed: () => Navigator.of(context).pushNamed('/discover'),
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  context,
                  label: loc.translate('admin_login'),
                  onPressed: () => Navigator.of(context).pushNamed('/admin'),
                  isPrimary: false,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: isPrimary
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Colors.white
              : Colors.white.withAlpha(50),
          foregroundColor: isPrimary ? AppColors.primary : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.white.withAlpha(200), width: 2),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPrimary ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
