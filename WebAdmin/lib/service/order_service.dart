import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/utils/api_manager.dart';

class OrderService extends GetxService {
  // Throws on 401/403 so auth failures are caught explicitly in DioException.
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

  /// Calls getOrderList API endpoint.
  Future<List<OrderModel>> getOrderList({
    int page = 1,
    int perPage = 10,
    String? status,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();
    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.getOrderList}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {"page": page, "per_page": perPage};

    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    dynamic responseData;

    // Web: call the backend directly.
    // NOTE: The backend must have CORS headers configured for browser requests.
    // Public CORS proxies have been removed for security — they received full
    // request bodies including Bearer tokens and order PII.
    if (kIsWeb) {
      try {
        http.Response httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );

        if (httpResponse.statusCode < 200 ||
            httpResponse.statusCode >= 300 ||
            httpResponse.body.isEmpty) {
          final baseUri = Uri.parse(targetUrl);
          final uri = baseUri.replace(
            queryParameters: {...baseUri.queryParameters, ...queryParams},
          );
          httpResponse = await http.get(uri, headers: requestHeaders);
        }

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderService] Web getOrderList request failed: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.getOrderList,
          data: jsonEncode(payload),
          options: Options(
            contentType: Headers.jsonContentType,
            headers: requestHeaders,
          ),
        );

