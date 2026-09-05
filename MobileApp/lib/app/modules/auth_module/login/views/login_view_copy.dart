import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/asset_manager.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/auth_module/login/controllers/login_controller.dart';
import 'terms_webview_view.dart';

class LoginViewCopy extends GetView<LoginController> {
  const LoginViewCopy({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: isKeyboardOpen ? 15.h : 45.h,
                    ),
                    // Bulkify Logo
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      height: isKeyboardOpen ? 45.h : 85.h,
                      child: Image.asset(
                        AssetManager.splashLogo2Png,
                        fit: BoxFit.contain,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: isKeyboardOpen ? 20.h : 46.h,
                    ),
                    _buildSubTitleSection(),
                    SizedBox(height: 30.h),
                    _buildPhoneInputField(context),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Bottom Section: Terms & Conditions + Request OTP Button
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTermsSection(),
                  SizedBox(height: 20.h),
                  _buildRequestOtpButton(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Subtitle Instruction Section
  Widget _buildSubTitleSection() {
    return WidgetManager.customText(
      text: StringManager.otpSendInstruction,
      fontSize: 14.5.sp,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      textAlign: TextAlign.center,
    );
  }

  /// Phone Number Input Field
  Widget _buildPhoneInputField(BuildContext context) {
    return Obx(() {
      final isValid = controller.isPhoneValid.value;

      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _MobileNumberInputFormatter(),
                ],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 18.h,
                  ),
                  border: InputBorder.none,
                  hintText: StringManager.enterPhoneHint,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA5A3AE),
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            if (isValid)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Request OTP Action Button
  Widget _buildRequestOtpButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isValid =
          controller.isPhoneValid.value && controller.isAgreedToTerms.value;

      return Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isValid ? ColorManager.red : const Color(0xFFDDE1EB),
          boxShadow: isValid
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isValid && !isLoading)
                ? () => controller.requestOtp()
                : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : WidgetManager.customText(
                      text: StringManager.requestOtp,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: isValid ? Colors.white : const Color(0xFF7E7E9A),
                      letterSpacing: 0.6,
                    ),
            ),
          ),
        ),
      );
    });
  }

  /// Terms and Conditions Checkbox & Text Section
  Widget _buildTermsSection() {
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.toggleTerms(!controller.isAgreedToTerms.value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: IgnorePointer(
                  child: Checkbox(
                    value: controller.isAgreedToTerms.value,
                    onChanged: null,
                    activeColor: Colors.grey.shade100,
                    checkColor: ColorManager.red,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.grey.withValues(alpha: 0.2);
                      }
                      return Colors.grey.withValues(alpha: 0.2);
                    }),
                    side: BorderSide(
                      color: controller.isAgreedToTerms.value
                          ? Colors.grey.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: StringManager.iAcceptAllThe,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: StringManager.termsAndConditions,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                          shadows: const [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(0, -2.5),
                            ),
                          ],
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(
                              () => const TermsWebviewView(),
                              transition: Transition.downToUp,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Input formatter that restricts mobile number entries.
/// - Allows typing up to 10 digits ONLY IF the first digit is 6, 7, 8, or 9.
/// - Rejects input and triggers a snackbar alert if the number starts with any other digit.
class _MobileNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final cleaned = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) {
      return TextEditingValue.empty;
    }

    final firstDigit = cleaned[0];
    final isValidFirstDigit = ['6', '7', '8', '9'].contains(firstDigit);

    if (!isValidFirstDigit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isSnackbarOpen != true) {
          WidgetManager.showAlertSnackBar(StringManager.mobileMustStartWith);
        }
      });
      return oldValue.text.isEmpty ? TextEditingValue.empty : oldValue;
    }

    final truncated = cleaned.length > 10 ? cleaned.substring(0, 10) : cleaned;
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
