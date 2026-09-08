import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/order_service.dart';

class PaymentTransactionModel {
  final String issuedBy;
  final String createdOn;
  final String paymentId;
  final String paymentMethod;
  final String rrnUtr;
  final String status;
  final String amount;

  PaymentTransactionModel({
    required this.issuedBy,
    required this.createdOn,
    required this.paymentId,
    required this.paymentMethod,
    required this.rrnUtr,
    required this.status,
    required this.amount,
  });
}

class OrderItemModel {
  final String name;
  final String merchant;
  final String price;
  final int qty;
  final String total;

  OrderItemModel({
    required this.name,
    required this.merchant,
    required this.price,
    required this.qty,
    required this.total,
  });
}

class DocumentModel {
  final String title;
  final String code;

  DocumentModel({required this.title, required this.code});
}

class ShippingActivityModel {
  final String title;
  final String timestamp;
  final String description;
  final bool isCompleted;
  final String? highlightText;

  ShippingActivityModel({
    required this.title,
    required this.timestamp,
    required this.description,
    this.isCompleted = true,
    this.highlightText,
  });
}

class OrderDetailsController extends GetxController {
  final OrderService _orderService = Get.put(OrderService());

  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;

  // Summary Fields
  final RxString orderNo = ''.obs;
  final RxString date = ''.obs;
  final RxString time = ''.obs;
  final RxString customer = ''.obs;
  final RxString company = ''.obs;
  final RxString paymentMethod = ''.obs;
  final RxString shipmentStatus = ''.obs;

  // Shipping Address
  final RxString shippingName = ''.obs;
  final RxString shippingPhone = ''.obs;
  final RxString shippingAddress = ''.obs;
  final RxString shippingPincode = ''.obs;

  // Billing Address
  final RxString billingName = ''.obs;
  final RxString billingPhone = ''.obs;
  final RxString billingAddress = ''.obs;
  final RxString billingPincode = ''.obs;

  // Price Breakdown
  final RxString subtotal = ''.obs;
  final RxString shippingFee = ''.obs;
  final RxString platformFee = ''.obs;
  final RxString bankFee = ''.obs;
  final RxString discountPercent = ''.obs;
  final RxString couponDiscount = ''.obs;
  final RxString tax = ''.obs;
  final RxString cgst = ''.obs;
  final RxString sgst = ''.obs;
  final RxString grandTotal = ''.obs;

  // Documents List
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;

  // Payment Transactions List
  final RxList<PaymentTransactionModel> transactions =
      <PaymentTransactionModel>[].obs;

  // Order Items List
  final RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;

  // Shipping Activity Timeline
  final RxList<ShippingActivityModel> shippingActivities =
      <ShippingActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    String salesorderId = '';

    final args = Get.arguments;
    if (args is OrderModel) {
      selectedOrder.value = args;
      salesorderId = args.salesorderId.isNotEmpty ? args.salesorderId : args.id;
      if (args.id.isNotEmpty && args.id != '-') {
        orderNo.value = args.id.startsWith('#') ? args.id : '#${args.id}';
      }
      if (args.customerName.isNotEmpty && args.customerName != '-') {
        customer.value = args.customerName;
      }
      if (args.companyName.isNotEmpty) {
        company.value = args.companyName;
      }
      if (args.paymentStatus.isNotEmpty) {
        paymentMethod.value = args.paymentStatus;
      }
      if (args.orderStatus.isNotEmpty) {
        shipmentStatus.value = args.orderStatus;
      }
      if (args.amount.isNotEmpty) {
        grandTotal.value = args.amount;
      }
      if (args.date.isNotEmpty && args.date != '-') {
        final parts = args.date.split(' ');
        if (parts.isNotEmpty) date.value = parts[0];
        if (parts.length > 1) {
          time.value = parts.sublist(1).join(' ');
        }
      }
    } else if (args is String) {
      salesorderId = args;
    }

    if (salesorderId.startsWith('#')) {
      salesorderId = salesorderId.substring(1);
    }

