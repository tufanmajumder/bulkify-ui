import 'package:intl/intl.dart';
import 'user_model.dart';

class SearchUserModel {
  final String userKey;
  final String userName;
  final String name;
  final String email;
  final String mobile;
  final String roleName;
  final String roleKey;
  final String status;
  final String isOnline;
  final String lastLogin;
  final String createdOn;

  SearchUserModel({
    required this.userKey,
    required this.userName,
    required this.name,
    required this.email,
    required this.mobile,
    required this.roleName,
    required this.roleKey,
    required this.status,
    required this.isOnline,
    required this.lastLogin,
    required this.createdOn,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    final rawLastLogin =
        json['lastlogin']?.toString() ??
        json['last_login']?.toString() ??
        json['lastLogin']?.toString() ??
        '';

    String formattedLastLogin = '-';
    if (rawLastLogin.isNotEmpty &&
        rawLastLogin != 'null' &&
        rawLastLogin != '-') {
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

    final String mobileVal =
        json['registeredmobile']?.toString() ??
        json['mobile']?.toString() ??
        json['mobNo']?.toString() ??
        json['contact']?.toString() ??
        json['phone']?.toString() ??
        '';

    final String emailVal =
        json['registeredemail']?.toString() ?? json['email']?.toString() ?? '';

    final String usernameVal =
        json['username']?.toString() ?? json['userName']?.toString() ?? '';

    final String nameVal =
        json['fullname']?.toString() ??
        json['name']?.toString() ??
        (usernameVal.isNotEmpty ? usernameVal : '');

    return SearchUserModel(
      userKey:
          json['userkey']?.toString() ??
          json['contactkey']?.toString() ??
          json['id']?.toString() ??
          '',
      userName: usernameVal,
      name: nameVal,
      email: emailVal,
      mobile: mobileVal,
      roleName:
          json['rolename']?.toString() ??
          json['role_name']?.toString() ??
          json['role']?.toString() ??
          '',
      roleKey:
          json['rolekey']?.toString() ?? json['role_key']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      isOnline: json['isonline']?.toString() ?? 'false',
      lastLogin: formattedLastLogin,
      createdOn:
          json['createdon']?.toString() ?? json['created_on']?.toString() ?? '',
    );
  }

  /// Converts SearchUserModel into UserModel for display in the user list table
  UserModel toUserModel() {
    return UserModel(
      id: userKey,
      userName: userName,
      name: name,
      email: email,
      contact: mobile.isNotEmpty ? mobile : null,
      role: roleName,
      lastLogin: lastLogin,
      status: status,
      mobNo: mobile,
      isOnline: isOnline,
    );
  }
}
