import 'dart:convert';
import 'package:admin_app/models/login_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:admin_app/utils/api_manager.dart';
import 'package:admin_app/utils/string_manager.dart';
import 'package:admin_app/utils/widget_manager.dart';

class AuthService extends GetxService {
  static String authToken = "";
  static const String tokenKey = 'authToken';

  // OTP retry throttle — max 3 attempts per 60-second window
  static final List<DateTime> _otpAttemptTimestamps = [];
  static const int _otpMaxAttempts = 3;
  static const Duration _otpThrottleWindow = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();
    getAuthToken();
  }

  // ---------------------------------------------------------------------------
  // Token Management
  // ---------------------------------------------------------------------------

  static Future<void> setAuthToken(String token) async {
    if (token.trim().isNotEmpty) {
      authToken = token.trim();
      // TODO(security): Replace SharedPreferences (localStorage on web) with
      // HttpOnly cookie issued by the backend to prevent XSS token theft.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, authToken);
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthService] Error saving token: $e');
      }
    }
  }

  static Future<String> getAuthToken() async {
    if (authToken.isNotEmpty) {
      return authToken;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken =
          prefs.getString(tokenKey) ?? prefs.getString('sessionId') ?? "";
      if (savedToken.isNotEmpty) {
        authToken = savedToken;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] Error loading token: $e');
    }
    return authToken;
  }

  static Future<void> clearAuthToken() async {
    authToken = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove('sessionId');
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] Error clearing token: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // OTP throttle helper
  // ---------------------------------------------------------------------------

  /// Returns true if a new OTP attempt is allowed, false if throttled.
  static bool _checkAndRecordOtpAttempt() {
    final now = DateTime.now();
    _otpAttemptTimestamps.removeWhere(
      (t) => now.difference(t) > _otpThrottleWindow,
    );
    if (_otpAttemptTimestamps.length >= _otpMaxAttempts) {
      return false;
    }
    _otpAttemptTimestamps.add(now);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Dio instance — throws on 401/403 so catch blocks handle auth failures
  // ---------------------------------------------------------------------------

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiManager.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Throw DioException for 401/403 so auth failures are handled explicitly.
      validateStatus: (status) =>
          status != null && status < 400 ||
          (status != null && status >= 500 && status < 600),
    ),
  );

  // ---------------------------------------------------------------------------
  // Login service
  // ---------------------------------------------------------------------------

  Future<LoginModel?> login({
    required int channel,
    required String identifier,
  }) async {
    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.loginUrl}";
    final Map<String, dynamic> dataMap = {
      "channel": channel,
      "identifier": identifier,
    };

    // Web: call the backend directly.
    // NOTE: The backend must have CORS headers configured for this to succeed
    // in a browser context. Public CORS proxies have been removed for security.
    if (kIsWeb) {
      try {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(dataMap),
        );

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          return loginModelFromJson(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode)
          debugPrint('[AuthService] Web login request failed: $e');
      }
    }

    // Mobile/Desktop/Fallback: use Dio.
    try {
      final response = await dio.post(
        ApiManager.loginUrl,
        data: jsonEncode(dataMap),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LoginModel.fromJson(response.data);
        } else if (response.data is String) {
          return loginModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AuthService] DioException in login: ${e.response?.statusCode}',
        );
      }

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return LoginModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          try {
            return loginModelFromJson(e.response!.data);
          } catch (_) {}
        }
      }

      String errorText = StringManager.somethingWentWrong;
      if (e.response?.data != null &&
          e.response?.data is Map &&
          e.response?.data['message'] != null) {
        errorText = e.response?.data['message'].toString() ?? errorText;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorText = e.message!;
      }

      WidgetManager.showAlertSnackBar(errorText, 3);
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] Unexpected error in login: $e');
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Verify OTP service
  // ---------------------------------------------------------------------------

  Future<LoginModel?> verifyOtp({
    required int channel,
    String deviceinfo = '',
    required String identifier,
    required String otp,
  }) async {
    // Enforce client-side OTP retry throttle.
    if (!_checkAndRecordOtpAttempt()) {
      WidgetManager.showAlertSnackBar(
        'Too many attempts. Please wait a moment before trying again.',
        3,
      );
      return null;
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.verifyOtpUrl}";
    final String cleanIdentifier = identifier.replaceFirst('+91', '').trim();
    final String withPrefixIdentifier = cleanIdentifier.startsWith('+91')
        ? cleanIdentifier
        : '+91$cleanIdentifier';

    final List<Map<String, dynamic>> payloadsToTry = [
      {
        "channel": channel,
        "deviceinfo": deviceinfo,
        "identifier": identifier,
        "otp": otp,
      },
      if (identifier != cleanIdentifier)
        {
          "channel": channel,
          "deviceinfo": deviceinfo,
          "identifier": cleanIdentifier,
          "otp": otp,
        },
      if (identifier != withPrefixIdentifier)
        {
          "channel": channel,
          "deviceinfo": deviceinfo,
          "identifier": withPrefixIdentifier,
          "otp": otp,
        },
    ];

    // Web: call the backend directly.
    // NOTE: The backend must have CORS headers configured for browser requests.
    if (kIsWeb) {
      for (final payload in payloadsToTry) {
        try {
          final httpResponse = await http.post(
            Uri.parse(targetUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          );

          if (httpResponse.statusCode >= 200 &&
              httpResponse.statusCode < 500 &&
              httpResponse.body.isNotEmpty) {
            final model = loginModelFromJson(httpResponse.body);
            final sStr = model.success?.toString().toLowerCase();
            final cStr = model.code?.toString();
            if (model.success == true ||
                sStr == 'true' ||
                sStr == '1' ||
                sStr == 'success' ||
                model.code == 200 ||
                cStr == '200' ||
                cStr == '0' ||
                model.data != null) {
              return model;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[AuthService] Web verifyOtp attempt failed: $e');
          }
        }
      }
    }

    // Mobile/Desktop/Fallback: use Dio.
    try {
      final response = await dio.post(
        ApiManager.verifyOtpUrl,
        data: jsonEncode(payloadsToTry.first),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LoginModel.fromJson(response.data);
        } else if (response.data is String) {
          return loginModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AuthService] DioException in verifyOtp: ${e.response?.statusCode}',
        );
      }
      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return LoginModel.fromJson(e.response!.data);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] Unexpected error in verifyOtp: $e');
      }
      return null;
    }
  }

  Map<String, dynamic> convertData(
    String phone,
    String deviceId,
    String model,
    String brand,
  ) {
    return {
      "devicetype": phone,
      "deviceid": deviceId,
      "model": model,
      "brand": brand,
    };
  }
}
