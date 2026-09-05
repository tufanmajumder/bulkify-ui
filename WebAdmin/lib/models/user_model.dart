class UserModel {
  final String id;
  final String name;
  final String email;
  final String? contact;
  final String role;
  final String lastLogin;
  final String status;
  final String mobNo; // 'Active' or 'Inactive'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.contact,
    required this.role,
    required this.lastLogin,
    required this.status,
    required this.mobNo,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? contact,
    String? role,
    String? lastLogin,
    String? status,
    String? mobNo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      status: status ?? this.status,
      mobNo: mobNo ?? this.mobNo,
    );
  }
}
