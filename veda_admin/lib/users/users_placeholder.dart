import 'package:flutter/material.dart';

import '../models/admin_user_record.dart';
import '../services/admin_service.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminUserRecord>>(
      future: adminService.fetchUsers(),
      builder: (BuildContext context,
          AsyncSnapshot<List<AdminUserRecord>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<AdminUserRecord> users = snapshot.data!;
        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: users
              .map(
                (AdminUserRecord user) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.role} | ${user.dairyId}'),
                    trailing: Text(user.email),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
