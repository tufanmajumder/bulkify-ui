import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/orders/controllers/orders_controller.dart';
import 'package:bulkify/app/routes/app_pages.dart';

class NavigateToDeliverController extends GetxController {
  final RxString orderId = 'O103490'.obs;
  final RxString customerName = 'Aditya Shah'.obs;
  final RxString deliveryAddress =
      'Flat 402, Oakwood Heights, Main Street, Bengaluru 560038'.obs;
  final RxDouble orderValue = 2049.00.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      final resolvedId = data['orderId'] ?? data['orderNumber'] ?? data['id'];
      if (resolvedId != null && resolvedId.toString().trim().isNotEmpty) {
        orderId.value = resolvedId.toString().replaceAll('#', '').trim();
      }

      String resolvedCustomer = (data['customerName'] ?? '').toString().trim();
      if (resolvedCustomer.isEmpty && data['raw'] != null && data['raw'] is Map) {
        final raw = data['raw'] as Map;
        resolvedCustomer = (raw['customerName'] ??
                raw['customername'] ??
                raw['clientname'] ??
                (raw['customer'] is Map ? (raw['customer']['name'] ?? raw['customer']['fullname']) : '') ??
                (raw['drop'] is Map ? (raw['drop']['name'] ?? raw['drop']['contactname']) : '') ??
                '')
            .toString()
            .trim();
      }
      if (resolvedCustomer.isNotEmpty) {
        customerName.value = resolvedCustomer;
      }

      String resolvedAddress = (data['dropOffAddress'] ??
              data['address'] ??
              data['deliveryAddress'] ??
              '')
          .toString()
          .trim();
      if (resolvedAddress.isEmpty && data['raw'] != null && data['raw'] is Map) {
        final raw = data['raw'] as Map;
        resolvedAddress = (raw['deliveryAddress'] ??
                raw['deliveryaddress'] ??
                raw['address'] ??
                (raw['drop'] is Map ? (raw['drop']['address'] ?? raw['drop']['addressline']) : '') ??
                '')
            .toString()
            .trim();
      }
      if (resolvedAddress.isNotEmpty) {
        deliveryAddress.value = resolvedAddress;
      }

      if (data['orderTotal'] != null && data['orderTotal'] is num) {
        orderValue.value = (data['orderTotal'] as num).toDouble();
      } else if (data['amount'] != null && data['amount'] is num) {
        orderValue.value = (data['amount'] as num).toDouble();
      } else if (data['orderTotal'] != null || data['amount'] != null) {
        final parsedVal = double.tryParse((data['orderTotal'] ?? data['amount'])
            .toString()
            .replaceAll('₹', '')
            .replaceAll(',', '')
            .trim());
        if (parsedVal != null) {
          orderValue.value = parsedVal;
        }
      }

      String resolvedPhone = (data['customerPhone'] ?? '').toString().trim();
      if (resolvedPhone.isEmpty && data['raw'] != null && data['raw'] is Map) {
        final raw = data['raw'] as Map;
        resolvedPhone = (raw['customerPhone'] ??
                raw['customerphone'] ??
                raw['phone'] ??
                (raw['customer'] is Map ? (raw['customer']['phone'] ?? raw['customer']['contactnumber']) : '') ??
                (raw['drop'] is Map ? (raw['drop']['phone'] ?? raw['drop']['contactnumber']) : '') ??
                '')
            .toString()
            .trim();
      }
      if (resolvedPhone.isNotEmpty) {
        customerPhone.value = resolvedPhone;
      }
    }
  }

  void onBackPressed({bool skipPop = false}) {
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().refreshOrders();
    }
    if (!skipPop) {
      Get.back();
    }
  }

  Future<void> onCallCustomer() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: customerPhone.value.replaceAll(' ', ''),
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      WidgetManager.showSnackBar(
        message: "Dialing ${customerName.value} (${customerPhone.value})...",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> onOpenGoogleMaps() async {
    final encodedDestination = Uri.encodeComponent(deliveryAddress.value);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final Uri googleMapsAppUri = Uri.parse(
        'comgooglemaps://?daddr=$encodedDestination&directionsmode=driving',
      );
      final Uri appleMapsUri = Uri.parse(
        'https://maps.apple.com/?daddr=$encodedDestination&dirflg=d',
      );
      final Uri webMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$encodedDestination&travelmode=driving',
      );

      try {
        if (await canLaunchUrl(googleMapsAppUri)) {
          await launchUrl(
            googleMapsAppUri,
            mode: LaunchMode.externalApplication,
          );
          return;
        }
        if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          return;
        }
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        WidgetManager.showSnackBar(
          message: "Could Not Open Maps Application: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$encodedDestination&travelmode=driving',
      );

      try {
        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        WidgetManager.showSnackBar(
          message: "Could Not Open Google Maps: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  void onArrivedAtLocation() {
    Get.toNamed(
      Routes.COLLECT_PAYMENT,
      arguments: {
        'customerName': customerName.value,
        'customerPhone': customerPhone.value,
        'deliveryAddress': deliveryAddress.value,
        'orderValue': orderValue.value,
      },
    );
  }
}
