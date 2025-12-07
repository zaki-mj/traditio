import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_shell.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Email validation regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  // Show error notification (red)
  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show success notification (primary color)
  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Validate inputs before calling Firebase
  bool _validateInputs(AppLocalizations loc) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check email
    if (email.isEmpty) {
      _showErrorNotification('${loc.translate('email')} ${loc.translate('is_required').toLowerCase()}');
      return false;
    }

    if (!_isValidEmail(email)) {
      _showErrorNotification(loc.translate('invalid_email'));
      return false;
    }

    // Check password
    if (password.isEmpty) {
      _showErrorNotification('${loc.translate('password')} ${loc.translate('is_required').toLowerCase()}');
      return false;
    }

    if (password.length < 6) {
      _showErrorNotification(loc.translate('password_too_short'));
      return false;
    }

    return true;
  }

  Future<void> _handleLogin() async {
    final loc = AppLocalizations(Localizations.localeOf(context));

    // Validate inputs
    if (!_validateInputs(loc)) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final _ = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);

      _showSuccessNotification('Login successful');

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminShell()));
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorNotification(loc.translate('user_not_found'));
      } else if (e.code == 'wrong-password') {
        _showErrorNotification(loc.translate('wrong_password'));
      } else {
        _showErrorNotification(loc.translate('login_error'));
      }
    } catch (e) {
      _showErrorNotification(loc.translate('login_error'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              //theme.colorScheme.secondary.withValues(alpha: 0.08),
              theme.colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // App Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.hintColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Icon(Icons.admin_panel_settings, size: 48, color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.translate('login_title'),
                          style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Card
                  Card(
                    elevation: 8,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.colorScheme.surface, theme.colorScheme.surface.withValues(alpha: 0.9)]),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field (for prototyping, no validation)
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: loc.translate('email'),
                                prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            // Password Field (for prototyping, no validation)
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: loc.translate('password'),
                                prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Login Button (no validation, direct navigation)
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.hintColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isLoading
                                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary)))
                                    : Text(
                                        loc.translate('login_button'),
                                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Forgot Password Link
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.translate('contact_developer'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                          backgroundColor: theme.colorScheme.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Text(
                      loc.translate('forgot_password'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
