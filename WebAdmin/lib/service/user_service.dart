import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/models/user_profile_model.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/utils/api_manager.dart';

class PageContextModel {
  final int page;
  final int perpage;
  final bool hasMorePage;

  PageContextModel({this.page = 1, this.perpage = 2, this.hasMorePage = false});

  factory PageContextModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 1;
      return 1;
    }

    return PageContextModel(
      page: parseInt(json['page']),
      perpage: parseInt(json['perpage']),
      hasMorePage: json['hasmorepage'] == true || json['has_more_page'] == true,
    );
  }
}

class UserListResult {
  final bool success;
  final String message;
  final int code;
  final UserSummaryModel? summary;
  final PageContextModel? pageContext;
  final List<UserModel> users;
  final bool isTokenExpired;

  UserListResult({
    required this.success,
    required this.message,
    required this.code,
    this.summary,
    this.pageContext,
    required this.users,
    this.isTokenExpired = false,
  });
}

class RoleListResult {
  final bool success;
  final String message;
  final int code;
  final List<RoleModel> roles;
  final bool isTokenExpired;

  RoleListResult({
    required this.success,
    required this.message,
    required this.code,
    required this.roles,
    this.isTokenExpired = false,
  });
}

class UserAddResult {
  final bool success;
  final String message;
  final int code;
  final bool isTokenExpired;

  UserAddResult({
    required this.success,
    required this.message,
    required this.code,
    this.isTokenExpired = false,
  });
}

class UserDetailResult {
  final bool success;
  final String message;
  final int code;
  final UserModel? user;
  final UserProfileModel? profile;
  final Map<String, dynamic>? rawData;
  final bool isTokenExpired;

  UserDetailResult({
    required this.success,
    required this.message,
    required this.code,
    this.user,
    this.profile,
    this.rawData,
    this.isTokenExpired = false,
  });
}

