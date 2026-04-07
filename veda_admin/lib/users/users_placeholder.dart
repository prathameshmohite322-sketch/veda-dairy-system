import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> users = <Map<String, String>>[
      <String, String>{
        'name': 'Prathamesh Mohite',
        'role': 'Owner',
        'dairy': 'Veda Dairy Main',
      },
      <String, String>{
        'name': 'Collection Staff 1',
        'role': 'Staff',
        'dairy': 'Veda Dairy Main',
      },
      <String, String>{
        'name': 'Admin Reviewer',
        'role': 'Admin',
        'dairy': 'Platform',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: users
          .map(
            (Map<String, String> user) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(user['name'] ?? ''),
                subtitle: Text('${user['role']} | ${user['dairy']}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          )
          .toList(),
    );
  }
}
