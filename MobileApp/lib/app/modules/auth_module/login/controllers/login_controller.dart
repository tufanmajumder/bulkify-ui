import 'package:bulkify/app/data/models/auth_models/login_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  final RxString selectedCountryCode = '+91'.obs;
  final RxList<String> countryCodes = ['+91', '+1', '+44', '+971', '+65'].obs;
  final RxBool isAgreedToTerms = false.obs;
  final RxBool isPhoneValid = false.obs;
  final RxBool isLoading = false.obs;

  // 1 & 7. TRAI 10-digit regex enforcing 6-9 series: ^[6-9]\d{9}$
  static final RegExp _trai10DigitRegex = RegExp(r'^[6-9]\d{9}$');

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_validatePhone);
  }

  /// 3. Strip formatting: spaces, hyphens, parentheses, dots
  String stripFormatting(String input) {
    return input.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  }

  /// 2. Handle country code and leading prefixes (+91, 91, 0)
  String stripCountryCodePrefix(String cleanedInput) {
    String str = cleanedInput;
    if (str.startsWith('+91')) {
      str = str.substring(3);
    } else if (str.startsWith('+')) {
      str = str.substring(1);
    }

    if (str.startsWith('91') && str.length == 12) {
      str = str.substring(2);
    } else if (str.startsWith('0') && str.length == 11) {
      str = str.substring(1);
    }
    return str;
  }

  /// 6. Numeric-only check
  bool isNumericOnly(String input) {
    return RegExp(r'^\d+$').hasMatch(input);
  }

  /// 7. Starting-digit check (enforces 6/7/8/9 TRAI series rule)
  bool isStartingDigitValid(String tenDigitInput) {
    if (tenDigitInput.isEmpty) return false;
    final firstChar = tenDigitInput[0];
    return ['6', '7', '8', '9'].contains(firstChar);
  }

  /// 5. Progressive / Live form validation check
  void _validatePhone() {
    final text = phoneController.text;
    isPhoneValid.value = isValidPhoneNumber(text);
  }

  bool isValidPhoneNumber(String rawInput) {
    return getPhoneValidationError(rawInput) == null;
  }

  /// Get user-friendly validation error message for feedback
  String? getPhoneValidationError(String rawInput) {
    final cleaned = rawInput.trim().replaceAll(RegExp(r'\D'), '');

    if (cleaned.isEmpty) {
      return StringManager.pleaseEnterPhoneNumber;
    }

    if (cleaned.length < 10) {
      return StringManager.enterValidMobileNumber;
    }

    if (cleaned.length > 10) {
      return StringManager.phoneExceed10Digits;
    }

    if (!_trai10DigitRegex.hasMatch(cleaned)) {
      return StringManager.mobileMustStartWith;
    }

    return null;
  }

  /// 4. Normalize / TryParse — cleans input and returns canonical 10-digit form (or null if invalid)
  String? normalizePhoneNumber(String rawInput) {
    if (isValidPhoneNumber(rawInput)) {
      return rawInput.trim().replaceAll(RegExp(r'\D'), '');
    }
    return null;
  }

  @override
  void onClose() {
    phoneController.removeListener(_validatePhone);
    phoneController.dispose();
    super.onClose();
  }

  void selectCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  void toggleTerms(bool? val) {
    isAgreedToTerms.value = val ?? false;
  }

  void requestOtp() async {
    final rawPhone = phoneController.text;

    if (!isAgreedToTerms.value) {
      WidgetManager.showSnackBar(
        message: StringManager.acceptTermsMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final validationError = getPhoneValidationError(rawPhone);
    if (validationError != null) {
      WidgetManager.showSnackBar(
        message: validationError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final normalizedPhone = normalizePhoneNumber(rawPhone)!;

    isLoading.value = true;
    try {
      final LoginModel? response = await _authService.login1(
        "1",
        normalizedPhone,
      );
      if (response != null &&
          (response.success == true ||
              response.code == 200 ||
              response.code == "200")) {
        Get.toNamed(Routes.OTP_VALIDATION, arguments: normalizedPhone);
      } else {
        final String message =
            response?.message?.toString() ?? StringManager.failedInitiateLogin;
        WidgetManager.showSnackBar(
          message: message,
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
}