class UserService extends GetxService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiManager.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  /// Calls the getUserList API endpoint (users/v1/list).
  Future<UserListResult> getUserList({
    int page = 1,
    int perpage = 100,
    String? search,
    String? role,
    String? status,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[UserService] Auth token is empty');
      }
      return UserListResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        users: [],
        isTokenExpired: true,
      );
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.getUserList}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };
    final Map<String, dynamic> requestPayload = {
      'page': page,
      'perpage': perpage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint(
        '[UserService] Calling getUserList endpoint (POST): $targetUrl with payload: $requestPayload',
      );
    }

    // Web request direct call (POST with JSON payload)
    if (kIsWeb) {
      try {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(requestPayload),
        );

        responseStatusCode = httpResponse.statusCode;

        if (kDebugMode) {
          debugPrint(
            '[UserService] Web getUserList response status: ${httpResponse.statusCode}',
          );
          debugPrint(
            '[UserService] Web getUserList response body: ${httpResponse.body}',
          );
        }

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Web getUserList request exception: $e');
        }
      }
    }

    // Mobile / Fallback Dio call (POST with JSON payload)
    // if (responseData == null) {
    //   try {
    //     final response = await dio.post(
    //       ApiManager.getUserList,
    //       data: requestPayload,
    //       options: Options(
    //         contentType: Headers.jsonContentType,
    //         headers: requestHeaders,
    //       ),
    //     );
    //     responseStatusCode = response.statusCode;
    //     if (kDebugMode) {
    //       debugPrint(
    //         '[UserService] Dio getUserList response status: ${response.statusCode}',
    //       );
    //       debugPrint(
    //         '[UserService] Dio getUserList response data: ${response.data}',
    //       );
    //     }
    //     if (response.data != null) {
    //       if (response.data is Map<String, dynamic> || response.data is List) {
    //         responseData = response.data;
    //       } else if (response.data is String) {
    //         responseData = jsonDecode(response.data);
    //       }
    //     }
    //   } on DioException catch (e) {
    //     responseStatusCode = e.response?.statusCode;
    //     if (kDebugMode) {
    //       debugPrint(
    //         '[UserService] DioException in getUserList POST: $responseStatusCode',
    //       );
    //     }
    //     if (e.response?.data != null) {
    //       if (e.response!.data is Map<String, dynamic> ||
    //           e.response!.data is List) {
    //         responseData = e.response!.data;
    //       } else if (e.response!.data is String) {
    //         try {
    //           responseData = jsonDecode(e.response!.data);
    //         } catch (_) {}
    //       }
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       debugPrint('[UserService] Unexpected error in getUserList: $e');
    //     }
    //   }
    // }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return UserListResult(
        success: false,
        message: 'Session expired',
        code: 401,
        users: [],
        isTokenExpired: true,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final bool success = responseData['success'] == true;
      final String message = responseData['message']?.toString() ?? 'success';
      final int code = responseData['code'] is int ? responseData['code'] : 200;

      final dataObj = responseData['data'];
      UserSummaryModel? summary;
      PageContextModel? pageContext;
      List<UserModel> usersList = [];

      if (dataObj is Map<String, dynamic>) {
        if (dataObj.containsKey('summary') &&
            dataObj['summary'] is Map<String, dynamic>) {
          summary = UserSummaryModel.fromJson(
            dataObj['summary'] as Map<String, dynamic>,
          );
        }

        if (dataObj.containsKey('pagecontext') &&
            dataObj['pagecontext'] is Map<String, dynamic>) {
          pageContext = PageContextModel.fromJson(
            dataObj['pagecontext'] as Map<String, dynamic>,
          );
        }

        if (dataObj.containsKey('users') && dataObj['users'] is List) {
          final rawUsers = dataObj['users'] as List;
          usersList = rawUsers
              .whereType<Map<String, dynamic>>()
              .map((u) => UserModel.fromJson(u))
              .toList();
        }
      } else if (responseData.containsKey('users') &&
          responseData['users'] is List) {
        final rawUsers = responseData['users'] as List;
        usersList = rawUsers
            .whereType<Map<String, dynamic>>()
            .map((u) => UserModel.fromJson(u))
            .toList();
      }

      return UserListResult(
        success: success,
        message: message,
        code: code,
        summary: summary,
        pageContext: pageContext,
        users: usersList,
      );
    }

    return UserListResult(
      success: false,
      message: 'Failed to parse response data',
      code: responseStatusCode ?? 500,
      users: [],
    );
  }

  /// Calls the userAdd API endpoint (users/v1/add).
  Future<UserAddResult> addUser({
    required String email,
    required String fullname,
    required String mobile,
    required String rolekey,
    int status = 1,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[UserService] Auth token is empty in addUser');
      }
      return UserAddResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        isTokenExpired: true,
      );
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.userAdd}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {
      "email": email,
      "fullname": fullname,
      "mobile": mobile,
      "rolekey": rolekey,
      "status": status,
    };

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint(
        '[UserService] Calling userAdd endpoint: $targetUrl with payload: $payload',
      );
    }

    if (kIsWeb) {
      try {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );
        responseStatusCode = httpResponse.statusCode;
        if (httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Web userAdd request exception: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.userAdd,
          data: jsonEncode(payload),
          options: Options(
            contentType: Headers.jsonContentType,
            headers: requestHeaders,
          ),
        );
        responseStatusCode = response.statusCode;
        if (response.data != null) {
          if (response.data is Map<String, dynamic>) {
            responseData = response.data;
          } else if (response.data is String) {
            responseData = jsonDecode(response.data);
          }
        }
      } on DioException catch (e) {
        responseStatusCode = e.response?.statusCode;
        if (kDebugMode) {
          debugPrint(
            '[UserService] DioException in userAdd: $responseStatusCode',
          );
        }
        if (e.response?.data != null) {
          if (e.response!.data is Map<String, dynamic>) {
            responseData = e.response!.data;
          } else if (e.response!.data is String) {
            try {
              responseData = jsonDecode(e.response!.data);
            } catch (_) {}
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Unexpected error in userAdd: $e');
        }
      }
    }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return UserAddResult(
        success: false,
        message: 'Session expired',
        code: 401,
        isTokenExpired: true,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final bool success =
          responseData['success'] == true ||
          responseData['status'] == true ||
          responseData['status'] == 1 ||
          responseData['code'] == 200 ||
          responseData['code'] == 201 ||
          responseStatusCode == 200 ||
          responseStatusCode == 201;
      final String message =
          responseData['message']?.toString() ??
          responseData['msg']?.toString() ??
          'User added successfully';
      final int code = responseData['code'] is int
          ? responseData['code']
          : (responseStatusCode ?? 200);

      return UserAddResult(success: success, message: message, code: code);
    }

    final isSuccessStatus =
        responseStatusCode != null &&
        responseStatusCode >= 200 &&
        responseStatusCode < 300;

    return UserAddResult(
      success: isSuccessStatus,
      message: isSuccessStatus
          ? 'User added successfully'
          : 'Failed to add user',
      code: responseStatusCode ?? 500,
    );
  }

  /// Calls the roleList API endpoint (roles/v1/list) via GET request with Auth Token.
  Future<RoleListResult> getRoleList({String? token}) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[UserService] Auth token is empty in getRoleList');
      }
      return RoleListResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        roles: [],
        isTokenExpired: true,
      );
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.roleList}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint('[UserService] Calling roleList endpoint: $targetUrl');
    }

    if (kIsWeb) {
      try {
        final httpResponse = await http.get(
          Uri.parse(targetUrl),
          headers: requestHeaders,
        );
        responseStatusCode = httpResponse.statusCode;
        if (httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Web getRoleList request exception: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.get(
          ApiManager.roleList,
          options: Options(
            contentType: Headers.jsonContentType,
            headers: requestHeaders,
          ),
        );
        responseStatusCode = response.statusCode;
        if (response.data != null) {
          if (response.data is Map<String, dynamic> || response.data is List) {
            responseData = response.data;
          } else if (response.data is String) {
            responseData = jsonDecode(response.data);
          }
        }
      } on DioException catch (e) {
        responseStatusCode = e.response?.statusCode;
        if (kDebugMode) {
          debugPrint(
            '[UserService] DioException in getRoleList: $responseStatusCode',
          );
        }
        if (e.response?.data != null) {
          if (e.response!.data is Map<String, dynamic> ||
              e.response!.data is List) {
            responseData = e.response!.data;
          } else if (e.response!.data is String) {
            try {
              responseData = jsonDecode(e.response!.data);
            } catch (_) {}
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Unexpected error in getRoleList: $e');
        }
      }
    }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return RoleListResult(
        success: false,
        message: 'Session expired',
        code: 401,
        roles: [],
        isTokenExpired: true,
      );
    }

    RoleModel parseRoleItem(dynamic item) {
      if (item is Map<String, dynamic>) {
        return RoleModel.fromJson(item);
      } else if (item is String) {
        return RoleModel(roleKey: item, roleName: item);
      }
      return RoleModel(roleKey: '', roleName: item?.toString() ?? '');
    }

    List<RoleModel> rolesList = [];

    if (responseData is Map<String, dynamic>) {
      final bool success =
          responseData['success'] == true || responseData['code'] == 200;
      final String message = responseData['message']?.toString() ?? 'success';
      final int code = responseData['code'] is int ? responseData['code'] : 200;

      dynamic dataObj = responseData['data'] ?? responseData['roles'];
      if (dataObj is Map<String, dynamic> && dataObj.containsKey('roles')) {
        dataObj = dataObj['roles'];
      }

      if (dataObj is List) {
        rolesList = dataObj
            .map((r) => parseRoleItem(r))
            .where((r) => r.roleName.isNotEmpty)
            .toList();
      }

      return RoleListResult(
        success: success,
        message: message,
        code: code,
        roles: rolesList,
      );
    } else if (responseData is List) {
      rolesList = responseData
          .map((r) => parseRoleItem(r))
          .where((r) => r.roleName.isNotEmpty)
          .toList();

      return RoleListResult(
        success: true,
        message: 'success',
        code: 200,
        roles: rolesList,
      );
    }

    return RoleListResult(
      success: false,
      message: 'Failed to parse response data',
      code: responseStatusCode ?? 500,
      roles: [],
    );
  }

  /// Calls the userDetails API endpoint (users/v1/get-by-key).
  /// Sends POST request first with body {"userkey": userkey} and Bearer token as per API specification.
  /// Falls back to GET (query params) if server returns 405 Method Not Allowed or 404.
  Future<UserDetailResult> getUserDetails({
    required String userkey,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    //print("authToken...$activeToken");
    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[UserService] Auth token is empty in getUserDetails');
      }
      return UserDetailResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        isTokenExpired: true,
      );
    }

    final String baseUrlStr = "${ApiManager.baseUrl}${ApiManager.userDetails}";
    // final String getUrlWithParam =
    //     "$baseUrlStr?userkey=${Uri.encodeComponent(userkey)}";

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {"userkey": userkey};

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint(
        '[UserService] Calling userDetails endpoint: $baseUrlStr with userkey: $userkey',
      );
    }

    // 1. Web (http package)
    if (kIsWeb) {
      try {
        // Try POST first (as required by spec: body = {"userkey": "..."})
        var httpResponse = await http.post(
          Uri.parse(baseUrlStr),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );
        responseStatusCode = httpResponse.statusCode;

        print("Response from post request: $baseUrlStr");
        print("Response from post request: $payload");

        // If POST returns 405 Method Not Allowed or 404, fallback to GET
        if (httpResponse.statusCode == 405 || httpResponse.statusCode == 404) {
          httpResponse = await http.get(
            Uri.parse(baseUrlStr),
            headers: requestHeaders,
          );
          responseStatusCode = httpResponse.statusCode;
        }

        if (httpResponse.body.isNotEmpty) {
          try {
            responseData = jsonDecode(httpResponse.body);
          } catch (_) {}
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Web getUserDetails request exception: $e');
        }
      }
    }

    // // 2. Mobile / Fallback Dio call
    // if (responseData == null) {
    //   try {
    //     // Try POST first (data accepts Map directly when content-type is json)
    //     final response = await dio.post(
    //       ApiManager.userDetails,
    //       data: payload,
    //       options: Options(
    //         contentType: Headers.jsonContentType,
    //         headers: requestHeaders,
    //       ),
    //     );
    //     responseStatusCode = response.statusCode;

    //     if (response.data != null) {
    //       if (response.data is Map<String, dynamic>) {
    //         responseData = response.data;
    //       } else if (response.data is String) {
    //         try {
    //           responseData = jsonDecode(response.data);
    //         } catch (_) {}
    //       }
    //     }

    //     // If POST returns 405 or 404 or empty response, fallback to GET
    //     if ((responseStatusCode == 405 ||
    //         responseStatusCode == 404 ||
    //         responseData == null)) {
    //       final getResponse = await dio.get(
    //         ApiManager.userDetails,
    //         queryParameters: {"userkey": userkey},
    //         options: Options(
    //           contentType: Headers.jsonContentType,
    //           headers: requestHeaders,
    //         ),
    //       );
    //       responseStatusCode = getResponse.statusCode;
    //       if (getResponse.data != null) {
    //         if (getResponse.data is Map<String, dynamic>) {
    //           responseData = getResponse.data;
    //         } else if (getResponse.data is String) {
    //           try {
    //             responseData = jsonDecode(getResponse.data);
    //           } catch (_) {}
    //         }
    //       }
    //     }
    //   } on DioException catch (e) {
    //     responseStatusCode = e.response?.statusCode;
    //     if (kDebugMode) {
    //       debugPrint(
    //         '[UserService] DioException in getUserDetails: $responseStatusCode ($e)',
    //       );
    //     }
    //     if (e.response?.data != null) {
    //       if (e.response!.data is Map<String, dynamic>) {
    //         responseData = e.response!.data;
    //       } else if (e.response!.data is String) {
    //         try {
    //           responseData = jsonDecode(e.response!.data);
    //         } catch (_) {}
    //       }
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       debugPrint('[UserService] Unexpected error in getUserDetails: $e');
    //     }
    //   }
    // }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return UserDetailResult(
        success: false,
        message: 'Session expired',
        code: 401,
        isTokenExpired: true,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final bool success =
          responseData['success'] == true ||
          responseData['status'] == true ||
          responseData['status'] == 1 ||
          responseData['code'] == 200;
      final String message =
          responseData['message']?.toString() ??
          responseData['msg']?.toString() ??
          'success';
      final int code = responseData['code'] is int
          ? responseData['code']
          : (responseStatusCode ?? 200);

      dynamic dataObj = responseData['data'];

      if (dataObj is List && dataObj.isNotEmpty) {
        dataObj = dataObj.first;
      }

      UserModel? userObj;
      UserProfileModel? profileObj;
      Map<String, dynamic>? rawMap;

      if (dataObj is Map<String, dynamic>) {
        rawMap = dataObj;
        userObj = UserModel.fromJson(dataObj);
        profileObj = UserProfileModel.fromJson(dataObj);
      } else {
        rawMap = responseData;
        userObj = UserModel.fromJson(responseData);
        profileObj = UserProfileModel.fromJson(responseData);
      }

      return UserDetailResult(
        success: success,
        message: message,
        code: code,
        user: userObj,
        profile: profileObj,
        rawData: rawMap,
      );
    }

    return UserDetailResult(
      success: false,
      message: 'Failed to parse user details',
      code: responseStatusCode ?? 500,
    );
  }

  bool _isTokenExpired(int? statusCode, dynamic responseData) {
    if (statusCode == 401 || statusCode == 403) return true;
    if (responseData is Map) {
      final code = responseData['code'] ?? responseData['status'];
      if (code == 401 || code == 403 || code == '401' || code == '403') {
        return true;
      }
      final msg = (responseData['message'] ?? responseData['error'] ?? '')
          .toString()
          .toLowerCase();
      if (msg.contains('token expired') ||
          msg.contains('unauthorized') ||
          msg.contains('unauthenticated') ||
          msg.contains('session expired')) {
        return true;
      }
    }
    return false;
  }
}
