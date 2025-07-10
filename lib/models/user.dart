/// Model representing a user in the system.
class User {
  /// Unique identifier for the user.
  final String id;

  /// Name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// Whether the user is an admin.
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}
