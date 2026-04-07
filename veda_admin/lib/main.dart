import 'package:flutter/material.dart';

import 'dashboard/dashboard_placeholder.dart';
import 'payments/payments_placeholder.dart';
import 'reports/reports_placeholder.dart';
import 'users/users_placeholder.dart';

void main() {
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Veda Admin'),
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
        body: const TabBarView(
          children: <Widget>[
            AdminDashboardScreen(),
            UsersScreen(),
            PaymentsScreen(),
            ReportsScreen(),
          ],
        ),
      ),
    );
  }
}
