import 'package:intl/intl.dart';

class UserSummaryModel {
  final int activeUsers;
  final int pendingUsers;
  final int inactiveUsers;
  final int activeSession;

  UserSummaryModel({
    this.activeUsers = 0,
    this.pendingUsers = 0,
    this.inactiveUsers = 0,
    this.activeSession = 0,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val != null) {
        return int.tryParse(val.toString()) ?? 0;
      }
      return 0;
    }

    return UserSummaryModel(
      activeUsers: parseInt(json['activeusers'] ?? json['active_users']),
      pendingUsers: parseInt(json['pendingusers'] ?? json['pending_users']),
      inactiveUsers: parseInt(json['inactiveusers'] ?? json['inactive_users']),
      activeSession: parseInt(json['activesession'] ?? json['active_session']),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? contact;
  final String role;
  final String lastLogin;
  final String status;
  final String mobNo;

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawLastLogin =
        json['lastlogin']?.toString() ??
        json['last_login']?.toString() ??
        json['lastLogin']?.toString() ??
        '';

    String formattedLastLogin = rawLastLogin;
    if (rawLastLogin.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawLastLogin);
        formattedLastLogin = DateFormat(
          'dd-MM-yyyy hh:mm a',
        ).format(parsedDate);
      } catch (_) {
        formattedLastLogin = rawLastLogin;
      }
    }

    final String mobile =
        json['mobile']?.toString() ??
        json['mobNo']?.toString() ??
        json['contact']?.toString() ??
        '';

    return UserModel(
      id: json['userkey']?.toString() ?? json['id']?.toString() ?? '',
      name: json['username']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contact: mobile.isNotEmpty ? mobile : null,
      role: json['rolename']?.toString() ?? json['role']?.toString() ?? '',
      lastLogin: formattedLastLogin,
      status: json['status']?.toString() ?? 'Active',
      mobNo: mobile,
    );
  }

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
