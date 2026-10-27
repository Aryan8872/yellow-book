class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });
}