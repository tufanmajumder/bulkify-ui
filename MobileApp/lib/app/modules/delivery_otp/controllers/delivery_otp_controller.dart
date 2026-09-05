import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';

class DeliveryOtpController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxString customerName = 'Priya Nair'.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;
  final RxString deliveryAddress = ''.obs;
  final RxDouble orderValue = 0.0.obs;
  final RxString storeName = 'Burger Bistro'.obs;
  final RxString deliveryOption = 'Handed to customer'.obs;
  final RxString paymentType = 'Cash/UPI collected on delivery'.obs;

  // QR Scanner States
  final RxBool isFlashOn = false.obs;
  final RxBool isScanning = true.obs;
  final RxBool showOtpFallback = true.obs;
  final RxBool isVerifying = false.obs;

  // Animation Controller for QR Laser Scan Line
  late AnimationController scanAnimationController;
  late Animation<double> scanAnimation;

  // OTP Fallback
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final RxInt focusedIndex = 0.obs;
  final RxInt timerSeconds = 59.obs;
  Timer? _timer;

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
      } else if (data['orderValue'] != null && data['orderValue'] is num) {
        orderValue.value = (data['orderValue'] as num).toDouble();
      }
      if (data['showOtpFallback'] != null && data['showOtpFallback'] is bool) {
        showOtpFallback.value = data['showOtpFallback'] as bool;
      }
      if (data['storeName'] != null) {
        storeName.value = data['storeName'].toString();
      }
      if (data['deliveryOption'] != null) {
        deliveryOption.value = data['deliveryOption'].toString();
      }
      if (data['paymentType'] != null) {
        paymentType.value = data['paymentType'].toString();
      }
    }

    // Laser scanning beam animation
    scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: scanAnimationController, curve: Curves.easeInOut),
    );

    // Track focus changes for OTP inputs
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusedIndex.value = i;
        }
      });
    }

    startTimer();
  }

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    WidgetManager.showSnackBar(
      message: isFlashOn.value ? "Flash Turned ON" : "Flash Turned OFF",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> pickQrFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onScanQrCode();
      }
    } catch (_) {
      onScanQrCode();
    }
  }

  Future<void> onScanQrCode() async {
    if (isVerifying.value) return;
    isVerifying.value = true;

    await Future.delayed(const Duration(milliseconds: 600));
    isVerifying.value = false;

    WidgetManager.showSuccessSnackBar("QR Code Scanned & Verified!");

    Get.offAllNamed(
      Routes.DELIVERY_SUCCESS,
      arguments: {
        'storeName': storeName.value,
        'deliveryOption': deliveryOption.value,
        'orderValue': orderValue.value,
        'paymentType': paymentType.value,
      },
    );
  }

  void toggleOtpFallback() {
    showOtpFallback.value = !showOtpFallback.value;
  }

  void startTimer() {
    _timer?.cancel();
    timerSeconds.value = 59;
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
    scanAnimationController.dispose();
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
      WidgetManager.showSnackBar(
        message:
            "Please Enter The Complete 6-Digit OTP Shared By ${customerName.value}.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isVerifying.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isVerifying.value = false;

    Get.offAllNamed(
      Routes.DELIVERY_SUCCESS,
      arguments: {
        'storeName': storeName.value,
        'deliveryOption': deliveryOption.value,
        'orderValue': orderValue.value,
        'paymentType': paymentType.value,
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
    WidgetManager.showSnackBar(
      message:
          "A New 6-Digit OTP Has Been Sent To ${customerName.value} (${customerPhone.value}).",
      snackPosition: SnackPosition.TOP,
    );
  }
}
