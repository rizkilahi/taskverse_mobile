class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  // Dummy data untuk testing
  static UserModel currentUser = UserModel(
    id: '1',
    name: 'Sinister',
    email: 'sinister@example.com',
    avatarUrl: null,
  );
}