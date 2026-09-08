import 'dart:async';
import 'package:bulkify/app/data/models/auth_models/verify_otp_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpValidationController extends GetxController {
  final otpController = TextEditingController();
  final AuthService _authService = AuthService();

  final RxString phoneNumber = ''.obs;
  //final RxInt timerSeconds = 30.obs;
  final RxBool isOtpValid = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAgreedToTerms = true.obs;
  Timer? _timer;
  String deviceAllInfo = "";

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      phoneNumber.value = Get.arguments.toString();
    } else {
      phoneNumber.value = '9876543210';
    }
    showDeviceInfo(Get.context!);
    //startResendTimer();
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

  // void startResendTimer() {
  //   timerSeconds.value = 30;
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (timerSeconds.value > 0) {
  //       timerSeconds.value--;
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  void toggleTerms(bool? val) {
    isAgreedToTerms.value = val ?? false;
  }

  void verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length < 6) {
      WidgetManager.showSnackBar(
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
        deviceinfo: deviceAllInfo,
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
          debugPrint("Saved sessionId to SharedPreferences: $sessionId");
        }

        WidgetManager.showSnackBar(
          message:
              response.message?.toString() ?? StringManager.otpVerifiedSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          textColor: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        Get.offAllNamed(Routes.HOME);
      } else if (response!.code == 400 ||
          response.code == "400" ||
          response.success == false) {
        final String errorMsg = response.message;
        WidgetManager.showSnackBar(
          message: errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        final String errorMsg =
            response.message?.toString() ?? StringManager.somethingWentWrong;
        WidgetManager.showSnackBar(
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

  showDeviceInfo(BuildContext context) async {
    String deviceId = 'Unknown';
    String model = 'Unknown';
    String brand = 'Unknown';
    String deviceType = 'Phone';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        print("deviceInfo...${webInfo.userAgent}");
        deviceId = webInfo.userAgent ?? 'Web Browser';
        model = webInfo.browserName.name;
        final vendor = webInfo.vendor;
        brand = (vendor != null && vendor.isNotEmpty) ? vendor : 'Web Browser';
        deviceType = 'Web Browser';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        model = androidInfo.model;
        brand = androidInfo.brand;
        if (context.mounted) {
          final shortestSide = MediaQuery.of(context).size.shortestSide;
          deviceType = shortestSide >= 600 ? 'Tablet' : 'Phone';
        } else {
          deviceType = 'Phone';
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'Unknown iOS';
        model = iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.model;
        brand = 'Apple';
        deviceType = iosInfo.model.toLowerCase().contains('ipad')
            ? 'Tablet'
            : 'Phone';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        model = windowsInfo.computerName;
        brand = 'Microsoft';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'Unknown macOS';
        model = macInfo.model;
        brand = 'Apple';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'Unknown Linux';
        model = linuxInfo.name;
        brand = linuxInfo.variant ?? 'Linux';
        deviceType = 'Desktop';
      }
    } catch (e) {
      deviceId = 'Error: $e';
    }

    final infoObj = _authService.convertData(
      deviceType,
      deviceId,
      model,
      brand,
    );
    deviceAllInfo = WidgetManager().convertData(
      deviceType,
      deviceId,
      model,
      brand,
    );
    print("Generated plain deviceinfo payload: $infoObj");
    print("Generated plain deviceinfo payload: $deviceAllInfo");
    //return infoObj;
  }

  // void resendOtp() {
  //   if (timerSeconds.value == 0) {
  //     startResendTimer();
  //     otpController.clear();
  //     WidgetManager.showSnackBar(
  //       message: "A new OTP has been sent to +91 ${phoneNumber.value}",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.redAccent,
  //       textColor: Colors.white,
  //       margin: const EdgeInsets.all(16),
  //       borderRadius: 12,
  //     );
  //   }
  // }
}
