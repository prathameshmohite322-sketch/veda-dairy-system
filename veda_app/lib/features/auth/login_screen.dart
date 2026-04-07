import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLogin,
  });

  final AuthService authService;
  final ValueChanged<AppUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'owner@veda.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'owner123');
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    AppUser? user;
    try {
      user = await widget.authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
      return;
    }

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _submitting = false;
        _error = l10n.t('loginFailed');
      });
      return;
    }

    widget.onLogin(user);
  }

  Future<void> _createOwnerAccount() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    AppUser? user;
    try {
      user = await widget.authService.createOwnerAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
      return;
    }

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _submitting = false;
        _error = l10n.t('accountCreationFailed');
      });
      return;
    }

    widget.onLogin(user);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String code) {
              l10n.setLocale(Locale(code));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'en', child: Text(l10n.t('english'))),
              PopupMenuItem<String>(value: 'mr', child: Text(l10n.t('marathi'))),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      l10n.t('loginTitle'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('loginSubtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.t('email'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.t('emailRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.t('password'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return l10n.t('passwordRequired');
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _submitting ? null : _login,
                      child: Text(_submitting ? l10n.t('signingIn') : l10n.t('login')),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _submitting ? null : _createOwnerAccount,
                      child: Text(l10n.t('createOwnerAccount')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
