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

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();
    final AdminAuthService adminAuthService = AdminAuthService();
    return FutureBuilder<AdminSessionUser?>(
      future: adminAuthService.currentAdminUser(),
      builder:
          (BuildContext context, AsyncSnapshot<AdminSessionUser?> snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const AdminLoginRequiredScreen();
        }

        final AdminSessionUser user = snapshot.data!;
        if (user.role != 'admin') {
          return AccessDeniedScreen(
            role: user.role,
            onSignOut: adminAuthService.signOut,
          );
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Veda Admin | ${user.name}'),
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
                AdminDashboardScreen(adminService: adminService),
                UsersScreen(adminService: adminService),
                PaymentsScreen(adminService: adminService),
                const ReportsScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
