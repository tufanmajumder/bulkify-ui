import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/order_service.dart';
import 'package:admin_app/utils/blob_downloader.dart';
import 'package:intl/intl.dart';

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

class LineItemTaxModel {
  final String taxName;
  final String taxAmount;
  final double taxPercent;

  LineItemTaxModel({
    required this.taxName,
    required this.taxAmount,
    this.taxPercent = 0.0,
  });
}

class OrderItemModel {
  final String name;
  final String itemType;
  final String description;
  final String price;
  final int qty;
  final String total;
  final List<LineItemTaxModel> lineItemTaxes;
  final RxBool isAccepted;
  final RxBool isRejected;

  OrderItemModel({
    required this.name,
    required this.itemType,
    required this.description,
    required this.price,
    required this.qty,
    required this.total,
    this.lineItemTaxes = const [],
    bool initialAccepted = false,
    bool initialRejected = false,
  }) : isAccepted = initialAccepted.obs,
       isRejected = initialRejected.obs;

  String get merchant => description;
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
  final RxString orderKey = ''.obs;
  final RxString orderId = ''.obs;
  final RxString customerId = ''.obs;
  final RxBool isSubmittingPayment = false.obs;
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
  final RxString couponCode = '#WELCOME10'.obs;
  final RxString tax = ''.obs;
  final RxString cgst = ''.obs;
  final RxString sgst = ''.obs;
  final RxString igst = ''.obs;
  final RxString grandTotal = ''.obs;

  // Invoice details
  final RxString invoiceId = ''.obs;
  final RxString invoiceNumber = ''.obs;
  final RxBool isDownloadingInvoice = false.obs;
  final RxBool isInvoiceDownloaded = false.obs;

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

  final ScrollController leftScrollController = ScrollController();
  final ScrollController rightScrollController = ScrollController();

  @override
  void onClose() {
    leftScrollController.dispose();
    rightScrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    String salesorderId = '';

    final args = Get.arguments;
    if (args is OrderModel) {
      selectedOrder.value = args;
      salesorderId = args.orderkey;
      if (args.id.isNotEmpty && args.id != '-') {
        orderNo.value = args.id;
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
        grandTotal.value = _formatPriceVal(args.amount);
      }
      if (args.date.isNotEmpty && args.date != '-') {
        date.value = formatDateOnly(args.date);
        time.value = formatDateOnly(args.date);
      }
    } else if (args is String) {
      salesorderId = args;
    } else if (Get.parameters.containsKey('orderkey')) {
      salesorderId = Get.parameters['orderkey'] ?? '';
    } else if (Get.parameters.containsKey('id')) {
      salesorderId = Get.parameters['id'] ?? '';
    }

    if (salesorderId.startsWith('#')) {
      salesorderId = salesorderId.substring(1);
    }

    salesorderId = salesorderId.trim();

    if (salesorderId.isNotEmpty) {
      fetchOrderDetails(salesorderId);
    } else {
      _redirectToOrderList('Order key not found');
    }
  }

  bool _isRedirecting = false;

