import 'package:flutter/material.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement actual authentication
    // For now, redirect to admin shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/admin-dashboard');
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
