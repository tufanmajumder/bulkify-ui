import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/routes/app_pages.dart';
import 'package:bulkify/app/data/models/order/reject_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/orders/controllers/orders_controller.dart';

class OrderDetailsController extends GetxController {
  // Order Details Reactive Data
  final RxString orderId = '01'.obs;
  final RxString orderKey = ''.obs;
  final RxString orderType = 'Food Delivery'.obs;
  final RxString customerName = 'Aditya Shah'.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;
  final RxString dropOffAddress = 'Oakwood Heights, Flat 402'.obs;
  final RxDouble orderTotal = 165.00.obs;
  final RxDouble totalTax = 0.0.obs;
  final RxString status = 'Accepted'.obs;
  final RxString orderstatus = 'Accepted'.obs;
  final RxString statusType = 'active'.obs;
  final RxBool isConfirmingPickup = false.obs;

  final RxList<Map<String, dynamic>> items = RxList<Map<String, dynamic>>(_generate50Items());

  static List<Map<String, dynamic>> _generate50Items() {
    final sampleNames = [
      'Cheeseburger', 'Fries', 'Coke', 'Cheese Slice', 'Bacon Strips',
      'Veggie Pizza', 'Garlic Bread', 'Chicken Wings', 'Chocolate Milkshake', 'Brownie',
      'Iced Tea', 'Onion Rings', 'Nachos Dip', 'Sub Sandwich', 'Caesar Salad',
      'Crispy Tacos', 'Pasta Alfredo', 'Espresso Coffee', 'Glazed Donut', 'Spring Rolls',
      'Mozzarella Sticks', 'Grilled Cheese', 'Lemonade', 'Waffles', 'Pancakes',
      'Club Sandwich', 'Hot Dog', 'Chicken Nuggets', 'Potato Wedges', 'Fruit Bowl',
      'Churro Bites', 'Popcorn Chicken', 'Fish & Chips', 'Burrito Bowl', 'Quesadilla',
      'Apple Pie', 'Cupcake', 'Smoothie Bowl', 'Ice Cream Scoop', 'Iced Latte',
      'Garlic Dip', 'BBQ Sauce', 'Honey Mustard', 'Chipotle Mayo', 'Ranch Dressing',
      'Garlic Butter Toast', 'Mac & Cheese', 'Loaded Fries', 'Soft Pretzel', 'Chai Latte'
    ];

    final quantities = ['1 pc', '2 pc', '3 pc', '4 pc', '1 can', '2 cans', '1 order', '1 bowl', '1 bottle'];

    return List.generate(50, (index) {
      final name = sampleNames[index % sampleNames.length];
      final qty = quantities[index % quantities.length];
      final price = ((index + 1) * 25 + 15).toString();
      return {
        'name': name,
        'quantity': qty,
        'price': price,
      };
    });
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['id'] != null && data['id'].toString().trim().isNotEmpty) {
        orderId.value = data['id'].toString().replaceAll('#', '');
      }
      if (data['orderNumber'] != null && data['orderNumber'].toString().trim().isNotEmpty) {
        orderId.value = data['orderNumber'].toString().replaceAll('#', '');
      }
      if (data['orderKey'] != null && data['orderKey'].toString().trim().isNotEmpty) {
        orderKey.value = data['orderKey'].toString().trim();
      } else if (data['orderkey'] != null && data['orderkey'].toString().trim().isNotEmpty) {
        orderKey.value = data['orderkey'].toString().trim();
      } else if (data['raw'] != null && data['raw'] is Map) {
        orderKey.value = (data['raw']['orderkey'] ?? data['raw']['orderKey'] ?? '').toString().trim();
      }
      if (data['orderType'] != null) {
        orderType.value = data['orderType'].toString();
      }
      if (data['customerName'] != null && data['customerName'].toString().trim().isNotEmpty) {
        customerName.value = data['customerName'].toString();
      }
      if (data['customerPhone'] != null && data['customerPhone'].toString().trim().isNotEmpty) {
        customerPhone.value = data['customerPhone'].toString();
      }
      if (data['dropOffAddress'] != null || data['address'] != null) {
        dropOffAddress.value = (data['dropOffAddress'] ?? data['address']).toString();
      }
      if (data['amount'] != null) {
        final d = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse(data['amount'].toString());
        if (d != null) {
          orderTotal.value = d;
        }
      }