        if (response.data != null) {
          if (response.data is Map<String, dynamic> || response.data is List) {
            responseData = response.data;
          } else if (response.data is String) {
            responseData = jsonDecode(response.data);
          }
        }
      } on DioException catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[OrderService] DioException in getOrderList: ${e.response?.statusCode}',
          );
        }
        try {
          final response = await dio.get(
            ApiManager.getOrderList,
            queryParameters: queryParams,
            options: Options(
              contentType: Headers.jsonContentType,
              headers: requestHeaders,
            ),
          );
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
          debugPrint('[OrderService] Unexpected error in getOrderList: $e');
        }
      }
    }

    if (responseData != null) {
      final parsed = _parseOrders(responseData);
      final hasMore = extractHasMorePage(responseData);
      if (kDebugMode) {
        debugPrint(
          '[OrderService] Parsed ${parsed.length} orders. HasMorePage: $hasMore',
        );
      }
      return parsed;
    }

    return [];
  }

  bool extractHasMorePage(
    dynamic responseData, {
    int fetchedCount = 0,
    int perPage = 10,
  }) {
    if (responseData != null) {
      bool? toBool(dynamic val) {
        if (val == null) return null;
        if (val is bool) return val;
        if (val is int || val is double) return val == 1;
        if (val is String) {
          final s = val.trim().toLowerCase();
          if (s == 'true' || s == '1' || s == 'yes') return true;
          if (s == 'false' || s == '0' || s == 'no') return false;
        }
        return null;
      }

      bool? searchMap(dynamic node) {
        if (node is Map) {
          for (final key in [
            'has_more_page',
            'has_more_pages',
            'has_more',
            'has_next_page',
            'has_next',
            'hasmorepage',
            'hasmore',
          ]) {
            if (node.containsKey(key)) {
              final b = toBool(node[key]);
              if (b != null) return b;
            }
          }
          for (final entry in node.entries) {
            if (entry.key == 'salesorders' ||
                entry.key == 'items' ||
                entry.key == 'orders') {
              continue;
            }
            final res = searchMap(entry.value);
            if (res != null) return res;
          }
        } else if (node is List) {
          for (final item in node) {
            final res = searchMap(item);
            if (res != null) return res;
          }
        }
        return null;
      }

      final explicitValue = searchMap(responseData);
      if (explicitValue != null) {
        return explicitValue;
      }
    }

    return fetchedCount > 0 && fetchedCount >= perPage;
  }

  bool isTokenExpiredResponse(int? statusCode, dynamic responseData) {
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
          msg.contains('token invalid') ||
          msg.contains('session expired')) {
        return true;
      }
    }
    return false;
  }

  Future<OrderListResult> getOrderListResult({
    int page = 1,
    int perPage = 10,
    String? status,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode)
        debugPrint('[OrderService] Token missing — session expired');
      return OrderListResult(
        orders: [],
        hasMorePage: false,
        isTokenExpired: true,
      );
    }

    final String targetUrl = "${ApiManager.baseUrl}${ApiManager.getOrderList}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {"page": page, "per_page": perPage};

    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    dynamic responseData;
    int? responseStatusCode;

    // Web: call the backend directly.
    // NOTE: The backend must have CORS headers configured for browser requests.
    // Public CORS proxies have been removed for security.
    if (kIsWeb) {
      try {
        http.Response httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );

        if (httpResponse.statusCode < 200 ||
            httpResponse.statusCode >= 300 ||
            httpResponse.body.isEmpty) {
          final baseUri = Uri.parse(targetUrl);
          final uri = baseUri.replace(
            queryParameters: {...baseUri.queryParameters, ...queryParams},
          );
          httpResponse = await http.get(uri, headers: requestHeaders);
        }

        responseStatusCode = httpResponse.statusCode;

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderService] Web getOrderListResult failed: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.getOrderList,
          data: jsonEncode(payload),
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
            '[OrderService] DioException in getOrderListResult: $responseStatusCode',
          );
        }
        try {
          final response = await dio.get(
            ApiManager.getOrderList,
            queryParameters: queryParams,
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
      } catch (_) {}
    }

    if (isTokenExpiredResponse(responseStatusCode, responseData)) {
      if (kDebugMode) debugPrint('[OrderService] Token expiration detected');
      return OrderListResult(
        orders: [],
        hasMorePage: false,
        isTokenExpired: true,
      );
    }

    final orders = responseData != null
        ? _parseOrders(responseData)
        : <OrderModel>[];
    final hasMore = responseData != null
        ? extractHasMorePage(
            responseData,
            fetchedCount: orders.length,
            perPage: perPage,
          )
        : false;

    if (kDebugMode) {
      debugPrint(
        '[OrderService] Result: ${orders.length} orders, hasMorePage: $hasMore',
      );
    }

    return OrderListResult(
      orders: orders,
      hasMorePage: hasMore,
      isTokenExpired: false,
    );
  }

  List<OrderModel> _parseOrders(dynamic responseData) {
    List rawItems = [];

    if (responseData is List) {
      rawItems = responseData;
    } else if (responseData is Map) {
      final dataField = responseData['data'];
      if (dataField is List) {
        rawItems = dataField;
      } else if (dataField is Map) {
        final innerList =
            dataField['salesorders'] ??
            dataField['salesorder_list'] ??
            dataField['items'] ??
            dataField['orders'] ??
            dataField['orderlist'] ??
            dataField['list'] ??
            dataField['data'];
        if (innerList is List) {
          rawItems = innerList;
        }
      } else {
        final rootList =
            responseData['salesorders'] ??
            responseData['salesorder_list'] ??
            responseData['items'] ??
            responseData['orders'] ??
            responseData['orderlist'] ??
            responseData['list'];
        if (rootList is List) {
          rawItems = rootList;
        }
      }
    }

    final List<OrderModel> orders = [];
    for (var item in rawItems) {
      if (item is Map) {
        try {
          final Map<String, dynamic> mapItem = Map<String, dynamic>.from(item);
          orders.add(OrderModel.fromJson(mapItem));
        } catch (e) {
          if (kDebugMode) debugPrint('[OrderService] Error parsing order: $e');
        }
      }
    }

    return orders;
  }

  /// Calls getOrderDetails API endpoint (zoho/v1/salesorder/get) with {"salesorder_id": salesorderId}
  Future<Map<String, dynamic>?> getOrderDetails({
    required String salesorderId,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();
    final String targetUrl =
        "${ApiManager.baseUrl}${ApiManager.getOrderDetails}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {
      "salesorder_id": salesorderId,
    };

    if (kDebugMode) {
      debugPrint('[OrderService] Fetching details for salesorder_id: $salesorderId from $targetUrl');
    }

    dynamic responseData;

    if (kIsWeb) {
      try {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );

        if (kDebugMode) {
          debugPrint('[OrderService] Web getOrderDetails status: ${httpResponse.statusCode}');
        }

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 500 &&
            httpResponse.body.isNotEmpty) {
          responseData = jsonDecode(httpResponse.body);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderService] Web getOrderDetails exception: $e');
        }
      }
    }

    if (responseData == null) {
      try {
        final response = await dio.post(
          ApiManager.getOrderDetails,
          data: jsonEncode(payload),
          options: Options(
            contentType: Headers.jsonContentType,
            headers: requestHeaders,
          ),
        );
        if (response.data != null) {
          if (response.data is Map<String, dynamic>) {
            responseData = response.data;
          } else if (response.data is String) {
            responseData = jsonDecode(response.data);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderService] Dio getOrderDetails exception: $e');
        }
      }
    }

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    return null;
  }
}

class OrderListResult {
  final List<OrderModel> orders;
  final bool hasMorePage;
  final bool isTokenExpired;

  OrderListResult({
    required this.orders,
    required this.hasMorePage,
    this.isTokenExpired = false,
  });
}
