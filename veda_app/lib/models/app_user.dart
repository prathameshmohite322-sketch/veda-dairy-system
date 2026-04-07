class AppUser {
  const AppUser({
    required this.id,
    required this.dairyId,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
  });

  final String id;
  final String dairyId;
  final String name;
  final String role;
  final String email;
  final String phone;
}
