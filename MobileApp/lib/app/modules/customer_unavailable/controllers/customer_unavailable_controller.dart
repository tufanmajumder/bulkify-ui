import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';

class CustomerUnavailableController extends GetxController {
  final RxString customerName = 'Aditya Shah'.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;
  final RxString orderId = '01'.obs;
  final RxString storeName = 'Burger Bistro'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['customerName'] != null) {
        customerName.value = data['customerName'].toString();
      }
      if (data['customerPhone'] != null) {
        customerPhone.value = data['customerPhone'].toString();
      }
      if (data['orderId'] != null) {
        orderId.value = data['orderId'].toString();
      }
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
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

  void onWaitFiveMinutesAndRetry() {
    WidgetManager.showSnackBar(
      message: "Timer Set For 5 Minutes. Please Retry Reaching ${customerName.value}.",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
    Get.back();
  }

  void onMarkDeliveryAsFailed() {
    Get.toNamed(
      Routes.DELIVERY_FAILED_REASON,
      arguments: {
        'customerName': customerName.value,
        'customerPhone': customerPhone.value,
        'orderId': orderId.value,
        'storeName': storeName.value,
      },
    );
  }
}
