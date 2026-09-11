import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/utils/api_manager.dart';

class UserListResult {
  final bool success;
  final String message;
  final int code;
  final UserSummaryModel? summary;
  final List<UserModel> users;
  final bool isTokenExpired;

  UserListResult({
    required this.success,
    required this.message,
    required this.code,
    this.summary,
    required this.users,
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
      validateStatus: (status) =>
          status != null && status < 400 ||
          (status != null && status >= 500 && status < 600),
    ),
  );

  /// Calls the getUserList API endpoint (users/v1/list).
  Future<UserListResult> getUserList({String? token}) async {
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

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint('[UserService] Calling getUserList endpoint: $targetUrl');
    }

    // Web request direct call
    if (kIsWeb) {
      try {
        http.Response httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
        );

        if (httpResponse.statusCode < 200 ||
            httpResponse.statusCode >= 300 ||
            httpResponse.body.isEmpty) {
          httpResponse = await http.get(
            Uri.parse(targetUrl),
            headers: requestHeaders,
          );
        }

        responseStatusCode = httpResponse.statusCode;

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

    // Mobile / Fallback Dio call
    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.getUserList,
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
          debugPrint('[UserService] DioException in getUserList: $responseStatusCode');
        }
        try {
          final response = await dio.get(
            ApiManager.getUserList,
            options: Options(
              contentType: Headers.jsonContentType,
              headers: requestHeaders,
            ),
          );
          responseStatusCode = response.statusCode;
          if (response.data != null) {
            if (response.data is Map<String, dynamic> ||
                response.data is List) {
              responseData = response.data;
            } else if (response.data is String) {
              responseData = jsonDecode(response.data);
            }
          }
        } catch (_) {
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
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserService] Unexpected error in getUserList: $e');
        }
      }
    }

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
      List<UserModel> usersList = [];

      if (dataObj is Map<String, dynamic>) {
        if (dataObj.containsKey('summary') && dataObj['summary'] is Map<String, dynamic>) {
          summary = UserSummaryModel.fromJson(dataObj['summary'] as Map<String, dynamic>);
        }

        if (dataObj.containsKey('users') && dataObj['users'] is List) {
          final rawUsers = dataObj['users'] as List;
          usersList = rawUsers
              .whereType<Map<String, dynamic>>()
              .map((u) => UserModel.fromJson(u))
              .toList();
        }
      } else if (responseData.containsKey('users') && responseData['users'] is List) {
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
