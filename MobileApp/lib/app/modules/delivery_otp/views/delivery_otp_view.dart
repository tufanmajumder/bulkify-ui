import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../controllers/delivery_otp_controller.dart';

class DeliveryOtpView extends GetView<DeliveryOtpController> {
  const DeliveryOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color buttonRedBg = Color(0xFFD84338);
    const Color buttonGreyBg = Color(0xFFF2F3F7);
    const Color iconCircleBg = Color(0xFFFDE8E8);
    const Color boxBorderColor = Color(0xFFE4E4E7);

    const Color activeBoxBorderColor = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        // Top Custom AppBar (Back Button & Title)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: textPrimary,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              WidgetManager.customText(
                text: "Delivery Code",
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ],
          ),
        ),

        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Main White Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Phone Icon Circle Badge
                          Container(
                            width: 58.r,
                            height: 58.r,
                            decoration: const BoxDecoration(
                              color: iconCircleBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.smartphone_outlined,
                                color: buttonRedBg,
                                size: 26.r,
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // 2. Instruction Subtitle
                          WidgetManager.customText(
                            text:
                                "Enter the OTP shared by the customer\nto confirm this delivery",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 24.h),

                          // 3. Row of 6-Digit OTP Box Input Fields
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (index) {
                                return Obx(() {
                                  final isFocused =
                                      controller.focusedIndex.value == index ||
                                      controller
                                          .otpControllers[index]
                                          .text
                                          .isNotEmpty;
                                  return Container(
                                    width: 44.w,
                                    height: 54.h,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: isFocused
                                            ? activeBoxBorderColor
                                            : boxBorderColor,
                                        width: isFocused ? 1.5.w : 1.2.w,
                                      ),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller:
                                            controller.otpControllers[index],
                                        focusNode: controller.focusNodes[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged: (value) => controller
                                            .onOtpChanged(value, index),
                                      ),
                                    ),
                                  );
                                });
                              }),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // 4. Countdown Timer
                          Obx(
                            () => controller.timerSeconds.value > 0
                                ? WidgetManager.customText(
                                    text:
                                        "Code expires in ${controller.formattedTimer}",
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 1. Delivered Button (Red Pill)
                    Obx(
                      () => Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: buttonRedBg,
                          borderRadius: BorderRadius.circular(26.r),
                          boxShadow: [
                            BoxShadow(
                              color: buttonRedBg.withValues(alpha: 0.3),
                              blurRadius: 14.r,
                              offset: Offset(0, 5.h),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.isVerifying.value
                                ? null
                                : controller.onVerifyAndContinue,
                            borderRadius: BorderRadius.circular(26.r),
                            child: Center(
                              child: controller.isVerifying.value
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : WidgetManager.customText(
                                      text: "Delivered",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. Resend OTP Button (Grey Pill - Only shown after timer expires)
                    Obx(
                      () => controller.timerSeconds.value == 0
                          ? Padding(
                              padding: EdgeInsets.only(top: 12.h),
                              child: Container(
                                width: double.infinity,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: buttonGreyBg,
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: controller.onResendOtp,
                                    borderRadius: BorderRadius.circular(25.r),
                                    child: Center(
                                      child: WidgetManager.customText(
                                        text: "Resend OTP",
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: kIsWeb
            ? Center(
                child: SizedBox(
                  width: 550,
                  height: double.infinity,
                  child: mainContent,
                ),
              )
            : mainContent,
      ),
    );
  }
}
