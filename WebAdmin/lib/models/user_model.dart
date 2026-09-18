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

class RoleModel {
  final String roleKey;
  final String roleName;

  RoleModel({
    required this.roleKey,
    required this.roleName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleKey: json['rolekey']?.toString() ??
          json['role_key']?.toString() ??
          json['id']?.toString() ??
          json['key']?.toString() ??
          '',
      roleName: json['rolename']?.toString() ??
          json['role_name']?.toString() ??
          json['name']?.toString() ??
          json['role']?.toString() ??
          '',
    );
  }
}

class UserModel {
  final String id;
  final String userName;
  final String name;
  final String email;
  final String? contact;
  final String role;
  final String lastLogin;
  final String status;
  final String mobNo;
  final String isOnline;

  UserModel({
    required this.id,
    required this.userName,
    required this.name,
    required this.email,
    this.contact,
    required this.role,
    required this.lastLogin,
    required this.status,
    required this.mobNo,
    required this.isOnline,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawLastLogin =
        json['lastlogin']?.toString() ??
        json['last_login']?.toString() ??
        json['lastLogin']?.toString() ??
        '';

    String formattedLastLogin = '-';
    if (rawLastLogin.isNotEmpty && rawLastLogin != 'null' && rawLastLogin != '-') {
      try {
        DateTime parsedDate = DateTime.parse(rawLastLogin);
        String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
        String formattedTime = DateFormat('hh:mm:ss a').format(parsedDate);
        formattedLastLogin = '$formattedDate $formattedTime';
      } catch (_) {
        DateTime? dt = DateTime.tryParse(rawLastLogin);
        if (dt == null && rawLastLogin.contains(' ')) {
          dt = DateTime.tryParse(rawLastLogin.replaceFirst(' ', 'T'));
        }
        if (dt != null) {
          String formattedDate = DateFormat('dd-MM-yyyy').format(dt);
          String formattedTime = DateFormat('hh:mm:ss a').format(dt);
          formattedLastLogin = '$formattedDate $formattedTime';
        } else {
          formattedLastLogin = rawLastLogin;
        }
      }
    }

    final String mobile =
        json['mobile']?.toString() ??
        json['mobNo']?.toString() ??
        json['contact']?.toString() ??
        '';

    final String usernameVal =
        json['username']?.toString() ?? json['userName']?.toString() ?? '';

    final String nameVal =
        json['name']?.toString() ?? (usernameVal.isNotEmpty ? usernameVal : '');

    return UserModel(
      id: json['userkey']?.toString() ?? json['id']?.toString() ?? '',
      userName: usernameVal,
      name: nameVal,
      email: json['email']?.toString() ?? '',
      contact: mobile.isNotEmpty ? mobile : null,
      role: json['rolename']?.toString() ?? json['role']?.toString() ?? '',
      lastLogin: formattedLastLogin,
      status: json['status']?.toString() ?? 'Active',
      mobNo: mobile,
      isOnline: json['isonline']?.toString() ?? 'false',
    );
  }

  UserModel copyWith({
    String? id,
    String? userName,
    String? name,
    String? email,
    String? contact,
    String? role,
    String? lastLogin,
    String? status,
    String? mobNo,
    String? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      status: status ?? this.status,
      mobNo: mobNo ?? this.mobNo,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
