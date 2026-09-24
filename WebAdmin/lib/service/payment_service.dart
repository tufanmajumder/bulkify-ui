import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/utils/api_manager.dart';

class PaymentPageContext {
  final int page;
  final int perpage;
  final bool hasMorePage;
  final int total;
  final int totalPages;

  PaymentPageContext({
    this.page = 1,
    this.perpage = 2,
    this.hasMorePage = false,
    this.total = 0,
    this.totalPages = 1,
  });

  factory PaymentPageContext.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int || val is double) return val == 1;
      if (val != null) {
        final s = val.toString().trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    final pageVal = parseInt(json['page']);
    final perPageVal = parseInt(json['perpage']);
    final totalVal = parseInt(
      json['total'] ?? json['total_count'] ?? json['totalCount'],
    );
    final totalPagesVal = parseInt(
      json['totalpages'] ?? json['total_pages'] ?? json['totalPages'],
    );

    return PaymentPageContext(
      page: pageVal > 0 ? pageVal : 1,
      perpage: perPageVal > 0 ? perPageVal : 2,
      hasMorePage: parseBool(json['hasmorepage']),
      total: totalVal,
      totalPages: totalPagesVal > 0 ? totalPagesVal : 1,
    );
  }
}

class PaymentListResult {
  final bool success;
  final String message;
  final int code;
  final PaymentPageContext? pageContext;
  final List<PaymentModel> payments;
  final bool isTokenExpired;

  PaymentListResult({
    required this.success,
    required this.message,
    required this.code,
    this.pageContext,
    required this.payments,
    this.isTokenExpired = false,
  });
}

class PaymentDetailResult {
  final bool success;
  final String message;
  final int code;
  final PaymentModel? payment;
  final Map<String, dynamic>? rawData;
  final bool isTokenExpired;

  PaymentDetailResult({
    required this.success,
    required this.message,
    required this.code,
    this.payment,
    this.rawData,
    this.isTokenExpired = false,
  });
}

class PaymentService extends GetxService {
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

