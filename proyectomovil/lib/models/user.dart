class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final DateTime? lockoutEnd;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.lockoutEnd,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String roleStr = 'Employee';
    // Manejo robusto de roles array o string
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      roleStr = json['roles'][0];
    } else if (json['role'] != null) {
      roleStr = json['role'];
    }

    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: roleStr,
      lockoutEnd: json['lockoutEnd'] != null
          ? DateTime.parse(json['lockoutEnd'])
          : null,
    );
  }
}
