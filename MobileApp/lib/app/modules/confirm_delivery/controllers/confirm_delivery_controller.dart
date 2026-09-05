import 'package:get/get.dart';

import 'package:bulkify/app/routes/app_pages.dart';

class ConfirmDeliveryController extends GetxController {
  final RxString customerName = 'Priya Nair'.obs;
  final RxDouble orderValue = 2049.00.obs;
  final RxString orderId = 'O103490'.obs;
  final RxString paymentId = '710644'.obs;
  final RxString utr = '554776421'.obs;
  final RxString storeName = 'Burger Bistro'.obs;
  final RxString paymentType = 'Cash/UPI collected on delivery'.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['customerName'] != null) {
        customerName.value = data['customerName'].toString();
      }
      if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
      if (data['orderId'] != null) {
        orderId.value = data['orderId'].toString();
      }
      if (data['paymentId'] != null) {
        paymentId.value = data['paymentId'].toString();
      }
      if (data['utr'] != null) {
        utr.value = data['utr'].toString();
      }
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['paymentType'] != null) {
        paymentType.value = data['paymentType'].toString();
      }
    }
  }

  Future<void> onSendDeliveryCode() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isSubmitting.value = false;

    Get.toNamed(
      Routes.DELIVERY_OTP,
      arguments: {
        'customerName': customerName.value,
        'orderValue': orderValue.value,
        'orderId': orderId.value,
        'storeName': storeName.value,
        'paymentType': paymentType.value,
      },
    );
  }
}