    if (salesorderId.isNotEmpty) {
      fetchOrderDetails(salesorderId);
    }
  }

  Future<void> fetchOrderDetails(String salesorderId) async {
    final cleanId = salesorderId.trim();
    if (cleanId.isEmpty) return;

    isLoading.value = true;
    isError.value = false;

    try {
      final responseMap = await _orderService.getOrderDetails(
        salesorderId: cleanId,
      );
      if (responseMap != null) {
        _populateFromApiResponse(responseMap);
      } else {
        if (kDebugMode) {
          debugPrint('[OrderDetailsController] API returned null response');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderDetailsController] Error fetching details: $e');
      }
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deeply drills down into response map to find the map containing actual order data
  Map<String, dynamic> _extractTargetOrderMap(
    Map<String, dynamic> responseMap,
  ) {
    if (kDebugMode) {
      debugPrint('[OrderDetailsController] Raw responseMap: $responseMap');
    }

    Map<String, dynamic> current = responseMap;

    for (int i = 0; i < 5; i++) {
      if (current.containsKey('salesorder_number') ||
          current.containsKey('customer_name') ||
          current.containsKey('line_items') ||
          current.containsKey('salesorder_id') ||
          current.containsKey('paid_status')) {
        return current;
      }

      if (current.containsKey('salesorder') &&
          current['salesorder'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['salesorder']);
        continue;
      }
      if (current.containsKey('sales_order') &&
          current['sales_order'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['sales_order']);
        continue;
      }
      if (current.containsKey('data') &&
          current['data'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['data']);
        continue;
      }
      if (current.containsKey('result') &&
          current['result'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['result']);
        continue;
      }
      if (current.containsKey('order') &&
          current['order'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['order']);
        continue;
      }
      if (current.containsKey('data') &&
          current['data'] is List &&
          (current['data'] as List).isNotEmpty &&
          (current['data'] as List)[0] is Map) {
        current = Map<String, dynamic>.from((current['data'] as List)[0]);
        continue;
      }
      break;
    }

    return current;
  }

  void _populateFromApiResponse(Map<String, dynamic> responseMap) {
    final data = _extractTargetOrderMap(responseMap);

    // 1. Summary details (if key is missing, make blank "")
    final num =
        data['salesorder_number'] ??
        data['salesorder_no'] ??
        data['order_number'] ??
        data['ordernumber'] ??
        data['salesorder_id'] ??
        data['order_id'] ??
        data['id'];

    if (num != null && num.toString().trim().isNotEmpty) {
      final numStr = num.toString().trim();
      orderNo.value = numStr.startsWith('#') ? numStr : '#$numStr';
    } else {
      orderNo.value = '';
    }

    final dateVal =
        data['date'] ??
        data['salesorder_date'] ??
        data['created_time'] ??
        data['created_at'];
    date.value = dateVal != null ? _formatDateOnly(dateVal.toString()) : '';

    final timeVal = data['time'] ?? data['created_time'] ?? data['created_at'];
    time.value = timeVal != null ? _formatTimeOnly(timeVal.toString()) : '';

    customer.value =
        (data['customer_name'] ??
                data['customerName'] ??
                data['customer'] ??
                data['name'])
            ?.toString() ??
        '';

    company.value =
        (data['company_name'] ??
                data['companyName'] ??
                data['company'] ??
                data['restaurant_name'] ??
                data['restaurantname'] ??
                data['resturentname'])
            ?.toString() ??
        '';

    paymentMethod.value =
        (data['paid_status'] ??
                data['payment_status'] ??
                data['payment_mode'] ??
                data['payment_method'] ??
                data['payment'])
            ?.toString() ??
        '';

    shipmentStatus.value =
        (data['shipped_status'] ??
                data['shipment_status'] ??
                data['status'] ??
                data['salesorder_status'] ??
                data['order_status'])
            ?.toString() ??
        '';

    // 2. Shipping Address (if key missing -> blank "")
    final shipMap =
        data['shipping_address'] ??
        data['shippingAddress'] ??
        data['shipping'] ??
        data['delivery_address'];
    if (shipMap is Map) {
      shippingName.value =
          (shipMap['attention'] ??
                  shipMap['name'] ??
                  shipMap['customer_name'] ??
                  shipMap['recipient_name'])
              ?.toString() ??
          '';
      shippingPhone.value =
          (shipMap['phone'] ?? shipMap['mobile'] ?? shipMap['contact'])
              ?.toString() ??
          '';
      shippingAddress.value =
          (shipMap['address'] ??
                  shipMap['street'] ??
                  shipMap['address_1'] ??
                  _buildAddressString(shipMap))
              ?.toString() ??
          '';
      shippingPincode.value =
          (shipMap['zip'] ??
                  shipMap['pincode'] ??
                  shipMap['zip_code'] ??
                  shipMap['postal_code'])
              ?.toString() ??
          '';
    } else if (shipMap is String) {
      shippingAddress.value = shipMap;
      shippingName.value = '';
      shippingPhone.value = '';
      shippingPincode.value = '';
    } else {
      shippingName.value = '';
      shippingPhone.value = '';
      shippingAddress.value = '';
      shippingPincode.value = '';
    }

    // 3. Billing Address (if key missing -> blank "")
    final billMap =
        data['billing_address'] ?? data['billingAddress'] ?? data['billing'];
    if (billMap is Map) {
      billingName.value =
          (billMap['attention'] ?? billMap['name'] ?? billMap['customer_name'])
              ?.toString() ??
          '';
      billingPhone.value =
          (billMap['phone'] ?? billMap['mobile'] ?? billMap['contact'])
              ?.toString() ??
          '';
      billingAddress.value =
          (billMap['address'] ??
                  billMap['street'] ??
                  billMap['address_1'] ??
                  _buildAddressString(billMap))
              ?.toString() ??
          '';
      billingPincode.value =
          (billMap['zip'] ??
                  billMap['pincode'] ??
                  billMap['zip_code'] ??
                  billMap['postal_code'])
              ?.toString() ??
          '';
    } else if (billMap is String) {
      billingAddress.value = billMap;
      billingName.value = '';
      billingPhone.value = '';
      billingPincode.value = '';
    } else {
      billingName.value = '';
      billingPhone.value = '';
      billingAddress.value = '';
      billingPincode.value = '';
    }

    // 4. Price Breakdown (if key missing -> blank "")
    subtotal.value = _formatPriceVal(
      data['sub_total'] ??
          data['subtotal'] ??
          data['sub_total_inclusive_of_tax'],
    );
    shippingFee.value = _formatPriceVal(
      data['shipping_charge'] ??
          data['shipping_fee'] ??
          data['shipping_charges'],
    );
    platformFee.value = _formatPriceVal(
      data['platform_fee'] ?? data['platform_charge'],
    );
    bankFee.value = _formatPriceVal(data['bank_fee'] ?? data['bank_charge']);
    discountPercent.value = _formatPriceVal(
      data['discount'] ?? data['discount_total'] ?? data['discount_amount'],
    );
    couponDiscount.value = _formatPriceVal(
      data['coupon_discount'] ?? data['coupon_amount'],
    );
    tax.value = _formatPriceVal(
      data['tax_total'] ?? data['tax'] ?? data['tax_amount'],
    );
    cgst.value = _formatPriceVal(data['cgst'] ?? data['cgst_amount']);
    sgst.value = _formatPriceVal(data['sgst'] ?? data['sgst_amount']);
    grandTotal.value = _formatPriceVal(
      data['total'] ?? data['grand_total'] ?? data['amount'],
    );

    // 5. Documents (if key missing -> empty list)
    final docsList = data['documents'] ?? data['document_list'] ?? data['docs'];
    if (docsList is List && docsList.isNotEmpty) {
      documents.assignAll(
        docsList.map((d) {
          if (d is Map) {
            return DocumentModel(
              title:
                  (d['title'] ??
                          d['name'] ??
                          d['type'] ??
                          d['document_type'] ??
                          'Document')
                      .toString(),
              code:
                  (d['code'] ??
                          d['document_number'] ??
                          d['doc_number'] ??
                          d['id'] ??
                          '')
                      .toString(),
            );
          }
          return DocumentModel(title: 'Document', code: d.toString());
        }).toList(),
      );
    } else {
      documents.clear();
    }

    // 6. Payment Transactions (if key missing -> empty list)
    final txList =
        data['payments'] ??
        data['transactions'] ??
        data['payment_transactions'];
    if (txList is List && txList.isNotEmpty) {
      transactions.assignAll(
        txList.map((tx) {
          if (tx is Map) {
            return PaymentTransactionModel(
              issuedBy:
                  (tx['issued_by'] ??
                          tx['issuedBy'] ??
                          tx['payment_mode'] ??
                          tx['gateway'] ??
                          tx['bank'] ??
                          '')
                      .toString(),
              createdOn:
                  (tx['created_on'] ??
                          tx['created_time'] ??
                          tx['date'] ??
                          tx['created_at'] ??
                          '')
                      .toString(),
              paymentId:
                  (tx['payment_id'] ??
                          tx['transaction_id'] ??
                          tx['payment_number'] ??
                          '')
                      .toString(),
              paymentMethod:
                  (tx['payment_method'] ??
                          tx['payment_type'] ??
                          tx['type'] ??
                          '')
                      .toString(),
              rrnUtr:
                  (tx['rrn_utr'] ??
                          tx['rrn'] ??
                          tx['utr'] ??
                          tx['reference_number'] ??
                          '')
                      .toString(),
              status: (tx['status'] ?? tx['payment_status'] ?? '').toString(),
              amount: _formatPriceVal(tx['amount'] ?? tx['total']),
            );
          }
          return PaymentTransactionModel(
            issuedBy: '',
            createdOn: '',
            paymentId: '',
            paymentMethod: '',
            rrnUtr: '',
            status: '',
            amount: '',
          );
        }).toList(),
      );
    } else {
      transactions.clear();
    }

    // 7. Order Items (if key missing -> empty list)
    final itemsList =
        data['line_items'] ??
        data['order_items'] ??
        data['items'] ??
        data['products'];
    if (itemsList is List && itemsList.isNotEmpty) {
      orderItems.assignAll(
        itemsList.map((item) {
          if (item is Map) {
            final qtyVal =
                int.tryParse(
                  item['quantity']?.toString() ??
                      item['qty']?.toString() ??
                      '0',
                ) ??
                0;
            return OrderItemModel(
              name:
                  (item['name'] ??
                          item['item_name'] ??
                          item['product_name'] ??
                          item['item_description'] ??
                          '')
                      .toString(),
              merchant:
                  (item['merchant_name'] ??
                          item['vendor'] ??
                          item['brand'] ??
                          item['seller_name'] ??
                          '')
                      .toString(),
              price: _formatPriceVal(
                item['rate'] ?? item['price'] ?? item['unit_price'],
              ),
              qty: qtyVal,
              total: _formatPriceVal(
                item['item_total'] ?? item['total'] ?? item['line_total'],
              ),
            );
          }
          return OrderItemModel(
            name: '',
            merchant: '',
            price: '',
            qty: 0,
            total: '',
          );
        }).toList(),
      );
    } else {
      orderItems.clear();
    }

    // 8. Shipping Activities (if key missing -> empty list)
    final actList =
        data['shipping_activities'] ??
        data['activities'] ??
        data['history'] ??
        data['tracking'];
    if (actList is List && actList.isNotEmpty) {
      shippingActivities.assignAll(
        actList.map((act) {
          if (act is Map) {
            return ShippingActivityModel(
              title: (act['title'] ?? act['status'] ?? act['event'] ?? '')
                  .toString(),
              timestamp: (act['timestamp'] ?? act['time'] ?? act['date'] ?? '')
                  .toString(),
              description:
                  (act['description'] ?? act['details'] ?? act['notes'] ?? '')
                      .toString(),
              isCompleted: act['is_completed'] ?? act['completed'] ?? true,
              highlightText: act['highlight_text']?.toString(),
            );
          }
          return ShippingActivityModel(
            title: '',
            timestamp: '',
            description: '',
          );
        }).toList(),
      );
    } else {
      shippingActivities.clear();
    }
  }

  String _formatPriceVal(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '';
    final parsed = double.tryParse(str);
    if (parsed != null) {
      return '₹ ${parsed.toStringAsFixed(2)}';
    }
    return str;
  }

  String _formatDateOnly(String raw) {
    if (raw.isEmpty || raw == 'null') return '';
    if (raw.contains(' ')) {
      return raw.split(' ')[0];
    }
    return raw;
  }

  String _formatTimeOnly(String raw) {
    if (raw.isEmpty || raw == 'null') return '';
    if (raw.contains(' ')) {
      final parts = raw.split(' ');
      if (parts.length > 1) {
        return parts.sublist(1).join(' ');
      }
    }
    return raw;
  }

  String _buildAddressString(Map map) {
    final parts = [
      map['address'],
      map['street'],
      map['address_1'],
      map['city'],
      map['state'],
      map['country'],
    ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  void downloadDocument(DocumentModel doc) {
    Get.snackbar(
      'Download Started',
      'Downloading ${doc.title} (${doc.code})...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void downloadReceipt(PaymentTransactionModel transaction) {
    Get.snackbar(
      'Receipt Download',
      'Downloading receipt for ${transaction.issuedBy} (${transaction.rrnUtr})...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
