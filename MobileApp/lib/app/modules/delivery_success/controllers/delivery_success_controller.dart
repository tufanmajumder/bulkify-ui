import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class DeliverySuccessController extends GetxController {
  final RxString storeName = 'Burger Bistro'.obs;
  final RxString deliveryOption = 'Handed to customer'.obs;
  final RxDouble orderValue = 165.00.obs;
  final RxString paymentType = 'Cash/UPI collected on delivery'.obs;
  final RxString deliveredAtTime = '3:01 PM'.obs;

  @override
  void onInit() {
    super.onInit();
    final DateTime now = DateTime.now();
    final int hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';
    deliveredAtTime.value = '$hour:$minute $period';

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['deliveryOption'] != null) {
        deliveryOption.value = data['deliveryOption'].toString();
      }
      if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
      if (data['paymentType'] != null) {
        paymentType.value = data['paymentType'].toString();
      }
      if (data['deliveredAtTime'] != null) {
        deliveredAtTime.value = data['deliveredAtTime'].toString();
      }
    }
  }

  void onBackToHome() {
    Get.offAllNamed(Routes.HOME);
  }
}
