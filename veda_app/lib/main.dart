import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_language.dart';
import 'core/constants.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/customer_service.dart';
import 'services/khata_service.dart';
import 'services/milk_entry_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final KhataService _khataService = KhataService();
  final MilkEntryService _milkEntryService = MilkEntryService();

  AppUser? _user;
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final AppUser? user = await _authService.currentSessionUser();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
      _booting = false;
    });
  }

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
      home: _booting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _user == null
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
              khataService: _khataService,
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
