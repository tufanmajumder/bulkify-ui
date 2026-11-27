import 'dart:convert';
import 'dart:io';

import 'package:bulkify/app/data/models/auth_models/login_model.dart';
import 'package:bulkify/app/data/models/auth_models/profile/profileModel.dart';
import 'package:bulkify/app/data/models/auth_models/verify_otp_model.dart';
import 'package:bulkify/app/data/models/home/summary_model.dart';
import 'package:bulkify/app/data/models/home/pending_offer_model.dart';
import 'package:bulkify/app/data/models/order/reject_model.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bulkify/app/data/utils/api_manager.dart';

class AuthService extends GetConnect implements GetxService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiManager.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  // loginService
  Future<LoginModel?> login1(String name, String pass) async {
    final String url = ApiManager.loginUrl;
    print("url in login...${ApiManager.baseUrl}$url");
    //print("name & pass...$name...$pass");
    final dynamic channelValue =
        int.tryParse(name) ?? (name.toLowerCase() == '1' ? 1 : name);
    final String formattedPhone = pass.startsWith('+91') ? pass : '+91$pass';
    Map<String, dynamic> data1 = {
      "channel": channelValue,
      "identifier": formattedPhone,
    };
    print("response data...$data1");

    try {
      final response = await dio.post(url, data: data1);
      print("response status...${response.statusCode}");
      print("response data...${response.data}");
      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LoginModel.fromJson(response.data);
        } else if (response.data is String) {
          return loginModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      //print("DioException type: ${e.type}");
      //print("DioException error: ${e.error}");
      //print("DioException response status: ${e.response?.statusCode}");
      //print("DioException response data: ${e.response?.data}");

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return LoginModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return loginModelFromJson(e.response!.data);
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in login1: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // verifyOtpService
  Future<VerifyOtpModel?> verifyOtp({
    dynamic channel = 2,
    String deviceinfo = "",
    required String identifier,
    required String otp,
    String? fcmtoken,
  }) async {
    final String url = ApiManager.verifyOtpUrl;
    final dynamic channelValue = int.tryParse(channel.toString()) ?? channel;
    final String formattedPhone = identifier.startsWith('+91')
        ? identifier
        : '+91$identifier';

    String resolvedFcmToken = (fcmtoken ?? '').trim();
    if (resolvedFcmToken.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        resolvedFcmToken =
            prefs.getString('fcmToken') ?? prefs.getString('fcmtoken') ?? '';
      } catch (_) {}
    }

    if (resolvedFcmToken.isEmpty) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.trim().isNotEmpty) {
          resolvedFcmToken = token.trim();
        }
      } catch (e) {
        // print("Error fetching FCM token in verifyOtp: $e");
      }
    }

    Map<String, dynamic> dataMap = {
      "channel": channelValue,
      "deviceinfo": deviceinfo,
      "identifier": formattedPhone,
      "otp": otp,
      if (resolvedFcmToken.isNotEmpty) "fcmtoken": resolvedFcmToken,
    };

    try {
      final response = await dio.post(url, data: dataMap);
      print("verifyOtp status...${response.statusCode}");
      print("verifyOtp data...${response.data}");
      print("verifyOtp data...$dataMap");
      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return VerifyOtpModel.fromJson(response.data);
        } else if (response.data is String) {
          return verifyOtpModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      //print("DioException verifyOtp status: ${e.response?.statusCode}");
      //print("DioException verifyOtp data: ${e.response?.data}");

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return VerifyOtpModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return verifyOtpModelFromJson(e.response!.data);
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in verifyOtp: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // getConnectService
  Future<ProfileViewModel?> getConnect({String? sessionId}) async {
    final String url = ApiManager.getConnect;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    //print("url in getConnect...${ApiManager.baseUrl}$url");
    //print("Authorization token...${headers['Authorization']}");

    try {
      final response = await dio.get(url, options: Options(headers: headers));
      // print("getConnect status...${response.statusCode}");
      // print("getConnect data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ProfileViewModel.fromJson(response.data);
        } else if (response.data is String) {
          return profileViewModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      //print("DioException getConnect status: ${e.response?.statusCode}");
      //print("DioException getConnect data: ${e.response?.data}");

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return ProfileViewModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return profileViewModelFromJson(e.response!.data);
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in getConnect: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // getOrderListService
  Future<RejectedModel?> getOrderList({
    int page = 1,
    int pagesize = 10,
    String scope = "active",
    String? status,
    String? sessionId,
  }) async {
    final String url = ApiManager.getOrderList;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    final String resolvedScope = (scope.isNotEmpty && scope != "active"
            ? scope
            : (status ?? scope))
        .toLowerCase();

    final Map<String, dynamic> bodyData = {
      "page": page,
      "pagesize": pagesize,
      "scope": resolvedScope,
    };

    print("url in getOrderList...${ApiManager.baseUrl}$url");
    print("token in getOrderList...$token");
    print("headers in getOrderList...$headers");
    print("body in getOrderList...$bodyData");

    try {
      final response = await dio.post(
        url,
        data: bodyData,
        options: Options(headers: headers),
      );
      //print("getOrderList status...${response.statusCode}");
      //print("getOrderList data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return RejectedModel.fromJson(response.data);
        } else if (response.data is String) {
          return rejectedModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      //print("DioException getOrderList status: ${e.response?.statusCode}");
      //print("DioException getOrderList data: ${e.response?.data}");

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return RejectedModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return rejectedModelFromJson(e.response!.data);
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in getOrderList: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // getSummaryService
  Future<SummaryModel?> getSummary({String? sessionId}) async {
    final String url = ApiManager.summary;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    // print("url in getSummary...${ApiManager.baseUrl}$url");
    // print("token in getSummary...$token");
    // print("headers in getSummary...$headers");

    try {
      final response = await dio.get(url, options: Options(headers: headers));
      // print("getSummary status...${response.statusCode}");
      // print("getSummary data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return SummaryModel.fromJson(response.data);
        } else if (response.data is String) {
          return summaryModelFromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      //print("DioException getSummary status: ${e.response?.statusCode}");
      //print("DioException getSummary data: ${e.response?.data}");

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return SummaryModel.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return summaryModelFromJson(e.response!.data);
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in getSummary: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // updateOnlineStatusService
  Future<Map<String, dynamic>?> updateOnlineStatus({
    required bool isOnline,
    String? sessionId,
  }) async {
    final String url = ApiManager.onlinestatus;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    final Map<String, dynamic> body = {"isonline": isOnline};

    //print("url in updateOnlineStatus...${ApiManager.baseUrl}$url");
    //print("token in updateOnlineStatus...$token");
    //print("headers in updateOnlineStatus...$headers");
    //print("body in updateOnlineStatus...$body");

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      //print("updateOnlineStatus status...${response.statusCode}");
      //print("updateOnlineStatus data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } on DioException catch (e) {
      //print(
      //  "DioException updateOnlineStatus status: ${e.response?.statusCode}",
      //);
      //print("DioException updateOnlineStatus data: ${e.response?.data}");

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      //print("General exception in updateOnlineStatus: $e");
      //print("StackTrace: $stackTrace");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // getPendingOffersService
  Future<PendingOfferModel?> getPendingOffers({String? sessionId}) async {
    final String url = ApiManager.pendingOffer;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    print("url in pendingOffer...${ApiManager.baseUrl}$url");
    print("Authorization token...${headers['Authorization']}");

    try {
      // 1. Try POST without body as specified in curl
      Response response;
      try {
        response = await dio.post(url, options: Options(headers: headers));
      } catch (e) {
        response = await dio.post(
          url,
          data: {},
          options: Options(headers: headers),
        );
      }

      print("pendingOffer status...${response.statusCode}");
      print("pendingOffer data...${response.data}");

      PendingOfferModel? model;
      if (response.data != null) {
        model = PendingOfferModel.fromAny(response.data);
      }

      // If no items extracted, try with `{}` in case server expects empty json body
      if (model == null || model.items.isEmpty) {
        try {
          final res2 = await dio.post(
            url,
            data: {},
            options: Options(headers: headers),
          );
          if (res2.data != null) {
            final model2 = PendingOfferModel.fromAny(res2.data);
            if (model2.items.isNotEmpty) {
              model = model2;
            }
          }
        } catch (_) {}
      }

      return model;
    } on DioException catch (e) {
      print("DioException pendingOffer status: ${e.response?.statusCode}");
      print("DioException pendingOffer data: ${e.response?.data}");

      if (e.response?.data != null) {
        return PendingOfferModel.fromAny(e.response!.data);
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      print("General exception in pendingOffer: $e");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // acceptOrderService
  Future<Map<String, dynamic>?> acceptOrder({
    required String orderKey,
    String reasonCode = "",
    String remarks = "",
    String? sessionId,
  }) async {
    final String url = ApiManager.acceptOrder;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    final Map<String, dynamic> body = {
      "orderkey": orderKey,
      "reasoncode": reasonCode,
      "remarks": remarks,
    };

    print("url in acceptOrder...${ApiManager.baseUrl}$url");
    print("Authorization token...${headers['Authorization']}");
    print("body in acceptOrder...$body");

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      print("acceptOrder status...${response.statusCode}");
      print("acceptOrder data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            return json.decode(response.data) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
      return null;
    } on DioException catch (e) {
      print("DioException acceptOrder status: ${e.response?.statusCode}");
      print("DioException acceptOrder data: ${e.response?.data}");

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      print("General exception in acceptOrder: $e");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // rejectOrderService
  Future<Map<String, dynamic>?> rejectOrder({
    required String orderKey,
    String reasonCode = "",
    String remarks = "",
    String? sessionId,
  }) async {
    final String url = ApiManager.rejectOrder;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    final Map<String, dynamic> body = {
      "orderkey": orderKey,
      "reasoncode": reasonCode,
      "remarks": remarks,
    };

    print("url in rejectOrder...${ApiManager.baseUrl}$url");
    print("Authorization token...${headers['Authorization']}");
    print("body in rejectOrder...$body");

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      print("rejectOrder status...${response.statusCode}");
      print("rejectOrder data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            return json.decode(response.data) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
      return null;
    } on DioException catch (e) {
      print("DioException rejectOrder status: ${e.response?.statusCode}");
      print("DioException rejectOrder data: ${e.response?.data}");

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      print("General exception in rejectOrder: $e");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  // updateOrderStatusService (driver/v1/status)
  Future<Map<String, dynamic>?> updateOrderStatus({
    required String orderKey,
    String state = "picked_up",
    double? latitude,
    double? longitude,
    String reasonCode = "",
    String remarks = "",
    String? sessionId,
  }) async {
    final String url = ApiManager.driverStatus;
    String? token = sessionId;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('sessionId');
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }

    final Map<String, dynamic> body = {
      "latitude": latitude,
      "longitude": longitude,
      "orderkey": orderKey,
      "reasoncode": reasonCode,
      "remarks": remarks,
      "state": state,
    };

    print("url in updateOrderStatus...${ApiManager.baseUrl}$url");
    print("Authorization token...${headers['Authorization']}");
    print("body in updateOrderStatus...$body");

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      print("updateOrderStatus status...${response.statusCode}");
      print("updateOrderStatus data...${response.data}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            return json.decode(response.data) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
      return null;
    } on DioException catch (e) {
      print("DioException updateOrderStatus status: ${e.response?.statusCode}");
      print("DioException updateOrderStatus data: ${e.response?.data}");

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        WidgetManager.showAlertSnackBar(StringManager.unableToReachInternet, 3);
      } else {
        WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      }
      return null;
    } catch (e) {
      print("General exception in updateOrderStatus: $e");
      WidgetManager.showAlertSnackBar(StringManager.somethingWentWrong, 3);
      return null;
    }
  }

  String convertData(
    String phone,
    String deviceId,
    String model,
    String brand, [
    String? fcmtoken,
  ]) {
    // 1. Define your source Map
    final Map<String, dynamic> deviceData = {
      "devicetype": phone,
      "deviceid": deviceId,
      "model": model,
      "brand": brand,
      "fcmtoken": (fcmtoken != null && fcmtoken.trim().isNotEmpty)
          ? fcmtoken.trim()
          : "",
    };

    print("DeviceData auth....$deviceData");
    print("DeviceData auth....${deviceData.runtimeType}");

    // 2. Format the Map into a pretty-printed JSON string with 2 spaces
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJsonString = encoder.convert(deviceData);

    // 3. Convert the string to bytes (UTF-8)
    final List<int> jsonBytes = utf8.encode(prettyJsonString);

    // 4. Encode the bytes to Base64
    final String base64Result = base64.encode(jsonBytes);

    //print(base64Result);
    return base64Result;
    // Output: ewogICJkZXZpY2V0eXBlIjogIlBob25lIiwKICAiZGV2aWNlaWQiOiAiQlA0QS4yNTEyMDUuMDA2IiwKICAibW9kZWwiOiAiU00tTTA3NUYiLAogICJicmFuZCI6ICJzYW1zdW5nIgp9
  }
}
