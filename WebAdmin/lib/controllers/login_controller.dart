import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/login_model.dart';
import '../service/auth_service.dart';
import '../utils/widget_manager.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.put(AuthService());

  final TextEditingController inputController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final RxBool isOtpSent = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString base64Data = ''.obs;

  int activeChannel = 1;
  String activeIdentifier = '';

  bool get isMobileInput => activeChannel == 1;

  String get getFullOtp => otpControllers.map((c) => c.text.trim()).join();

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
    }
  }

  Future<void> sendOtp() async {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      errorMessage.value = 'Please enter your mobile number or email address';
      WidgetManager.showAlertSnackBar(errorMessage.value);
      return;
    }

    final isDigitStart = RegExp(r'^[0-9]').hasMatch(input);
    int channel;
    String identifier;

    if (isDigitStart) {
      final cleanDigits = input.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.isEmpty ||
          !['6', '7', '8', '9'].contains(cleanDigits[0])) {
        errorMessage.value = 'Mobile number must start with 6, 7, 8, or 9';
        WidgetManager.showAlertSnackBar(errorMessage.value);
        return;
      }
      if (cleanDigits.length != 10) {
        errorMessage.value = 'Please enter a valid 10-digit mobile number';
        WidgetManager.showAlertSnackBar(errorMessage.value);
        return;
      }
      channel = 1;
      identifier = cleanDigits.startsWith('+91')
          ? cleanDigits
          : '+91$cleanDigits';
    } else {
      final isEmailValid =
          GetUtils.isEmail(input) ||
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
      if (!isEmailValid) {
        errorMessage.value = 'Please enter a valid email address';
        WidgetManager.showAlertSnackBar(errorMessage.value);
        return;
      }
      channel = 2;
      identifier = input;
    }

    activeChannel = channel;
    activeIdentifier = identifier;
    errorMessage.value = '';

    isLoading.value = true;
    try {
      final LoginModel? response = await _authService.login(
        channel: channel,
        identifier: identifier,
      );

      if (response != null) {
        final bool isSuccess =
            response.success == true ||
            response.success == 'true' ||
            response.code == 200;
        if (isSuccess) {
          isOtpSent.value = true;
          clearOtpFields();
          final msg = response.message?.toString();
          if (msg != null && msg.isNotEmpty) {
            WidgetManager.showSuccessSnackBar(msg);
          } else {
            WidgetManager.showSuccessSnackBar('OTP sent successfully');
          }
        } else {
          final msg = response.message?.toString() ?? 'Failed to send OTP';
          errorMessage.value = msg;
          WidgetManager.showAlertSnackBar(msg);
        }
      } else {
        errorMessage.value = 'Failed to send OTP. Please try again.';
        WidgetManager.showAlertSnackBar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while sending OTP';
      WidgetManager.showAlertSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> showDeviceInfo(BuildContext context) async {
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
    print("Generated plain deviceinfo payload: $infoObj");
    return infoObj;
  }

  Future<void> verifyOtpAndLogin(BuildContext context) async {
    final otp = getFullOtp;
    if (otp.length < 6) {
      WidgetManager.showAlertSnackBar(
        'Please enter the complete 6-digit security code',
      );
      return;
    }

    isLoading.value = true;
    try {
      final LoginModel? response = await _authService.verifyOtp(
        channel: activeChannel,
        identifier: activeIdentifier,
        otp: otp,
      );

      if (response != null) {
        print(
          "verifyOtp response parsed -> success: ${response.success}, code: ${response.code}, message: ${response.message}, token: ${response.token}, data: ${response.data}",
        );

        final sStr = response.success?.toString().trim().toLowerCase();
        final mStr = response.message?.toString().trim().toLowerCase() ?? '';
        final cStr = response.code?.toString().trim();

        final bool isSuccess =
            response.success == true ||
            sStr == 'true' ||
            sStr == '1' ||
            sStr == 'success' ||
            response.code == 200 ||
            cStr == '200' ||
            cStr == '0' ||
            mStr.contains('success') ||
            mStr.contains('verified') ||
            mStr.contains('login successful') ||
            response.data != null;

        if (isSuccess) {
          String? sessionToken = response.token;
          if ((sessionToken == null || sessionToken.isEmpty) &&
              response.data is Data1) {
            sessionToken = (response.data as Data1).sessionId;
          }

          print("================ SESSION ID / TOKEN PRINT ================");
          print("RECEIVED DYNAMIC SESSION ID: $sessionToken");
          print("==========================================================");

          if (sessionToken != null && sessionToken.trim().isNotEmpty) {
            AuthService.setAuthToken(sessionToken);
          }

          final msg = response.message?.toString();
          if (msg != null && msg.isNotEmpty) {
            WidgetManager.showSuccessSnackBar(msg);
          } else {
            WidgetManager.showSuccessSnackBar('Login successful');
            print("cdc");
          }
          Get.offAllNamed('/orders');
        } else {
          final msg =
              (response.message != null &&
                  response.message.toString().isNotEmpty)
              ? response.message.toString()
              : 'Invalid OTP code';
          WidgetManager.showAlertSnackBar(msg);
          clearOtpFields();
        }
      } else {
        WidgetManager.showAlertSnackBar(
          'Verification failed. Please try again.',
        );
        clearOtpFields();
      }
    } catch (e) {
      WidgetManager.showAlertSnackBar('An error occurred during verification');
      clearOtpFields();
    } finally {
      isLoading.value = false;
    }
  }

  void resetLogin() {
    isOtpSent.value = false;
    inputController.clear();
    clearOtpFields();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    inputController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
