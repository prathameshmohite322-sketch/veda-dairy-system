import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dashboard/dashboard_placeholder.dart';
import 'firebase_options.dart';
import 'models/admin_session_user.dart';
import 'payments/payments_placeholder.dart';
import 'reports/reports_placeholder.dart';
import 'services/admin_auth_service.dart';
import 'services/admin_service.dart';
import 'users/users_placeholder.dart';
import 'widgets/access_denied_screen.dart';
import 'widgets/admin_error_view.dart';
import 'widgets/admin_login_screen.dart';
import 'widgets/admin_login_required_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const VedaAdminApp());
}

class VedaAdminApp extends StatelessWidget {
  const VedaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veda Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F5B34)),
        useMaterial3: true,
      ),
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  AdminSessionUser? _sessionUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminSessionUser?>(
      future: _sessionUser == null
          ? _adminAuthService.currentAdminUser()
          : Future.value(_sessionUser),
      builder:
          (BuildContext context, AsyncSnapshot<AdminSessionUser?> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: AdminErrorView(
              title: 'Admin Session Load Failed',
              error: snapshot.error!,
            ),
          );
        }
        if (!snapshot.hasData) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AdminLoginRequiredScreen(
            onSignIn: _openLogin,
          );
        }

        final AdminSessionUser user = snapshot.data!;
        if (user.role != 'admin') {
          return AccessDeniedScreen(
            role: user.role,
            onSignOut: _handleSignOut,
          );
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Veda Admin | ${user.name}'),
              actions: <Widget>[
                IconButton(
                  onPressed: _handleSignOut,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: <Tab>[
                  Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_outlined)),
                  Tab(text: 'Users', icon: Icon(Icons.people_outline)),
                  Tab(text: 'Payments', icon: Icon(Icons.credit_card)),
                  Tab(text: 'Reports', icon: Icon(Icons.analytics_outlined)),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                AdminDashboardScreen(adminService: _adminService),
                UsersScreen(adminService: _adminService),
                PaymentsScreen(adminService: _adminService),
                ReportsScreen(adminService: _adminService),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminLoginScreen(
          adminAuthService: _adminAuthService,
          onLogin: (AdminSessionUser user) {
            setState(() {
              _sessionUser = user;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _handleSignOut() async {
    await _adminAuthService.signOut();
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionUser = null;
    });
  }
}
