class User {
  final String username;
  final String password;
  final String email;
  final String assignedLine;
  final String fullName;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.assignedLine,
    required this.fullName,
  });

  // Convert User to Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'assignedLine': assignedLine,
      'fullName': fullName,
    };
  }

  // Create User from Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      assignedLine: map['assignedLine'],
      fullName: map['fullName'],
    );
  }
}