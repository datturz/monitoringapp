class User {
  final int id;
  final String email;
  final String password;
  final String role;

  User(
      {required this.id,
      required this.email,
      required this.password,
      required this.role});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
