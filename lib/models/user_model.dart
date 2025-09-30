class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String assignedLine;
  final String tenantId;
  final String? department;
  final String? role;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.assignedLine,
    required this.tenantId,
    this.department,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['userId'] ?? '',
      username: json['username'] ?? json['userName'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      assignedLine: json['assignedLine'] ?? json['line'] ?? 'Not assigned',
      tenantId: json['tenantId'] ?? '',
      department: json['department'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'assignedLine': assignedLine,
      'tenantId': tenantId,
      'department': department,
      'role': role,
    };
  }
}