      // Extract Total Tax from "taxes" array or totalTax
      if (data['totalTax'] != null && data['totalTax'] is num) {
        totalTax.value = (data['totalTax'] as num).toDouble();
      } else if (data['totalTax'] != null && data['totalTax'].toString().trim().isNotEmpty) {
        final parsedTax = double.tryParse(data['totalTax'].toString().replaceAll('₹', '').replaceAll(',', '').trim());
        if (parsedTax != null) {
          totalTax.value = parsedTax;
        }
      } else {
        dynamic rawTaxes = data['taxes'];
        if (rawTaxes == null && data['raw'] != null && data['raw'] is Map) {
          rawTaxes = data['raw']['taxes'] ?? data['raw']['tax'] ?? data['raw']['tax_details'];
        }
        totalTax.value = Item.calculateTotalTax(rawTaxes);
      }

      // Extract & assign items from passed data (fetched from driver/v1/orders response)
      dynamic rawItems = data['items'];
      if ((rawItems == null || (rawItems is List && rawItems.isEmpty)) && data['raw'] != null) {
        final rawMap = data['raw'] is Map ? Map<String, dynamic>.from(data['raw']) : {};
        rawItems = rawMap['items'] ??
            rawMap['orderitems'] ??
            rawMap['order_items'] ??
            rawMap['orderItems'] ??
            rawMap['products'] ??
            rawMap['product_list'] ??
            rawMap['orderlines'] ??
            rawMap['order_lines'] ??
            rawMap['lines'] ??
            (rawMap['cart'] is Map ? (rawMap['cart']['items'] ?? rawMap['cart']['lines']) : rawMap['cart']) ??
            (rawMap['details'] is Map ? rawMap['details']['items'] : rawMap['details']);
      }

      final parsed = Item.parseOrderItems(rawItems);
      if (parsed.isNotEmpty) {
        items.assignAll(parsed);
      } else if (rawItems is List && rawItems.isNotEmpty) {
        items.assignAll(List<Map<String, dynamic>>.from(
          rawItems.map((e) => Map<String, dynamic>.from(e is Map ? e : {'name': e.toString()})),
        ));
      }

      // If order total is 0 but items have amounts, compute total
      if (orderTotal.value <= 0 && items.isNotEmpty) {
        double calcTotal = 0;
        for (final it in items) {
          final amt = it['amount'];
          if (amt is num) {
            calcTotal += amt.toDouble();
          } else if (amt != null) {
            final parsedAmt = double.tryParse(amt.toString().replaceAll('₹', '').trim());
            if (parsedAmt != null) calcTotal += parsedAmt;
          }
        }
        if (calcTotal > 0) {
          orderTotal.value = calcTotal;
        }
      }

