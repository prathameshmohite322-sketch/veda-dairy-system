import 'package:flutter/material.dart';

class AdminLoginRequiredScreen extends StatelessWidget {
  const AdminLoginRequiredScreen({
    super.key,
    required this.onSignIn,
  });

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.admin_panel_settings_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Admin login required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in from the main app with an admin account first, then reopen the admin panel.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onSignIn,
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
