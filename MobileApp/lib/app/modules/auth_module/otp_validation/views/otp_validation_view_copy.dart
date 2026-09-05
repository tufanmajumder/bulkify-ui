import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/asset_manager.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/auth_module/otp_validation/controllers/otp_validation_controller.dart';

class OtpValidationViewCopy extends GetView<OtpValidationController> {
  const OtpValidationViewCopy({super.key});

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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bulkify Logo
                    SizedBox(
                      width: double.infinity,
                      height: 90.h,
                      child: Image.asset(
                        AssetManager.splashLogo2Png,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Phone Instruction Subtitle
                    _buildPhoneInstructionText(),

                    SizedBox(height: 28.h),

                    // 6-digit OTP Box Inputs
                    _OtpInputWidget(controller: controller),

                    SizedBox(height: 24.h),

                    // Resend Timer / Button
                    //_buildResendSection(),
                    SizedBox(height: 32.h),

                    // Verify OTP Button
                    _buildVerifyButton(),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // Mobile layout
    return Scaffold(
      backgroundColor: ColorManager.white,
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
                    _buildPhoneInstructionText(),
                    SizedBox(height: 28.h),
                    _OtpInputWidget(controller: controller),
                    SizedBox(height: 20.h),
                    //_buildResendSection(),
                    if (isKeyboardOpen) ...[
                      SizedBox(height: 16.h),
                      _buildVerifyButton(),
                      SizedBox(height: 12.h),
                    ] else
                      SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            if (!isKeyboardOpen)
              Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildVerifyButton(),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Phone Instruction Subtitle
  Widget _buildPhoneInstructionText() {
    return Obx(
      () => WidgetManager.customText(
        text: 'Enter the code sent to\n+91 ${controller.phoneNumber.value}',
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Resend OTP Timer & Button Section
  // Widget _buildResendSection() {
  //   return Obx(() {
  //     final seconds = controller.timerSeconds.value;
  //     if (seconds > 0) {
  //       return WidgetManager.customText(
  //         text: 'Resend OTP in 00:${seconds.toString().padLeft(2, '0')}',
  //         fontSize: 13.5.sp,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.white,
  //       );
  //     } else {
  //       return InkWell(
  //         onTap: controller.resendOtp,
  //         child: Text(
  //           StringManager.resendOtp,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             fontWeight: FontWeight.w700,
  //             color: Colors.white,
  //             decoration: TextDecoration.underline,
  //             decorationColor: Colors.white,
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  /// Verify OTP Action Button
  Widget _buildVerifyButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isValid = controller.isOtpValid.value;

      return Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isValid ? ColorManager.red : const Color(0xFFDDE1EB),
          boxShadow: isValid
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
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
                ? () => controller.verifyOtp()
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
                      text: StringManager.verifyOtp,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: isValid ? Colors.white : const Color(0xFF7E8A9F),
                      letterSpacing: 0.6,
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _OtpInputWidget extends StatefulWidget {
  final OtpValidationController controller;
  const _OtpInputWidget({required this.controller});

  @override
  State<_OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<_OtpInputWidget> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double boxDimension = math.min((screenWidth - 48) / 6.8, 48.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden TextField for receiving keyboard input
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller.otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () {
                  _focusNode.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                },
              ),
            ),
          ),

          // Visual 6 Digit Boxes (wrapped in IgnorePointer to pass tap events to TextField & GestureDetector)
          IgnorePointer(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller.otpController,
              builder: (context, value, child) {
                String text = value.text;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    bool isFocused =
                        _focusNode.hasFocus &&
                        (text.length == index ||
                            (index == 5 && text.length == 6));
                    bool isFilled = index < text.length;
                    String digit = isFilled ? text[index] : '';

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: boxDimension,
                      height: boxDimension,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey[350]!,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: math.max(boxDimension * 0.38, 16.0),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
