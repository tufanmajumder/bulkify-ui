import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class DeliveryFailedReasonController extends GetxController {
  final RxString customerName = 'Aditya Shah'.obs;
  final RxString orderId = '01'.obs;
  final RxString storeName = 'Burger Bistro'.obs;
  final RxDouble orderValue = 165.00.obs;

  final RxInt selectedOptionIndex = 0.obs; // Default to 'Customer not reachable'
  final RxBool isSubmitting = false.obs;

  final List<String> failureReasons = [
    'Customer not reachable',
    'Wrong or incomplete address',
    'Customer refused the order',
    'Other reason',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['customerName'] != null) {
        customerName.value = data['customerName'].toString();
      }
      if (data['orderId'] != null) {
        orderId.value = data['orderId'].toString();
      }
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
    }
  }

  void selectOption(int index) {
    selectedOptionIndex.value = index;
  }

  Future<void> onConfirmDeliveryFailed() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isSubmitting.value = false;

    final reason = failureReasons[selectedOptionIndex.value];

    Get.offAllNamed(
      Routes.DELIVERY_FAILED_SUMMARY,
      arguments: {
        'storeName': storeName.value,
        'orderValue': orderValue.value,
        'reason': reason,
      },
    );
  }
}
