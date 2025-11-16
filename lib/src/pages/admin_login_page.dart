import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('admin_page'))),
      body: const Center(
        child: Text('Admin login placeholder — implement auth here.'),
      ),
    );
  }
}
