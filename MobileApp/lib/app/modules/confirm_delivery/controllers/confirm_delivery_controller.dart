import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class ConfirmDeliveryController extends GetxController {
  final RxString customerName = 'Priya Nair'.obs;
  final RxDouble orderValue = 165.00.obs;
  final RxString orderId = '01'.obs;
  final RxString storeName = 'Burger Bistro'.obs;
  final RxInt selectedOptionIndex = 0.obs; // Default to 'Handed to customer'
  final RxBool isSubmitting = false.obs;

  final List<Map<String, dynamic>> deliveryOptions = [
    {
      'title': 'Handed to customer',
      'icon': 'location',
    },
    {
      'title': 'Left at door',
      'icon': 'door',
    },
    {
      'title': 'Handed to security/reception',
      'icon': 'security',
    },
    {
      'title': 'Customer unavailable',
      'icon': 'unavailable',
    },
  ];

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
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
    }
  }

  void selectOption(int index) {
    selectedOptionIndex.value = index;
  }

  Future<void> onConfirmDelivery() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isSubmitting.value = false;

    if (selectedOptionIndex.value != 3) {
      Get.toNamed(
        Routes.COLLECT_PAYMENT,
        arguments: {
          'customerName': customerName.value,
          'orderValue': orderValue.value,
          'orderId': orderId.value,
          'storeName': storeName.value,
          'deliveryOption': deliveryOptions[selectedOptionIndex.value]['title'],
        },
      );
    } else {
      Get.toNamed(
        Routes.CUSTOMER_UNAVAILABLE,
        arguments: {
          'customerName': customerName.value,
          'customerPhone': '+91 98123 45670',
          'orderId': orderId.value,
          'storeName': storeName.value,
        },
      );
    }
  }
}
