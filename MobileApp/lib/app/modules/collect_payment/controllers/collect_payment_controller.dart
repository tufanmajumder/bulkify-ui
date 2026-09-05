import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class CollectPaymentController extends GetxController {
  final RxDouble orderValue = 165.00.obs;
  final RxString orderId = '01'.obs;
  final RxString storeName = 'Burger Bistro'.obs;
  final RxString upiId = 'johndoe@okhdfc'.obs;
  final RxString customerName = 'Priya Nair'.obs;

  final RxString deliveryOption = 'Handed to customer'.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
      if (data['orderId'] != null) {
        orderId.value = data['orderId'].toString();
      }
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['customerName'] != null) {
        customerName.value = data['customerName'].toString();
      }
      if (data['upiId'] != null) {
        upiId.value = data['upiId'].toString();
      }
      if (data['deliveryOption'] != null) {
        deliveryOption.value = data['deliveryOption'].toString();
      }
    }
  }

  Future<void> onReceivedPayment() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isProcessing.value = false;

    Get.offAllNamed(
      Routes.DELIVERY_SUCCESS,
      arguments: {
        'storeName': storeName.value,
        'deliveryOption': deliveryOption.value,
        'orderValue': orderValue.value,
        'paymentType': 'Cash/UPI collected on delivery',
      },
    );
  }

  Future<void> onAlreadyPaidOnline() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isProcessing.value = false;

    Get.offAllNamed(
      Routes.DELIVERY_SUCCESS,
      arguments: {
        'storeName': storeName.value,
        'deliveryOption': deliveryOption.value,
        'orderValue': orderValue.value,
        'paymentType': 'Paid online',
      },
    );
  }
}
