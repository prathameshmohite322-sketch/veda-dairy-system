import 'package:flutter/material.dart';

import 'core/app_language.dart';
import 'core/constants.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/customer_service.dart';
import 'services/milk_entry_service.dart';

void main() {
  runApp(const VedaApp());
}

class VedaApp extends StatefulWidget {
  const VedaApp({super.key});

  @override
  State<VedaApp> createState() => _VedaAppState();
}

class _VedaAppState extends State<VedaApp> {
  final AuthService _authService = AuthService();
  final CustomerService _customerService = CustomerService();
  final MilkEntryService _milkEntryService = MilkEntryService();

  AppUser? _user;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      supportedLocales: AppLanguage.supportedLocales,
      home: _user == null
          ? LoginScreen(
              authService: _authService,
              onLogin: (AppUser user) {
                setState(() {
                  _user = user;
                });
              },
            )
          : DashboardScreen(
              user: _user!,
              authService: _authService,
              customerService: _customerService,
              milkEntryService: _milkEntryService,
              onLogout: () {
                setState(() {
                  _user = null;
                });
              },
            ),
    );
  }
}
