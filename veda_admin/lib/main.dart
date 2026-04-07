import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Veda Admin')),
      body: const Center(
        child: Text('Admin dashboard starter'),
      ),
    );
  }
}
