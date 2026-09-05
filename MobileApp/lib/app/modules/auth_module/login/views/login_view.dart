import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/utils/asset_manager.dart';
import '../../../../data/utils/color_manager.dart';
import '../../../../data/utils/string_manager.dart';
import '../../../../data/utils/widget_manager.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color webBgColor = Color(0xFFF8F9FC);

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: webBgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: BoxDecoration(
                  color: ColorManager.red,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),

                    // Bulkify Logo
                    SizedBox(
                      width: double.infinity,
                      height: 90.h,
                      child: Image.asset(
                        AssetManager.splashLogo1,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Subtitle Instruction Text
                    _buildSubTitleSection(),

                    SizedBox(height: 28.h),

                    // Phone Input Field Box
                    _buildPhoneInputField(context),

                    SizedBox(height: 40.h),

                    // Terms & Conditions Checkbox
                    _buildTermsSection(),

                    SizedBox(height: 18.h),

                    // Request OTP Button
                    _buildRequestOtpButton(),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: ColorManager.red,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50.h),
                    // Bulkify Logo
                    SizedBox(
                      width: double.infinity,
                      height: 95.h,
                      child: Image.asset(
                        AssetManager.splashLogo1,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    _buildSubTitleSection(),
                    SizedBox(height: 32.h),
                    _buildPhoneInputField(context),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Bottom Section: Terms & Conditions + Request OTP Button
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: 24.h,
              ),
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
      color: Colors.white,
      textAlign: TextAlign.center,
    );
  }

  /// Phone Number Input Field
  Widget _buildPhoneInputField(BuildContext context) {
    return Obx(() {
      final isValid = controller.isPhoneValid.value;

      return Container(
        height: 58.h,
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
                maxLength: 17,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\(\)\s]')),
                  LengthLimitingTextInputFormatter(17),
                ],
                style: GoogleFonts.poppins(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
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
                  hintStyle: GoogleFonts.poppins(
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
      final isValid = controller.isPhoneValid.value;

      return Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isValid ? Colors.white : const Color(0xFFDDE1EB),
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
                      text: StringManager.requestOtp.toUpperCase(),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isValid ? Colors.black : const Color(0xFF7E7E9A),
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22.r,
            height: 22.r,
            child: Checkbox(
              value: controller.isAgreedToTerms.value,
              onChanged: (val) => controller.toggleTerms(val),
              activeColor: Colors.white,
              checkColor: ColorManager.red,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.white.withValues(alpha: 0.2);
              }),
              side: BorderSide(
                color: controller.isAgreedToTerms.value
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: GestureDetector(
              onTap: () =>
                  controller.toggleTerms(!controller.isAgreedToTerms.value),
              child: Text.rich(
                TextSpan(
                  text: StringManager.iAcceptAllThe,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: StringManager.termsAndConditions,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
