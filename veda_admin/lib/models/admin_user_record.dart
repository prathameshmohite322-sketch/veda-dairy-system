class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dairyId,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String dairyId;
}
