import 'dart:async';
import 'package:get/get.dart';

import 'package:bulkify/app/routes/app_pages.dart';

class CollectPaymentController extends GetxController {
  final RxDouble orderValue = 145.00.obs;
  final RxString orderId = 'O103491'.obs;
  final RxString storeName = 'Fresh Mart'.obs;
  final RxString upiId = ''.obs;
  final RxString customerName = 'Priya Nair'.obs;

  final RxString deliveryOption = 'Handed to customer'.obs;
  final RxBool isProcessing = false.obs;

  // Countdown Timer (1 min 42 sec = 102 sec)
  static const int initialTimerSeconds = 102;
  final RxInt remainingSeconds = initialTimerSeconds.obs;
  Timer? _timer;

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
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void regenerateQr() {
    remainingSeconds.value = initialTimerSeconds;
    startTimer();
  }

  bool get isTimerExpired => remainingSeconds.value == 0;

  String get formattedTimer {
    final minutes = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> onGetDeliveryCode() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isProcessing.value = false;

    Get.toNamed(
      Routes.CONFIRM_DELIVERY,
      arguments: {
        'customerName': customerName.value,
        'storeName': storeName.value,
        'orderValue': orderValue.value,
        'orderId': orderId.value,
        'paymentId': '710644',
        'utr': '554776421',
      },
    );
  }
}
