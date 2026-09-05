import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';

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
      Get.snackbar(
        "Calling Customer",
        "Dialing ${customerName.value} (${customerPhone.value})...",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onWaitFiveMinutesAndRetry() {
    Get.snackbar(
      "Retry Delivery",
      "Timer set for 5 minutes. Please retry reaching ${customerName.value}.",
      snackPosition: SnackPosition.BOTTOM,
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
