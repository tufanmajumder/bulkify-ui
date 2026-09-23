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

    final Map<String, dynamic> payload = {"page": page, "perpage": perPage};

    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'perpage': perPage.toString(),
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
    int perPage = 1,
    String? status,
    String? token,
  }) async {
    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();

    if (activeToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[OrderService] Token missing — session expired');
      }
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

    final Map<String, dynamic> payload = {"page": page, "perpage": perPage};

    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'perpage': perPage.toString(),
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
    required String orderKey,
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

    final Map<String, dynamic> payload = {"orderkey": orderKey};

    if (kDebugMode) {
      debugPrint(
        '[OrderService] Fetching details for salesorder_id: $orderKey from $targetUrl',
      );
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
          debugPrint(
            '[OrderService] Web getOrderDetails status: ${httpResponse.statusCode}',
          );
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

  /// Downloads invoice PDF bytes by calling zoho/v1/invoice/download with {"invoice_id": invoiceId}.
  Future<List<int>?> downloadInvoice({
    required String invoiceId,
    String? token,
  }) async {
    final cleanInvoiceId = invoiceId.trim();
    if (cleanInvoiceId.isEmpty || cleanInvoiceId == 'null') return null;

    final String activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await AuthService.getAuthToken();
    final String targetUrl =
        "${ApiManager.baseUrl}${ApiManager.invoiceDownload}";
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/pdf, application/json, */*',
      'Authorization': 'Bearer $activeToken',
    };

    final Map<String, dynamic> payload = {"invoice_id": cleanInvoiceId};

    if (kDebugMode) {
      debugPrint(
        '[OrderService] Requesting invoice with payload: $payload from $targetUrl',
      );
    }

    try {
      List<int>? rawBytes;
      if (kIsWeb) {
        final httpResponse = await http.post(
          Uri.parse(targetUrl),
          headers: requestHeaders,
          body: jsonEncode(payload),
        );

        if (kDebugMode) {
          final snippet = httpResponse.body.length > 200
              ? httpResponse.body.substring(0, 200)
              : httpResponse.body;
          debugPrint(
            '[OrderService] Web downloadInvoice POST (invoice_id: $cleanInvoiceId) status: ${httpResponse.statusCode}, snippet: $snippet',
          );
        }

        if (httpResponse.statusCode >= 200 &&
            httpResponse.statusCode < 300 &&
            httpResponse.bodyBytes.isNotEmpty) {
          rawBytes = httpResponse.bodyBytes;
        }
      }

      if (rawBytes == null) {
        final response = await dio.post(
          ApiManager.invoiceDownload,
          data: jsonEncode(payload),
          options: Options(
            responseType: ResponseType.bytes,
            headers: requestHeaders,
          ),
        );
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300 &&
            response.data != null) {
          if (response.data is List<int>) {
            rawBytes = response.data as List<int>;
          }
        }
      }

      if (rawBytes != null && rawBytes.isNotEmpty) {
        final validPdf = await _extractValidPdfBytes(rawBytes);
        if (validPdf != null && validPdf.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[OrderService] Successfully extracted valid PDF (${validPdf.length} bytes)',
            );
          }
          return validPdf;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderService] downloadInvoice exception: $e');
      }
    }

    return null;
  }

  Future<List<int>?> _extractValidPdfBytes(List<int>? rawBytes) async {
    if (rawBytes == null || rawBytes.isEmpty) return null;

    if (kDebugMode) {
      debugPrint(
        '[OrderService] Processing rawBytes (${rawBytes.length} bytes)',
      );
    }

    // 1. Direct PDF magic header check (%PDF-)
    if (_isPdfBytes(rawBytes)) {
      return rawBytes;
    }

    // 2. Decode as UTF-8 string to check for JSON, HTML, Base64, or URL
    String text;
    try {
      text = utf8.decode(rawBytes).trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[OrderService] rawBytes UTF-8 decode failed: $e. Returning rawBytes as binary fallback.',
        );
      }
      return rawBytes;
    }

    if (text.isEmpty) return null;

    // HTML error response check
    final lowerText = text.toLowerCase();
    if (lowerText.startsWith('<!doctype html') ||
        lowerText.startsWith('<html')) {
      if (kDebugMode) {
        debugPrint(
          '[OrderService] HTML error response received instead of PDF',
        );
      }
      return null;
    }

    // 3. Try parsing as JSON
    if (text.startsWith('{') || text.startsWith('[')) {
      try {
        final decodedJson = jsonDecode(text);
        final pdfBytes = await _extractPdfFromJson(decodedJson);
        if (pdfBytes != null) return pdfBytes;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OrderService] Error parsing JSON PDF response: $e');
        }
      }
      if (kDebugMode) {
        debugPrint(
          '[OrderService] JSON response did not contain valid PDF content: $text',
        );
      }
      return null;
    }

    // 4. Try parsing as raw Base64 string or Data URI
    final pdfFromBase64 = _tryDecodeBase64(text);
    if (pdfFromBase64 != null) return pdfFromBase64;

    // 5. Try parsing as HTTP/HTTPS URL
    if (text.startsWith('http://') || text.startsWith('https://')) {
      return await _fetchPdfFromUrl(text);
    }

    // 6. Binary fallback for non-text payloads
    if (rawBytes.length > 100) {
      if (kDebugMode) {
        debugPrint(
          '[OrderService] Fallback: returning rawBytes (${rawBytes.length} bytes)',
        );
      }
      return rawBytes;
    }

    return null;
  }

  Future<List<int>?> _extractPdfFromJson(dynamic json) async {
    if (json is Map) {
      final keysToCheck = [
        'data',
        'file',
        'file_content',
        'pdf',
        'base64',
        'content',
        'result',
        'response',
        'invoice',
        'invoice_pdf',
        'pdf_content',
        'document',
        'file_data',
        'blob',
        'url',
        'pdf_url',
        'file_url',
        'download_url',
      ];

      // Check priority keys first
      for (final key in keysToCheck) {
        final val = json[key];
        if (val is String && val.trim().isNotEmpty) {
          final strVal = val.trim();
          if (strVal.startsWith('http://') || strVal.startsWith('https://')) {
            final fetched = await _fetchPdfFromUrl(strVal);
            if (fetched != null) return fetched;
          }
          final b64Decoded = _tryDecodeBase64(strVal);
          if (b64Decoded != null) return b64Decoded;
        }
      }

      // Check all map fields recursively
      for (final entry in json.entries) {
        if (entry.value is String && entry.value.toString().trim().isNotEmpty) {
          final strVal = entry.value.toString().trim();
          if (strVal.startsWith('http://') || strVal.startsWith('https://')) {
            final fetched = await _fetchPdfFromUrl(strVal);
            if (fetched != null) return fetched;
          }
          final b64Decoded = _tryDecodeBase64(strVal);
          if (b64Decoded != null) return b64Decoded;
        } else if (entry.value is Map || entry.value is List) {
          final res = await _extractPdfFromJson(entry.value);
          if (res != null) return res;
        }
      }
    } else if (json is List && json.isNotEmpty) {
      for (final item in json) {
        final res = await _extractPdfFromJson(item);
        if (res != null) return res;
      }
    }

    return null;
  }

  List<int>? _tryDecodeBase64(String rawInput) {
    var clean = rawInput.trim();
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    if (clean.contains(';base64,')) {
      clean = clean.split(';base64,').last.trim();
    } else if (clean.startsWith('data:')) {
      final commaIndex = clean.indexOf(',');
      if (commaIndex != -1) {
        clean = clean.substring(commaIndex + 1).trim();
      }
    }
    clean = clean.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return null;

    // Convert URL-safe base64 (- and _) to standard (+ and /)
    var normalized = clean.replaceAll('-', '+').replaceAll('_', '/');
    // Add missing base64 padding =
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }

    try {
      final decoded = base64Decode(normalized);
      if (decoded.isNotEmpty) {
        if (_isPdfBytes(decoded) || decoded.length > 50) {
          return decoded;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderService] _tryDecodeBase64 error: $e');
      }
    }
    return null;
  }

  bool _isPdfBytes(List<int> bytes) {
    if (bytes.length < 5) return false;
    if (bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2D) {
      return true;
    }
    final maxSearch = bytes.length < 1024 ? bytes.length - 4 : 1020;
    for (int i = 0; i < maxSearch; i++) {
      if (bytes[i] == 0x25 &&
          bytes[i + 1] == 0x50 &&
          bytes[i + 2] == 0x44 &&
          bytes[i + 3] == 0x46 &&
          bytes[i + 4] == 0x2D) {
        return true;
      }
    }
    return false;
  }

  Future<List<int>?> _fetchPdfFromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          res.bodyBytes.isNotEmpty) {
        if (_isPdfBytes(res.bodyBytes)) {
          return res.bodyBytes;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderService] Error fetching PDF from URL ($url): $e');
      }
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
