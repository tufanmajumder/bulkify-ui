import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class DeliveryFailedSummaryController extends GetxController {
  final RxString storeName = 'Burger Bistro'.obs;
  final RxDouble orderValue = 165.00.obs;
  final RxString reason = 'Customer not reachable'.obs;
  final RxString loggedAtTime = '5:53 PM'.obs;

  @override
  void onInit() {
    super.onInit();
    final DateTime now = DateTime.now();
    final int hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';
    loggedAtTime.value = '$hour:$minute $period';

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
      if (data['reason'] != null) {
        reason.value = data['reason'].toString();
      }
      if (data['loggedAtTime'] != null) {
        loggedAtTime.value = data['loggedAtTime'].toString();
      }
    }
  }

  void onBackToHome() {
    Get.offAllNamed(Routes.HOME);
  }
}
