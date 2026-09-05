import 'dart:async';
import 'package:bulkify/app/data/models/auth_models/verify_otp_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpValidationController extends GetxController {
  final otpController = TextEditingController();
  final AuthService _authService = AuthService();

  final RxString phoneNumber = ''.obs;
  final RxInt timerSeconds = 30.obs;
  final RxBool isOtpValid = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAgreedToTerms = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      phoneNumber.value = Get.arguments.toString();
    } else {
      phoneNumber.value = '9876543210';
    }

    startResendTimer();
    otpController.addListener(_validateOtp);
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.removeListener(_validateOtp);
    otpController.dispose();
    super.onClose();
  }

  void _validateOtp() {
    isOtpValid.value = otpController.text.trim().length == 6;
  }

  void startResendTimer() {
    timerSeconds.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void toggleTerms(bool? val) {
    isAgreedToTerms.value = val ?? false;
  }

  void verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length < 6) {
      WidgetManager.showSnackBar(
        title: StringManager.incompleteOtpTitle,
        message: StringManager.enterCompleteOtpMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;
    try {
      final VerifyOtpModel? response = await _authService.verifyOtp(
        channel: 1,
        deviceinfo: "",
        identifier: phoneNumber.value,
        otp: otp,
      );

      if (response != null &&
          (response.code == 200 ||
              response.code == "200" ||
              response.success == true)) {
        final sessionId = response.data?.sessionId?.toString() ?? "";
        if (sessionId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('sessionId', sessionId);
          print("Saved sessionId to SharedPreferences: $sessionId");
        }

        WidgetManager.showSnackBar(
          title: StringManager.success,
          message:
              response.message?.toString() ?? StringManager.otpVerifiedSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          textColor: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        Get.offAllNamed(Routes.HOME);
      } else {
        final String errorMsg =
            response?.message?.toString() ?? StringManager.somethingWentWrong;
        WidgetManager.showSnackBar(
          title: StringManager.error,
          message: errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      WidgetManager.showSnackBar(
        title: StringManager.error,
        message: StringManager.unexpectedError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    if (timerSeconds.value == 0) {
      startResendTimer();
      otpController.clear();
      WidgetManager.showSnackBar(
        title: StringManager.otpResentTitle,
        message: "A new OTP has been sent to +91 ${phoneNumber.value}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
