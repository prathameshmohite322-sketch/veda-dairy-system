import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_language.dart';
import 'core/app_localizations.dart';
import 'core/constants.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/customer_service.dart';
import 'services/factory_service.dart';
import 'services/khata_service.dart';
import 'services/milk_entry_service.dart';
import 'services/offline_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final OfflineService offlineService = OfflineService();
  await offlineService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(VedaApp(offlineService: offlineService));
}

class VedaApp extends StatefulWidget {
  const VedaApp({
    super.key,
    required this.offlineService,
  });

  final OfflineService offlineService;

  @override
  State<VedaApp> createState() => _VedaAppState();
}

class _VedaAppState extends State<VedaApp> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  late final CustomerService _customerService;
  late final FactoryService _factoryService;
  late final KhataService _khataService;
  late final MilkEntryService _milkEntryService;
  late final SyncService _syncService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;

  AppUser? _user;
  bool _booting = true;
  Locale _locale = const Locale(AppConstants.defaultLanguageCode);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _customerService = CustomerService(offlineService: widget.offlineService);
    _factoryService = FactoryService(offlineService: widget.offlineService);
    _milkEntryService = MilkEntryService(offlineService: widget.offlineService);
    _khataService = KhataService(
      customerService: _customerService,
      offlineService: widget.offlineService,
    );
    _syncService = SyncService(
      offlineService: widget.offlineService,
      customerService: _customerService,
    );
    _startAutoSync();
    _restoreSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final AppUser? user = await _authService.currentSessionUser();
    if (user != null) {
      await _attemptAutoSync();
    }
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
      locale: _locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      supportedLocales: AppLanguage.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        return AppLocalizations(
          localeCode: _locale.languageCode,
          onLocaleChanged: (Locale locale) {
            setState(() {
              _locale = locale;
            });
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _booting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _user == null
              ? LoginScreen(
                  authService: _authService,
                  onLogin: _handleLogin,
                )
              : DashboardScreen(
                  user: _user!,
                  authService: _authService,
                  customerService: _customerService,
                  factoryService: _factoryService,
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

  Future<void> _handleLogin(AppUser user) async {
    await _attemptAutoSync();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_attemptAutoSync());
    }
  }

  void _startAutoSync() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.any(
          (ConnectivityResult result) => result != ConnectivityResult.none)) {
        unawaited(_attemptAutoSync());
      }
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      unawaited(_attemptAutoSync());
    });
  }

  Future<void> _attemptAutoSync() async {
    final List<ConnectivityResult> connectivityResults =
        await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResults.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
    if (!isOnline) {
      return;
    }
    await _syncService.syncPendingRecords();
  }
}
