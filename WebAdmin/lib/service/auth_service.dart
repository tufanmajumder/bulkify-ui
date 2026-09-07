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

  @override
  void onInit() {
    super.onInit();
    getAuthToken();
  }

  static Future<void> setAuthToken(String token) async {
    if (token.trim().isNotEmpty) {
      authToken = token.trim();
      print("================ TOKEN UPDATED ================");
      print("AuthService authToken: $authToken");
      print("===============================================");
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, authToken);
        print("Token saved to SharedPreferences under '$tokenKey'");
      } catch (e) {
        print("Error saving token to SharedPreferences: $e");
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
        print(
          "================ TOKEN LOADED FROM SHARED PREFERENCES ================",
        );
        print("AuthService authToken: $authToken");
        print(
          "======================================================================",
        );
      }
    } catch (e) {
      print("Error loading token from SharedPreferences: $e");
    }
    return authToken;
  }

  static Future<void> clearAuthToken() async {
    authToken = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove('sessionId');
      print(
        "================ TOKEN CLEARED FROM SHARED PREFERENCES ================",
      );
    } catch (e) {
      print("Error clearing token from SharedPreferences: $e");
    }
  }

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

  // loginService
  Future<LoginModel?> login({
    required int channel,
    required String identifier,
  }) async {
    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.loginUrl}";
    final Map<String, dynamic> dataMap = {
      "channel": channel,
      "identifier": identifier,
    };

    print("target URL in login...$targetUrl");
    print("payload in login...$dataMap");

    // 1. Web execution with multi-proxy fallback
    if (kIsWeb) {
      final List<String> urlsToTry = [
        targetUrl,
        "https://thingproxy.freeboard.io/fetch/$targetUrl",
        "https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}",
      ];

      for (final urlStr in urlsToTry) {
        try {
          print("Attempting web login via: $urlStr");
          final httpResponse = await http.post(
            Uri.parse(urlStr),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(dataMap),
          );

          print("Status from $urlStr: ${httpResponse.statusCode}");
          print("Body from $urlStr: ${httpResponse.body}");

          if (httpResponse.statusCode >= 200 &&
              httpResponse.statusCode < 500 &&
              httpResponse.body.isNotEmpty) {
            final LoginModel parsed = loginModelFromJson(httpResponse.body);
            return parsed;
          }
        } catch (e) {
          print("Request to $urlStr failed: $e");
        }
      }
    }

    // 2. Dio execution (For Mobile/Desktop/Fallback)
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
      print("Dio login status...${response.statusCode}");
      print("Dio login data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LoginModel.fromJson(response.data);
        } else if (response.data is String) {
          return loginModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      print("DioException in login status: ${e.response?.statusCode}");
      print("DioException in login data: ${e.response?.data}");

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
    } catch (e, stackTrace) {
      print("General exception in login: $e");
      print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // verifyOtpService
  Future<LoginModel?> verifyOtp({
    required int channel,
    String deviceinfo = '',
    required String identifier,
    required String otp,
  }) async {
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

    print("target URL in verifyOtp...$targetUrl");

    if (kIsWeb) {
      final List<String> urlsToTry = [
        targetUrl,
        "https://corsproxy.io/?$targetUrl",
        "https://thingproxy.freeboard.io/fetch/$targetUrl",
        "https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}",
      ];

      for (final payload in payloadsToTry) {
        print("payload in verifyOtp...$payload");
        for (final urlStr in urlsToTry) {
          try {
            print("Attempting web verifyOtp via: $urlStr");
            final httpResponse = await http.post(
              Uri.parse(urlStr),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(payload),
            );

            print("Status from $urlStr: ${httpResponse.statusCode}");
            print("Body from $urlStr: ${httpResponse.body}");

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
            print("Verify OTP request failed on $urlStr: $e");
          }
        }
      }
    }

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
      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return LoginModel.fromJson(e.response!.data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> convertData(
    String phone,
    String deviceId,
    String model,
    String brand,
  ) {
    final Map<String, dynamic> deviceData = {
      "devicetype": phone,
      "deviceid": deviceId,
      "model": model,
      "brand": brand,
    };
    print("deviceData: $deviceData");
    return deviceData;
  }
}
