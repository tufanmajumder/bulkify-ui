import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/order_service.dart';
import 'package:admin_app/utils/blob_downloader.dart';

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
  final String description;
  final String price;
  final int qty;
  final String total;
  final List<LineItemTaxModel> lineItemTaxes;

  OrderItemModel({
    required this.name,
    required this.description,
    required this.price,
    required this.qty,
    required this.total,
    this.lineItemTaxes = const [],
  });

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
        time.value = _formatTimeOnly(args.date);
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
    //print("salesorderId...$salesorderId");
    final cleanId = salesorderId.trim();
    if (cleanId.isEmpty) return;

    isLoading.value = true;
    isError.value = false;

    try {
      final responseMap = await _orderService.getOrderDetails(
        orderKey: cleanId,
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

    final dateVal =
        data['orderdate'] ??
        data['order_date'] ??
        data['date'] ??
        data['salesorder_date'] ??
        data['created_time'] ??
        data['created_at'];
    date.value = dateVal != null ? formatDateOnly(dateVal.toString()) : '';

    final timeVal =
        data['time'] ??
        data['orderdate'] ??
        data['order_date'] ??
        data['created_time'] ??
        data['created_at'];
    time.value = timeVal != null ? _formatTimeOnly(timeVal.toString()) : '';

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
      data['coupondiscount'] ??
          data['coupon_discount'] ??
          data['coupon_amount'],
    );
    if (data['coupon_code'] != null || data['coupon_name'] != null) {
      couponCode.value = (data['coupon_code'] ?? data['coupon_name'])
          .toString();
    }
    tax.value = _formatPriceVal(
      data['taxamount'] ??
          data['tax_total'] ??
          data['tax_total_formatted'] ??
          data['tax'] ??
          data['tax_amount'],
    );

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

    grandTotal.value = _formatPriceVal(
      data['finalamount'] ??
          data['grandtotal'] ??
          data['total'] ??
          data['grand_total'] ??
          data['amount'],
    );

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

            return OrderItemModel(
              name:
                  (item['name'] ??
                          item['item_name'] ??
                          item['product_name'] ??
                          '')
                      .toString(),
              description:
                  (item['description'] ??
                          item['item_description'] ??
                          item['details'] ??
                          item['merchant_name'] ??
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
              lineItemTaxes: itemTaxList,
            );
          }
          return OrderItemModel(
            name: '',
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

  String formatDateOnly(String raw) {
    final str = raw.trim();
    if (str.isEmpty || str == 'null' || str == '-') return '-';

    // 1. Try parsing full DateTime (ISO, yyyy-MM-dd, etc.)
    DateTime? dt = DateTime.tryParse(str);
    if (dt == null && str.contains(' ')) {
      dt = DateTime.tryParse(str.replaceFirst(' ', 'T'));
    }
    if (dt != null) {
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString().padLeft(4, '0');
      return '$dd-$mm-$yyyy';
    }

    // 2. Extract date portion if input contains time
    String datePart = str;
    if (str.contains(' ')) {
      datePart = str.split(RegExp(r'\s+'))[0];
    }

    // 3. Parse date components
    final components = datePart.split(RegExp(r'[-/.]'));
    if (components.length == 3) {
      String? dd, mm, yyyy;

      if (components[0].length == 4) {
        // yyyy-MM-dd
        yyyy = components[0];
        mm = components[1].padLeft(2, '0');
        dd = components[2].padLeft(2, '0');
      } else if (components[2].length == 4) {
        // dd-MM-yyyy
        dd = components[0].padLeft(2, '0');
        mm = components[1].padLeft(2, '0');
        yyyy = components[2];
      } else if (components[2].length == 2) {
        // dd-MM-yy
        dd = components[0].padLeft(2, '0');
        mm = components[1].padLeft(2, '0');
        yyyy = '20${components[2]}';
      }

      if (dd != null && mm != null && yyyy != null) {
        return '$dd-$mm-$yyyy';
      }
    }

    return datePart;
  }

  String _formatTimeOnly(String raw) {
    final str = raw.trim();
    if (str.isEmpty || str == 'null' || str == '-') return '-';

    // 1. Try parsing full DateTime
    DateTime? dt = DateTime.tryParse(str);
    if (dt == null && str.contains(' ')) {
      dt = DateTime.tryParse(str.replaceFirst(' ', 'T'));
    }
    if (dt != null) {
      int hr = dt.hour % 12;
      if (hr == 0) hr = 12;
      final hrStr = hr.toString().padLeft(2, '0');
      final minStr = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hrStr:$minStr $period';
    }

    // 2. Extract time component if input contains Date & Time
    String timePart = str;
    if (str.contains(' ')) {
      final parts = str.split(RegExp(r'\s+'));
      if (parts.length > 1 &&
          (parts[0].contains('-') || parts[0].contains('/'))) {
        timePart = parts.sublist(1).join(' ');
      }
    }

    // 3. Match HH:mm:ss or HH:mm with optional AM/PM
    final timeMatch = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*([AaPp][Mm])?$',
    ).firstMatch(timePart.trim());
    if (timeMatch != null) {
      int hr = int.parse(timeMatch.group(1)!);
      final minStr = timeMatch.group(2)!;
      final ampm = timeMatch.group(3);

      if (ampm != null && ampm.isNotEmpty) {
        final period = ampm.toUpperCase();
        final hrStr = hr.toString().padLeft(2, '0');
        return '$hrStr:$minStr $period';
      } else {
        final period = hr >= 12 ? 'PM' : 'AM';
        hr = hr % 12;
        if (hr == 0) hr = 12;
        final hrStr = hr.toString().padLeft(2, '0');
        return '$hrStr:$minStr $period';
      }
    }

    return timePart;
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

    if (kDebugMode) {
      debugPrint(
        '[OrderDetailsController] Requesting invoice download for invoice_id: $targetInvoiceId',
      );
    }

    if (targetInvoiceId.isEmpty || targetInvoiceId == 'null') {
      Get.snackbar(
        'Invoice Unavailable',
        'No valid invoice ID found for this order. An invoice may not have been generated yet on Zoho.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
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