      if (data['statusType'] != null) {
        statusType.value = data['statusType'].toString().toLowerCase();
      }
      final rawStatus = (data['orderstatus'] ?? data['status'] ?? data['statusText'] ?? '').toString().trim();
      if (rawStatus.isNotEmpty) {
        final formatted = StringManager.formatOrderStatus(rawStatus);
        orderstatus.value = formatted.toLowerCase() == 'pending' ? 'Accepted' : formatted;
        status.value = orderstatus.value;
      } else {
        orderstatus.value = 'Accepted';
        status.value = 'Accepted';
      }
      if (statusType.value == 'rejected' ||
          data['statusType']?.toString().toLowerCase() == 'rejected' ||
          data['statusText']?.toString().toLowerCase() == 'rejected') {
        orderstatus.value = 'Rejected';
        status.value = 'Rejected';
      }
    }
  }

  String get displayStatus {
    final raw = (orderstatus.value.isNotEmpty ? orderstatus.value : status.value).trim();
    if (raw.isEmpty) return '';
    return StringManager.formatOrderStatus(raw);
  }

  Color get statusBadgeBg {
    final s = displayStatus.toLowerCase();
    if (s == 'picked up') return const Color(0xFF3B82F6).withValues(alpha: 0.1);
    if (s == 'accepted') return const Color(0xFFFEF4E8);
    if (s == 'rejected') return const Color(0xFFF2F3F7);
    if (s == 'delivered' || s == 'completed') return const Color(0xFFE8F6ED);
    return const Color(0xFFF4F4F6);
  }

  Color get statusBadgeTextColor {
    final s = displayStatus.toLowerCase();
    if (s == 'picked up') return const Color(0xFF3B82F6);
    if (s == 'accepted') return const Color(0xFFD97706);
    if (s == 'rejected') return const Color(0xFF71717A);
    if (s == 'delivered' || s == 'completed') return const Color(0xFF109B5B);
    return const Color(0xFF71717A);
  }

  Future<void> onConfirmPickup() async {
    if (isConfirmingPickup.value) return;

    if (orderKey.value.trim().isEmpty) {
      print("Warning: orderKey is empty onConfirmPickup");
    }

    isConfirmingPickup.value = true;
    try {
      final authService = AuthService();
      final response = await authService.updateOrderStatus(
        orderKey: orderKey.value.trim(),
        state: "picked_up",
        latitude: null,
        longitude: null,
        reasonCode: "",
        remarks: "",
      );

      final bool isSuccess = response != null &&
          (response['success'] == true ||
              response['code'] == 200 ||
              response['code'] == "200" ||
              (response['message']?.toString().toLowerCase().contains('success') ?? false));

      if (isSuccess) {
        orderstatus.value = 'picked_up';
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().refreshOrders();
        }
        WidgetManager.showSnackBar(
          message: response?['message']?.toString() ?? "Order picked up successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: ColorManager.simpleGreen,
        );

        onStartOrder();

        _triggerSubsequentStatusUpdates(orderKey.value.trim());
      } else {
        final String errorMsg = response?['message']?.toString() ??
            "Failed to update pickup status";
        WidgetManager.showSnackBar(
          message: errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      print("Error in onConfirmPickup: $e");
      WidgetManager.showSnackBar(
        message: "Something went wrong. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isConfirmingPickup.value = false;
    }
  }

  void onStartOrder() {
    Get.offNamed(
      Routes.NAVIGATE_TO_DELIVER,
      arguments: {
        'orderKey': orderKey.value,
        'orderkey': orderKey.value,
        'orderId': orderId.value,
        'orderNumber': orderId.value,
        'customerName': customerName.value,
        'dropOffAddress': dropOffAddress.value,
        'address': dropOffAddress.value,
        'orderTotal': orderTotal.value,
        'amount': orderTotal.value,
        'customerPhone': customerPhone.value,
      },
    );
  }

  void onBackPressed({bool skipPop = false}) {
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().refreshOrders();
    }
    if (!skipPop) {
      Get.back();
    }
  }

  void _triggerSubsequentStatusUpdates(String key) {
    if (key.isEmpty) return;
    Future.microtask(() async {
      try {
        final authService = AuthService();

        // 1. Wait 15 seconds -> send in_transit
        await Future.delayed(const Duration(seconds: 15));
        final transitRes = await authService.updateOrderStatus(
          orderKey: key,
          state: "in_transit",
          latitude: null,
          longitude: null,
          reasonCode: "",
          remarks: "",
        );
        print("updateOrderStatus (in_transit) result: $transitRes");
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().refreshOrders();
        }

        // 2. Wait another 15 seconds -> send out_for_delivery
        await Future.delayed(const Duration(seconds: 15));
        final deliveryRes = await authService.updateOrderStatus(
          orderKey: key,
          state: "out_for_delivery",
          latitude: null,
          longitude: null,
          reasonCode: "",
          remarks: "",
        );
        print("updateOrderStatus (out_for_delivery) result: $deliveryRes");
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().refreshOrders();
        }
      } catch (e) {
        print("Error in subsequent status updates: $e");
      }
    });
  }
}