  void _redirectToOrderList([String? message]) {
    if (_isRedirecting) return;
    _isRedirecting = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != '/orders') {
        Get.offAllNamed('/orders');
      }
      if (message != null && message.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // Get.snackbar(
          //   'Order Not Found',
          //   message,
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: const Color(0xFFEF4444),
          //   colorText: Colors.white,
          //   margin: const EdgeInsets.all(16),
          //   duration: const Duration(seconds: 3),
          // );
        });
      }
    });
  }

  Future<void> fetchOrderDetails(String salesorderId) async {
    //print("salesorderId...$salesorderId");
    final cleanId = salesorderId.trim();
    if (cleanId.isEmpty) {
      _redirectToOrderList('Order key not found');
      return;
    }

    orderKey.value = cleanId;
    isLoading.value = true;
    isError.value = false;
    isInvoiceDownloaded.value = false;

    try {
      final responseMap = await _orderService.getOrderDetails(
        orderKey: cleanId,
      );
      if (responseMap != null) {
        final isSuccess = responseMap['success'] ?? responseMap['status'];
        final message =
            (responseMap['message'] ??
                    responseMap['error'] ??
                    responseMap['msg'] ??
                    '')
                .toString();

        if (isSuccess == false ||
            isSuccess == 0 ||
            message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('no order')) {
          isError.value = true;
          _redirectToOrderList(
            message.isNotEmpty ? message : 'Order not found for key: $cleanId',
          );
          return;
        }

        _populateFromApiResponse(responseMap);

        if (orderNo.value.isEmpty && orderItems.isEmpty) {
          isError.value = true;
          _redirectToOrderList('Order not found for key: $cleanId');
          return;
        }
      } else {
        isError.value = true;
        _redirectToOrderList('Order not found for key: $cleanId');
      }
    } catch (e) {
      // if (kDebugMode) {
      //   debugPrint('[OrderDetailsController] Error fetching details: $e');
      // }
      isError.value = true;
      _redirectToOrderList('Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Deeply drills down into response map to find the map containing actual order data
  Map<String, dynamic> _extractTargetOrderMap(
    Map<String, dynamic> responseMap,
  ) {
    // if (kDebugMode) {
    //   debugPrint('[OrderDetailsController] Raw responseMap: $responseMap');
    // }

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

    final rawOrderId =
        data['orderid'] ??
        data['salesorderid'] ??
        data['salesorder_id'] ??
        data['order_id'] ??
        data['id'];
    if (rawOrderId != null && rawOrderId.toString().trim().isNotEmpty) {
      orderId.value = rawOrderId.toString().trim();
    }

    final rawCustomerId = data['customerid'] ?? data['customer_id'];
    if (rawCustomerId != null && rawCustomerId.toString().trim().isNotEmpty) {
      customerId.value = rawCustomerId.toString().trim();
    }

    // 1. Summary details (if key is missing, make blank "")
    final num =
        data['ordernumber'] ??
        data['order_number'] ??
        data['salesorder_number'] ??
        data['salesorder_no'] ??
        data['salesorderid'] ??
        data['orderkey'] ??
        data['order_id'] ??
        data['id'];

    if (num != null && num.toString().trim().isNotEmpty) {
      final numStr = num.toString().trim();
      orderNo.value = numStr;
    } else {
      orderNo.value = '';
    }

    final dateVal = data['createdtime'];
    date.value = dateVal != null ? formatDateOnly(dateVal.toString()) : '';

    final timeVal = data['createdtime'];
    time.value = timeVal != null ? formatDateOnly(timeVal.toString()) : '';

    customer.value =
        (data['customername'] ??
                data['customer_name'] ??
                data['customerName'] ??
                data['customer'] ??
                data['name'])
            ?.toString() ??
        '';

    // 2. Shipping Address (if key missing -> blank "")
    final shipMap =
        data['shiptoaddress'] ??
        data['shipping_address'] ??
        data['shippingAddress'] ??
        data['shipping'] ??
        data['delivery_address'];

    company.value =
        (data['company_name'] ??
                data['companyName'] ??
                data['company'] ??
                data['restaurant_name'] ??
                data['restaurantname'] ??
                data['resturentname'] ??
                (shipMap is Map ? shipMap['company_name'] : null))
            ?.toString() ??
        '';

    paymentMethod.value =
        (data['paymentstatus'] ??
                data['paid_status'] ??
                data['payment_status'] ??
                data['payment_mode'] ??
                data['payment_method'] ??
                data['payment'])
            ?.toString() ??
        '';

    shipmentStatus.value =
        (data['shippingstatus'] ??
                data['shipped_status'] ??
                data['shipment_status'] ??
                data['orderstatus'] ??
                data['status'] ??
                data['salesorder_status'] ??
                data['order_status'])
            ?.toString() ??
        '';

    if (shipMap is Map) {
      shippingName.value =
          (shipMap['attention'] ??
                  shipMap['name'] ??
                  shipMap['customer_name'] ??
                  shipMap['recipient_name'] ??
                  data['customername'] ??
                  data['customer_name'])
              ?.toString() ??
          '';
      shippingPhone.value =
          (shipMap['phone'] ??
                  shipMap['mobile'] ??
                  shipMap['contact'] ??
                  data['mobilenumber'] ??
                  data['phonenumber'])
              ?.toString() ??
          '';
      shippingAddress.value = _buildAddressString(shipMap);
      shippingPincode.value =
          (shipMap['zip'] ??
                  shipMap['pincode'] ??
                  shipMap['zip_code'] ??
                  shipMap['postal_code'] ??
                  data['pincode'])
              ?.toString() ??
          '';
    } else if (shipMap is String) {
      shippingAddress.value = shipMap;
      shippingName.value = '';
      shippingPhone.value = '';
      shippingPincode.value = '';
    } else {
      shippingName.value = data['customername']?.toString() ?? '';
      shippingPhone.value = data['mobilenumber']?.toString() ?? '';
      shippingAddress.value = '';
      shippingPincode.value = data['pincode']?.toString() ?? '';
    }

    // 3. Billing Address (if key missing -> blank "")
    final billMap =
        data['billtoaddress'] ??
        data['billing_address'] ??
        data['billingAddress'] ??
        data['billing'];
    if (billMap is Map) {
      billingName.value =
          (billMap['attention'] ??
                  billMap['name'] ??
                  billMap['customer_name'] ??
                  data['customername'] ??
                  data['customer_name'])
              ?.toString() ??
          '';
      billingPhone.value =
          (billMap['phone'] ??
                  billMap['mobile'] ??
                  billMap['contact'] ??
                  data['mobilenumber'] ??
                  data['phonenumber'])
              ?.toString() ??
          '';
      billingAddress.value = _buildAddressString(billMap);
      billingPincode.value =
          (billMap['zip'] ??
                  billMap['pincode'] ??
                  billMap['zip_code'] ??
                  billMap['postal_code'] ??
                  data['pincode'])
              ?.toString() ??
          '';
    } else if (billMap is String) {
      billingAddress.value = billMap;
      billingName.value = '';
      billingPhone.value = '';
      billingPincode.value = '';
    } else {
      billingName.value = data['customername']?.toString() ?? '';
      billingPhone.value = data['mobilenumber']?.toString() ?? '';
      billingAddress.value = '';
      billingPincode.value = data['pincode']?.toString() ?? '';
    }

    // 4. Price Breakdown (if key missing -> blank "")
    double calculatedSubtotal = 0.0;
    final itemsRaw =
        data['items'] ??
        data['line_items'] ??
        data['order_items'] ??
        data['products'];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map) {
          final itemTot =
              double.tryParse(
                (item['item_sub_total'] ??
                        item['item_total'] ??
                        item['total'] ??
                        item['rate'] ??
                        '0')
                    .toString(),
              ) ??
              0.0;
          calculatedSubtotal += itemTot;
        }
      }
    }

    final rawSubtotal =
        data['sub_total'] ??
        data['subtotal'] ??
        data['item_sub_total'] ??
        data['sub_total_inclusive_of_tax'];
    if (rawSubtotal != null &&
        rawSubtotal.toString().trim().isNotEmpty &&
        rawSubtotal.toString().trim() != 'null') {
      subtotal.value = _formatPriceVal(rawSubtotal);
    } else if (calculatedSubtotal > 0) {
      subtotal.value = _formatPriceVal(calculatedSubtotal);
    } else {
      subtotal.value = '';
    }

    shippingFee.value = _formatPriceVal(data['shippingcharge']);
    platformFee.value = _formatPriceVal(
      data['platform_fee'] ?? data['platform_charge'],
    );

    // Calculate bankFee by summing bankcharges from payments array
    double totalBankCharges = 0.0;
    bool foundBankChargesInPayments = false;
    final paymentsList = data['payments'];
    if (paymentsList is List && paymentsList.isNotEmpty) {
      for (final p in paymentsList) {
        if (p is Map) {
          final val = p['bankcharges'];
          if (val != null) {
            final cleanStr = val
                .toString()
                .replaceAll('₹', '')
                .replaceAll(',', '')
                .replaceAll(RegExp(r'\s+'), '')
                .trim();
            final parsed = double.tryParse(cleanStr);
            if (parsed != null) {
              totalBankCharges += parsed;
              foundBankChargesInPayments = true;
            }
          }
        }
      }
    }

    if (foundBankChargesInPayments) {
      bankFee.value = _formatPriceVal(totalBankCharges);
    } else {
      bankFee.value = _formatPriceVal(data['bankcharges']);
    }

    discountPercent.value = _formatPriceVal(
      data['discount'] ?? data['discount_total'] ?? data['discount_amount'],
    );
    couponDiscount.value = _formatPriceVal(data['coupondiscount']);
    if (data['coupon_code'] != null || data['coupon_name'] != null) {
      couponCode.value = (data['coupon_code'] ?? data['coupon_name'])
          .toString();
    }
    tax.value = _formatPriceVal(data['taxamount']);

    // Tax breakdown from taxes array, line_item_taxes, or line items
    double calculatedCgst = 0.0;
    double calculatedSgst = 0.0;
    double calculatedIgst = 0.0;
    bool foundCgstInTaxes = false;
    bool foundSgstInTaxes = false;
    bool foundIgstInTaxes = false;

    void processTaxMap(Map t) {
      final taxSpecificType = (t['tax_specific_type'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final taxName =
          (t['tax_name'] ?? t['name'] ?? t['tax_type'] ?? t['tax_label'] ?? '')
              .toString()
              .toUpperCase();
      final amtVal =
          t['tax_amount_formatted'] ??
          t['tax_amount'] ??
          t['amount'] ??
          t['val'];
      double amt = 0.0;
      if (amtVal != null) {
        final cleanStr = amtVal
            .toString()
            .replaceAll('₹', '')
            .replaceAll(',', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim();
        amt = double.tryParse(cleanStr) ?? 0.0;
      }

      if (taxSpecificType == 'cgst' || taxName.contains('CGST')) {
        calculatedCgst += amt;
        foundCgstInTaxes = true;
      } else if (taxSpecificType == 'sgst' || taxName.contains('SGST')) {
        calculatedSgst += amt;
        foundSgstInTaxes = true;
      } else if (taxSpecificType == 'igst' || taxName.contains('IGST')) {
        calculatedIgst += amt;
        foundIgstInTaxes = true;
      }
    }

    final topTaxes = data['taxes'];
    if (topTaxes is List && topTaxes.isNotEmpty) {
      for (final t in topTaxes) {
        if (t is Map) processTaxMap(t);
      }
    } else {
      final rawItems =
          data['line_items'] ??
          data['order_items'] ??
          data['items'] ??
          data['products'];
      if (rawItems is List && rawItems.isNotEmpty) {
        for (final item in rawItems) {
          if (item is Map) {
            final itemTaxes =
                item['line_item_taxes'] ?? item['item_taxes'] ?? item['taxes'];
            if (itemTaxes is List && itemTaxes.isNotEmpty) {
              for (final t in itemTaxes) {
                if (t is Map) processTaxMap(t);
              }
            }
          }
        }
      }
    }

    final directCgst =
        data['cgst'] ??
        data['cgst_amount'] ??
        data['cgst_total'] ??
        data['cgst_tax_amount'];
    final directSgst =
        data['sgst'] ??
        data['sgst_amount'] ??
        data['sgst_total'] ??
        data['sgst_tax_amount'];
    final directIgst =
        data['igst'] ??
        data['igst_amount'] ??
        data['igst_total'] ??
        data['igst_tax_amount'];

    if (foundCgstInTaxes || calculatedCgst > 0) {
      cgst.value = _formatPriceVal(calculatedCgst);
    } else if (directCgst != null &&
        directCgst.toString().trim().isNotEmpty &&
        directCgst.toString().trim() != 'null' &&
        directCgst.toString().trim() != '-') {
      cgst.value = _formatPriceVal(directCgst);
    } else {
      cgst.value = '';
    }

    if (foundSgstInTaxes || calculatedSgst > 0) {
      sgst.value = _formatPriceVal(calculatedSgst);
    } else if (directSgst != null &&
        directSgst.toString().trim().isNotEmpty &&
        directSgst.toString().trim() != 'null' &&
        directSgst.toString().trim() != '-') {
      sgst.value = _formatPriceVal(directSgst);
    } else {
      sgst.value = '';
    }

    if (foundIgstInTaxes || calculatedIgst > 0) {
      igst.value = _formatPriceVal(calculatedIgst);
    } else if (directIgst != null &&
        directIgst.toString().trim().isNotEmpty &&
        directIgst.toString().trim() != 'null' &&
        directIgst.toString().trim() != '-') {
      igst.value = _formatPriceVal(directIgst);
    } else {
      igst.value = '';
    }

    grandTotal.value = _formatPriceVal(data['finalamount']);

    // Extract invoice_id & invoice_number from data['invoices'] list or top-level keys
    invoiceId.value = '';
    invoiceNumber.value = '';

    final invoicesList = data['invoices'];
    if (invoicesList is List && invoicesList.isNotEmpty) {
      for (final inv in invoicesList) {
        if (inv is Map) {
          final id = (inv['invoiceid']).toString().trim();
          if (id.isNotEmpty && id != 'null') {
            invoiceId.value = id;
            invoiceNumber.value = (inv['invoicenumber']).toString().trim();
            break;
          }
        }
      }
    } else if (invoicesList is Map) {
      final id = (invoicesList['invoiceid']).toString().trim();
      if (id.isNotEmpty && id != 'null') {
        invoiceId.value = id;
        invoiceNumber.value = (invoicesList['invoicenumber']).toString().trim();
      }
    }

    if (invoiceId.value.isEmpty &&
        data['invoiceid'] != null &&
        data['invoiceid'].toString().trim().isNotEmpty &&
        data['invoiceid'].toString().trim() != 'null') {
      invoiceId.value = data['invoiceid'].toString().trim();
      invoiceNumber.value = (data['invoicenumber']).toString().trim();
    }

    // 5. Documents (if key missing -> empty list)
    final docsList = data['documents'] ?? data['document_list'] ?? data['docs'];
    final List<DocumentModel> parsedDocs = [];
    if (docsList is List && docsList.isNotEmpty) {
      for (final d in docsList) {
        if (d is Map) {
          parsedDocs.add(
            DocumentModel(
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
            ),
          );
        } else {
          parsedDocs.add(DocumentModel(title: 'Document', code: d.toString()));
        }
      }
    }

    // Ensure 'Invoice' document entry in documents list matches invoiceId / invoiceNumber
    final int existingInvoiceIdx = parsedDocs.indexWhere(
      (doc) => doc.title.toLowerCase().replaceAll(' ', '') == 'invoice',
    );
    final String invoiceCodeToUse = invoiceId.value.isNotEmpty
        ? (invoiceNumber.value.isNotEmpty
              ? invoiceNumber.value
              : invoiceId.value)
        : '';

    if (existingInvoiceIdx != -1) {
      parsedDocs[existingInvoiceIdx] = DocumentModel(
        title: 'Invoice',
        code: invoiceCodeToUse,
      );
    } else {
      parsedDocs.insert(
        0,
        DocumentModel(title: 'Invoice', code: invoiceCodeToUse),
      );
    }

    documents.assignAll(parsedDocs);

    // 6. Payment Transactions (if key missing -> empty list)
    double totalBankFee = 0.0;
    bool hasBankCharges = false;

    final txList = data['payments'];
    if (txList is List && txList.isNotEmpty) {
      transactions.assignAll(
        txList.map((tx) {
          if (tx is Map) {
            final bcRaw = tx['bankcharges'];
            if (bcRaw != null) {
              final cleanStr = bcRaw
                  .toString()
                  .replaceAll('₹', '')
                  .replaceAll(',', '')
                  .replaceAll(RegExp(r'\s+'), '')
                  .trim();
              final parsed = double.tryParse(cleanStr);
              if (parsed != null) {
                totalBankFee += parsed;
                hasBankCharges = true;
              }
            }
            return PaymentTransactionModel(
              issuedBy: (tx['issuedby'] ?? tx['issued_by'] ?? "-").toString(),
              createdOn: formatDateOnly(
                (tx['paymentdate'] ??
                        tx['payment_date'] ??
                        tx['created_on'] ??
                        "-")
                    .toString(),
              ),
              paymentId: (tx['paymentid'] ?? tx['payment_id'] ?? "-")
                  .toString(),
              paymentMethod: (tx['paymentmode'] ?? tx['payment_mode'] ?? "-")
                  .toString(),
              rrnUtr:
                  (tx['transactionref'] ?? tx['rrn_utr'] ?? tx['rrn'] ?? "-")
                      .toString(),
              status: (tx['paymentstatus'] ?? tx['status'] ?? "-").toString(),
              amount: _formatPriceVal(
                tx['paymentamount'] ?? tx['amount'] ?? "-",
              ),
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

    if (hasBankCharges) {
      bankFee.value = _formatPriceVal(totalBankFee);
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

            final List<LineItemTaxModel> itemTaxList = [];
            final rawItemTaxes =
                item['line_item_taxes'] ?? item['item_taxes'] ?? item['taxes'];
            if (rawItemTaxes is List && rawItemTaxes.isNotEmpty) {
              for (final t in rawItemTaxes) {
                if (t is Map) {
                  itemTaxList.add(
                    LineItemTaxModel(
                      taxName:
                          (t['tax_name'] ?? t['name'] ?? t['tax_type'] ?? '')
                              .toString(),
                      taxAmount: _formatPriceVal(
                        t['tax_amount'] ?? t['amount'] ?? t['val'],
                      ),
                      taxPercent:
                          double.tryParse(
                            (t['tax_percentage'] ??
                                    t['tax_percent'] ??
                                    t['rate'] ??
                                    '0')
                                .toString(),
                          ) ??
                          0.0,
                    ),
                  );
                }
              }
            }

            final statusStr = (item['status'] ?? item['item_status'] ?? '')
                .toString()
                .toLowerCase();
            final isItemAccepted =
                statusStr == 'accepted' || statusStr == 'approved';
            final isItemRejected =
                statusStr == 'rejected' || statusStr == 'cancelled';

            return OrderItemModel(
              name: (item['name'] ?? '').toString(),
              itemType: (item['group_name'] ?? '').toString(),
              description: (item['description'] ?? '').toString(),
              price: _formatPriceVal(
                item['rate'] ?? item['price'] ?? item['unit_price'],
              ),
              qty: qtyVal,
              total: _formatPriceVal(
                item['item_total'] ?? item['total'] ?? item['line_total'],
              ),
              lineItemTaxes: itemTaxList,
              initialAccepted: isItemAccepted,
              initialRejected: isItemRejected,
            );
          }
          return OrderItemModel(
            name: '',
            itemType: '',
            description: '',
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
    if (raw == null) return '-';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '-';
    final cleanStr = str.replaceAll('₹', '').trim();
    final parsed = double.tryParse(cleanStr);
    if (parsed != null) {
      return '₹ ${parsed.toStringAsFixed(2)}';
    }
    return str;
  }

  String formatDateOnly(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    final String inputString = dateRaw.toString().trim();
    if (inputString.isEmpty || inputString == 'null' || inputString == '-') {
      return '-';
    }

    try {
      DateTime dateTime = DateTime.parse(inputString);
      String formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(dateTime.toLocal());
      String formattedTime = DateFormat(
        'hh:mm:ss a',
      ).format(dateTime.toLocal());
      return '$formattedDate $formattedTime';
    } catch (_) {
      DateTime? dt = DateTime.tryParse(inputString);
      if (dt == null && inputString.contains(' ')) {
        dt = DateTime.tryParse(inputString.replaceFirst(' ', 'T'));
      }
      if (dt != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(dt.toLocal());
        String formattedTime = DateFormat('hh:mm:ss a').format(dt.toLocal());
        return '$formattedDate $formattedTime';
      }
      return inputString;
    }
  }

  String extractDateOnly(String fullDateStr) {
    final trimmed = fullDateStr.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == '-') return '-';
    final parts = trimmed.split(' ');
    return parts.isNotEmpty ? parts[0] : trimmed;
  }

  String extractTimeOnly(String fullTimeStr) {
    final trimmed = fullTimeStr.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == '-') return '-';
    final parts = trimmed.split(' ');
    if (parts.length >= 3) {
      return '${parts[1]} ${parts[2]}';
    } else if (parts.length == 2) {
      return parts[1];
    }
    return '-';
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

  Future<void> downloadInvoiceById(String invId) async {
    final targetInvoiceId = invId.trim().isNotEmpty
        ? invId.trim()
        : invoiceId.value.trim();

    if (targetInvoiceId.isEmpty || targetInvoiceId == 'null') {
      Get.snackbar(
        'Invoice',
        'There is no invoice',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isDownloadingInvoice.value = true;
    Get.snackbar(
      'Download Started',
      'Downloading invoice...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    try {
      final bytes = await _orderService.downloadInvoice(
        invoiceId: targetInvoiceId,
      );

      if (bytes != null && bytes.isNotEmpty) {
        final filename = invoiceNumber.value.isNotEmpty
            ? "Invoice_${invoiceNumber.value}.pdf"
            : "Invoice_$targetInvoiceId.pdf";
        downloadBlob(bytes, filename, mimeType: 'application/pdf');
        isInvoiceDownloaded.value = true;
        Get.snackbar(
          'Success',
          'Invoice downloaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Download Failed',
          'Failed to download invoice for ID: $targetInvoiceId.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isDownloadingInvoice.value = false;
    }
  }

  Future<void> generateInvoice() async {
    final targetInvoiceId = invoiceId.value.trim();
    final hasInvoice = targetInvoiceId.isNotEmpty && targetInvoiceId != 'null';

    if (invoiceNumber.value.trim().isEmpty ||
        invoiceNumber.value.trim() == 'null') {
      if (hasInvoice) {
        invoiceNumber.value = targetInvoiceId;
      } else {
        invoiceNumber.value = '-';
      }
    }
    isInvoiceDownloaded.value = true;

    if (!hasInvoice) {
      Get.snackbar(
        'Invoice',
        'There is no invoice',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  void downloadDocument(DocumentModel doc) {
    if (doc.title.toLowerCase().replaceAll(' ', '') == 'invoice') {
      downloadInvoiceById(invoiceId.value);
      return;
    }

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

  Future<bool> submitPayment({
    required String orderNumber,
    required String dueAmount,
    required String issuedBy,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String createdDateText,
    required String createdTimeText,
    required String rrnUtr,
    required String amount,
    required String status,
    String? receiptFileName,
  }) async {
    if (orderNumber.trim().isEmpty ||
        dueAmount.trim().isEmpty ||
        issuedBy.trim().isEmpty ||
        createdDateText.trim().isEmpty ||
        createdTimeText.trim().isEmpty ||
        rrnUtr.trim().isEmpty ||
        amount.trim().isEmpty ||
        status.trim().isEmpty) {
      return false;
    }

    final cleanAmount = amount
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();
    final cleanDueAmount = dueAmount
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();

    final parsedAmountVal = double.tryParse(cleanAmount);
    final parsedDueAmountVal = double.tryParse(cleanDueAmount) ?? 0.0;
    if (parsedAmountVal == null ||
        parsedAmountVal < 0.01 ||
        parsedAmountVal > parsedDueAmountVal) {
      return false;
    }
    final cleanOrderNo = orderNumber.trim().isNotEmpty
        ? orderNumber.trim().replaceAll('#', '')
        : orderNo.value.replaceAll('#', '').trim();

    final dt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    final isoDate =
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00+05:30';

    final paymentType = issuedBy == 'Bank Transfer'
        ? 'Bank Transfer'
        : (issuedBy == 'Cash' ? 'Cash' : 'UPI');
    final dateStamp =
        '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
    final nowMs = DateTime.now().millisecondsSinceEpoch.toString();
    final shortSuffix = nowMs.length > 4
        ? nowMs.substring(nowMs.length - 4)
        : nowMs;
    final txnId = 'TXN-$dateStamp-$shortSuffix';
    final cleanRrn = rrnUtr.trim().isNotEmpty
        ? rrnUtr.trim()
        : nowMs.padLeft(12, '0').substring(0, 12);
    final txnRef = rrnUtr.trim().isNotEmpty
        ? rrnUtr.trim()
        : 'TXN-REF-$shortSuffix';

    final parsedOrderId = int.tryParse(orderId.value.trim()) ?? 0;
    final parsedCustomerId = int.tryParse(customerId.value.trim()) ?? 0;

    final cgstVal = _parseItemAmount(cgst.value);
    final sgstVal = _parseItemAmount(sgst.value);
    final taxVal = _parseItemAmount(tax.value);

    final hasValidInv =
        invoiceNumber.value.trim().isNotEmpty &&
        invoiceNumber.value.trim() != '-' &&
        invoiceNumber.value.trim() != 'null';
    final invoicesJson = hasValidInv
        ? jsonEncode([
            {
              "invoicenumber": invoiceNumber.value.trim(),
              "amount": _parseItemAmount(grandTotal.value),
            },
          ])
        : "[]";

    final Map<String, dynamic> payload = {
      "orderid": parsedOrderId,
      "ordernumber": cleanOrderNo,
      "customerid": parsedCustomerId,
      "customername": customer.value,
      "transactionref": txnRef,
      "paymentdate": isoDate,
      "paymenttype": paymentType,
      "paymentamount": cleanAmount,
      "isocurrency": "INR",
      "transactionid": txnId,
      "gatewaytransactionid": "WL-$shortSuffix",
      "paymentmode": paymentType,
      "paymentgateway": issuedBy.toLowerCase(),
      "terminal": "TID-0042",
      "channel": "POS",
      "dueamount": cleanDueAmount.isNotEmpty ? cleanDueAmount : "0",
      "conveniencefee": "0",
      "taxamount": taxVal > 0 ? taxVal.toStringAsFixed(2) : "0",
      "taxdetails": jsonEncode({"cgst": cgstVal, "sgst": sgstVal}),
      "statuscode": status.toLowerCase() == 'success' ? "00" : "01",
      "statusmessage": status.toLowerCase() == 'success'
          ? "Transaction successful"
          : "Transaction $status",
      "cardtype": "",
      "cardlast4": "",
      "cardexpiry": "",
      "bankname": "",
      "accountlast4": "",
      "upiid": "",
      "invoices": invoicesJson,
      "receipturl": receiptFileName ?? "",
      "receiptid": receiptFileName != null && receiptFileName.isNotEmpty
          ? "RCPT-$shortSuffix"
          : "",
      "isrefund": false,
      "refundstatus": "",
      "refundamount": "0",
      "refundreason": "",
      "ischargeback": false,
      "disputeid": "",
      "installmentnumber": 1,
      "totalinstallments": 1,
      "isrecurring": false,
      "subscriptionid": "",
      "authcode": "",
      "rrn": cleanRrn,
      "metadata": jsonEncode({
        "gateway_status": status == 'Success' ? "Completed" : status,
        "fraud_check": "Passed",
      }),
      "notes": "Paid at counter",
      "details": jsonEncode({"source": "pos"}),
      "paymentstatus": status,
      "issuedby": issuedBy,
    };

    isSubmittingPayment.value = true;
    try {
      final res = await _orderService.addPayment(payload: payload);
      final isSuccess =
          res != null &&
          (res['success'] == true ||
              res['status'] == true ||
              res['status'] == 1 ||
              res['status'] == 'success' ||
              res['code'] == 200 ||
              res['code'] == 201 ||
              !res.containsKey('error'));

      final formattedAmount = _formatPriceVal(cleanAmount);
      print("IsSuccess in order details....$isSuccess");

      if (isSuccess) {
        transactions.insert(
          0,
          PaymentTransactionModel(
            issuedBy: issuedBy,
            createdOn: '$createdDateText $createdTimeText',
            paymentId: txnId,
            paymentMethod: paymentType,
            rrnUtr: cleanRrn,
            status: status,
            amount: formattedAmount,
          ),
        );

        if (orderKey.value.isNotEmpty) {
          fetchOrderDetails(orderKey.value);
        }

        Get.snackbar(
          'Payment Added',
          (res['message'] ?? 'Payment of $formattedAmount added successfully')
              .toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        final errMsg =
            (res?['message'] ?? res?['error'] ?? 'Failed to add payment')
                .toString();
        Get.snackbar(
          'Error',
          errMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmittingPayment.value = false;
    }
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

  double _parseItemAmount(String raw) {
    final cleanStr = raw
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }

  double get totalSuccessTransactionAmount {
    double sum = 0.0;
    for (final tx in transactions) {
      if (tx.status.trim().toLowerCase() == 'success') {
        sum += _parseItemAmount(tx.amount);
      }
    }
    return sum;
  }

  double get dueAmountValue {
    final total = _parseItemAmount(grandTotal.value);
    return total - totalSuccessTransactionAmount;
  }

  String get paymentDueDisplay {
    if (transactions.isEmpty || dueAmountValue <= 0) {
      return 'Paid';
    }
    return 'Due ₹ ${dueAmountValue.toStringAsFixed(2)}';
  }

  int get totalRejectedItems =>
      orderItems.where((item) => item.isRejected.value).length;

  String get totalDeclinedAmount {
    double sum = 0.0;
    for (final item in orderItems) {
      if (item.isRejected.value) {
        sum += _parseItemAmount(item.total);
      }
    }
    return '₹${sum.toStringAsFixed(2)}.';
  }

  int get totalAcceptedItems =>
      orderItems.where((item) => item.isAccepted.value).length;

  String get acceptedOrderAmount {
    double sum = 0.0;
    for (final item in orderItems) {
      if (item.isAccepted.value) {
        sum += _parseItemAmount(item.total);
      }
    }
    return '₹${sum.toStringAsFixed(2)}';
  }

  void toggleAcceptItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      if (item.isAccepted.value) {
        item.isAccepted.value = false;
      } else {
        item.isAccepted.value = true;
        item.isRejected.value = false;
      }
    }
  }

  void toggleRejectItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      if (item.isRejected.value) {
        item.isRejected.value = false;
      } else {
        item.isRejected.value = true;
        item.isAccepted.value = false;
      }
    }
  }

  void acceptAllItems() {
    for (final item in orderItems) {
      item.isAccepted.value = true;
      item.isRejected.value = false;
    }
    Get.snackbar(
      'Accepted',
      'All order items have been accepted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