  /// Calls payments/v1/list API endpoint.
  Future<PaymentListResult> getPaymentList({
    int page = 1,
    int perpage = 2,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[PaymentService] Auth token is empty');
      }
      return PaymentListResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        payments: [],
        isTokenExpired: true,
      );
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.paymentList}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };
    final Map<String, dynamic> requestPayload = {
      'page': page,
      'perpage': perpage,
    };

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint(
        '[PaymentService] Calling paymentList endpoint (POST): $targetUrl with payload: $requestPayload',
      );
    }

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
            '[PaymentService] Web getPaymentList response status: ${httpResponse.statusCode}',
          );
          debugPrint(
            '[PaymentService] Web getPaymentList response body: ${httpResponse.body}',
          );
        }

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PaymentService] Web getPaymentList exception: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.paymentList,
          data: requestPayload,
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
            '[PaymentService] DioException in getPaymentList POST: $responseStatusCode',
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
          debugPrint('[PaymentService] Unexpected error in getPaymentList: $e');
        }
      }
    }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return PaymentListResult(
        success: false,
        message: 'Session expired',
        code: 401,
        payments: [],
        isTokenExpired: true,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final bool success =
          responseData['success'] == true || responseData['code'] == 200;
      final String message = responseData['message']?.toString() ?? 'success';
      final int code = responseData['code'] is int ? responseData['code'] : 200;

      final dataObj = responseData['data'];
      PaymentPageContext? pageContext;
      List<PaymentModel> paymentsList = [];

      if (dataObj is Map<String, dynamic>) {
        if (dataObj.containsKey('pagecontext') &&
            dataObj['pagecontext'] is Map<String, dynamic>) {
          pageContext = PaymentPageContext.fromJson(
            dataObj['pagecontext'] as Map<String, dynamic>,
          );
        }

        if (dataObj.containsKey('payments') && dataObj['payments'] is List) {
          final rawPayments = dataObj['payments'] as List;
          paymentsList = rawPayments
              .whereType<Map<String, dynamic>>()
              .map((p) => PaymentModel.fromJson(p))
              .toList();
        } else if (dataObj.containsKey('list') && dataObj['list'] is List) {
          final rawPayments = dataObj['list'] as List;
          paymentsList = rawPayments
              .whereType<Map<String, dynamic>>()
              .map((p) => PaymentModel.fromJson(p))
              .toList();
        } else if (dataObj.containsKey('items') && dataObj['items'] is List) {
          final rawPayments = dataObj['items'] as List;
          paymentsList = rawPayments
              .whereType<Map<String, dynamic>>()
              .map((p) => PaymentModel.fromJson(p))
              .toList();
        }
      } else if (responseData.containsKey('payments') &&
          responseData['payments'] is List) {
        final rawPayments = responseData['payments'] as List;
        paymentsList = rawPayments
            .whereType<Map<String, dynamic>>()
            .map((p) => PaymentModel.fromJson(p))
            .toList();
      }

      if (pageContext == null &&
          responseData.containsKey('pagecontext') &&
          responseData['pagecontext'] is Map<String, dynamic>) {
        pageContext = PaymentPageContext.fromJson(
          responseData['pagecontext'] as Map<String, dynamic>,
        );
      }

      return PaymentListResult(
        success: success,
        message: message,
        code: code,
        pageContext: pageContext,
        payments: paymentsList,
      );
    } else if (responseData is List) {
      final paymentsList = responseData
          .whereType<Map<String, dynamic>>()
          .map((p) => PaymentModel.fromJson(p))
          .toList();

      return PaymentListResult(
        success: true,
        message: 'success',
        code: 200,
        payments: paymentsList,
      );
    }

    return PaymentListResult(
      success: false,
      message: 'Failed to parse response data',
      code: responseStatusCode ?? 500,
      payments: [],
    );
  }

  /// Calls payments/v1/get-by-key API endpoint with payload {"paymentkey": paymentKey}.
  Future<PaymentDetailResult> getPaymentDetails({
    required String paymentKey,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[PaymentService] Auth token is empty in getPaymentDetails');
      }
      return PaymentDetailResult(
        success: false,
        message: 'Authentication token missing',
        code: 401,
        isTokenExpired: true,
      );
    }

    final String targetUrl =
        "${ApiManager.baseUrl}${ApiManager.paymentDetails}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };
    final Map<String, dynamic> requestPayload = {
      "paymentkey": paymentKey,
    };

    dynamic responseData;
    int? responseStatusCode;

    if (kDebugMode) {
      debugPrint(
        '[PaymentService] Calling paymentDetails endpoint (POST): $targetUrl with payload: $requestPayload',
      );
    }

    if (kIsWeb) {
      try {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(requestPayload),
        );
        responseStatusCode = httpResponse.statusCode;
        if (httpResponse.body.isNotEmpty) {
          try {
            responseData = jsonDecode(httpResponse.body);
          } catch (_) {}
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PaymentService] Web getPaymentDetails exception: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.paymentDetails,
          data: requestPayload,
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
            try {
              responseData = jsonDecode(response.data);
            } catch (_) {}
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PaymentService] Dio getPaymentDetails exception: $e');
        }
      }
    }

    if (_isTokenExpired(responseStatusCode, responseData)) {
      return PaymentDetailResult(
        success: false,
        message: 'Session expired',
        code: 401,
        isTokenExpired: true,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final bool success = responseData['success'] == true ||
          responseData['code'] == 200 ||
          responseStatusCode == 200;
      final String message = responseData['message']?.toString() ?? 'success';
      final int code = responseData['code'] is int
          ? responseData['code']
          : (responseStatusCode ?? 200);

      dynamic dataObj = responseData['data'];
      if (dataObj is List && dataObj.isNotEmpty) {
        dataObj = dataObj.first;
      }

      PaymentModel? paymentModel;
      Map<String, dynamic>? rawMap;

      if (dataObj is Map<String, dynamic>) {
        rawMap = dataObj;
        try {
          paymentModel = PaymentModel.fromJson(dataObj);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[PaymentService] Error parsing PaymentModel: $e');
          }
        }
      }

      return PaymentDetailResult(
        success: success,
        message: message,
        code: code,
        payment: paymentModel,
        rawData: rawMap,
      );
    }

    return PaymentDetailResult(
      success: false,
      message: 'Failed to parse payment details',
      code: responseStatusCode ?? 500,
    );
  }

  bool _isTokenExpired(int? statusCode, dynamic responseData) {
    if (statusCode == 401 || statusCode == 403) return true;
    if (responseData is Map) {
      final code =
          responseData['code'] ??
          responseData['status'] ??
          responseData['statusCode'];
      if (code == 401 || code == 403 || code == '401' || code == '403') {
        return true;
      }
      final msg =
          (responseData['message'] ??
                  responseData['error'] ??
                  responseData['msg'] ??
                  '')
              .toString()
              .toLowerCase();
      if (msg.contains('token expired') ||
          msg.contains('expired token') ||
          msg.contains('unauthorized') ||
          msg.contains('invalid token') ||
          msg.contains('token is required') ||
          msg.contains('unauthenticated') ||
          msg.contains('session expired')) {
        return true;
      }
    }
    return false;
  }
}
