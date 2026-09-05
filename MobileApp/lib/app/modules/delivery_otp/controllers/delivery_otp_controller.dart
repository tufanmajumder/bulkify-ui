import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class DeliveryOtpController extends GetxController {
  final RxString customerName = 'Priya Nair'.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;
  final RxString deliveryAddress = ''.obs;
  final RxDouble orderValue = 0.0.obs;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxBool isVerifying = false.obs;
  final RxInt timerSeconds = 21.obs;
  Timer? _timer;

  final RxInt focusedIndex = 0.obs;

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
      if (data['deliveryAddress'] != null) {
        deliveryAddress.value = data['deliveryAddress'].toString();
      }
      if (data['orderTotal'] != null && data['orderTotal'] is num) {
        orderValue.value = (data['orderTotal'] as num).toDouble();
      }
    }

    // Track focus changes to highlight active box
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusedIndex.value = i;
        }
      });
    }

    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    timerSeconds.value = 21;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  String get formattedTimer {
    final mins = (timerSeconds.value ~/ 60).toString().padLeft(2, '0');
    final secs = (timerSeconds.value % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String getEnteredOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  Future<void> onVerifyAndContinue() async {
    final otp = getEnteredOtp();
    if (otp.length < 6) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter the complete 6-digit OTP shared by ${customerName.value}.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isVerifying.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isVerifying.value = false;

    Get.toNamed(
      Routes.CONFIRM_DELIVERY,
      arguments: {
        'customerName': customerName.value,
        'customerPhone': customerPhone.value,
        'deliveryAddress': deliveryAddress.value,
        'orderValue': orderValue.value,
      },
    );
  }

  void onResendOtp() {
    for (var c in otpControllers) {
      c.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
    startTimer();
    Get.snackbar(
      "OTP Resent",
      "A new 6-digit OTP has been sent to ${customerName.value} (${customerPhone.value}).",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
