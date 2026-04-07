import 'package:flutter/material.dart';

import '../models/admin_user_record.dart';
import '../services/admin_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _selectedRole = 'all';
  String _selectedDairy = 'all';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminUserRecord>>(
      future: widget.adminService.fetchUsers(),
      builder: (BuildContext context,
          AsyncSnapshot<List<AdminUserRecord>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<AdminUserRecord> allUsers = snapshot.data!;
        if (allUsers.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        final List<String> dairyOptions = <String>{
          'all',
          ...allUsers.map((AdminUserRecord user) => user.dairyId),
        }.toList()
          ..sort();

        final List<AdminUserRecord> users =
            allUsers.where((AdminUserRecord user) {
          final bool matchesRole =
              _selectedRole == 'all' || user.role == _selectedRole;
          final bool matchesDairy =
              _selectedDairy == 'all' || user.dairyId == _selectedDairy;
          return matchesRole && matchesDairy;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role filter',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                          value: 'all', child: Text('All roles')),
                      DropdownMenuItem<String>(
                          value: 'admin', child: Text('Admin')),
                      DropdownMenuItem<String>(
                          value: 'owner', child: Text('Owner')),
                      DropdownMenuItem<String>(
                          value: 'staff', child: Text('Staff')),
                    ],
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDairy,
                    decoration: const InputDecoration(
                      labelText: 'Dairy filter',
                      border: OutlineInputBorder(),
                    ),
                    items: dairyOptions
                        .map(
                          (String dairyId) => DropdownMenuItem<String>(
                            value: dairyId,
                            child: Text(
                                dairyId == 'all' ? 'All dairies' : dairyId),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedDairy = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No users match the selected filters.'),
                ),
              ),
            ...users.map(
              (AdminUserRecord user) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text('${user.role} | ${user.dairyId}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openUserDetails(user),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUserDetails(AdminUserRecord user) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
              Text('Role: ${user.role}'),
              Text('Dairy: ${user.dairyId}'),
              Text('User ID: ${user.id}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
