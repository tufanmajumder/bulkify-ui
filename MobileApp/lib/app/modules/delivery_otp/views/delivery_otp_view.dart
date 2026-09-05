import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/delivery_otp/controllers/delivery_otp_controller.dart';

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
        // Top Custom AppBar (Back Button, Title & Toggle Button)
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
                text: "Verify Delivery Code",
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: _buildOtpFallbackContent(
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  buttonRedBg: buttonRedBg,
                  buttonGreyBg: buttonGreyBg,
                  iconCircleBg: iconCircleBg,
                  boxBorderColor: boxBorderColor,
                  activeBoxBorderColor: activeBoxBorderColor,
                ),
              ),
            ),
          ),
        ),

        // Pinned Bottom Action Button Section
        Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: 20.h,
            top: 8.h,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: _buildBottomVerifyButton(buttonRedBg: buttonRedBg),
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

  /// Build QR Scan View Content
  // Widget _buildQrScanContent({
  //   required Color textPrimary,
  //   required Color textSecondary,
  //   required Color buttonRedBg,
  // }) {
  //   return Column(
  //     children: [
  //       // 1. Customer Summary Card
  //       Container(
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20.r),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withValues(alpha: 0.03),
  //               blurRadius: 14.r,
  //               offset: Offset(0, 3.h),
  //             ),
  //           ],
  //         ),
  //         padding: EdgeInsets.all(16.r),
  //         child: Row(
  //           children: [
  //             Container(
  //               width: 44.r,
  //               height: 44.r,
  //               decoration: const BoxDecoration(
  //                 color: Color(0xFFFDE8E8),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Center(
  //                 child: Icon(
  //                   Icons.person_outline_rounded,
  //                   color: buttonRedBg,
  //                   size: 22.r,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 12.w),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   WidgetManager.customText(
  //                     text: controller.customerName.value,
  //                     fontSize: 15.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: textPrimary,
  //                   ),
  //                   SizedBox(height: 2.h),
  //                   WidgetManager.customText(
  //                     text: controller.customerPhone.value,
  //                     fontSize: 12.5.sp,
  //                     fontWeight: FontWeight.w400,
  //                     color: textSecondary,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             if (controller.orderValue.value > 0)
  //               Container(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 10.w,
  //                   vertical: 6.h,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFE8FADF),
  //                   borderRadius: BorderRadius.circular(12.r),
  //                 ),
  //                 child: WidgetManager.customText(
  //                   text: "₹${controller.orderValue.value.toStringAsFixed(0)}",
  //                   fontSize: 13.sp,
  //                   fontWeight: FontWeight.w800,
  //                   color: const Color(0xFF28C76F),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),

  //       SizedBox(height: 20.h),

  //       // 2. High-Tech Camera Viewfinder Card
  //       Container(
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF181824),
  //           borderRadius: BorderRadius.circular(24.r),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withValues(alpha: 0.15),
  //               blurRadius: 20.r,
  //               offset: Offset(0, 8.h),
  //             ),
  //           ],
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
  //         child: Column(
  //           children: [
  //             // Viewfinder Controls Header (Flash & Gallery)
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 GestureDetector(
  //                   onTap: controller.pickQrFromGallery,
  //                   child: Container(
  //                     padding: EdgeInsets.all(10.r),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withValues(alpha: 0.12),
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       Icons.photo_library_rounded,
  //                       color: Colors.white,
  //                       size: 20.r,
  //                     ),
  //                   ),
  //                 ),
  //                 WidgetManager.customText(
  //                   text: "Scan QR Code",
  //                   fontSize: 14.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white.withValues(alpha: 0.9),
  //                 ),
  //                 Obx(
  //                   () => GestureDetector(
  //                     onTap: controller.toggleFlash,
  //                     child: Container(
  //                       padding: EdgeInsets.all(10.r),
  //                       decoration: BoxDecoration(
  //                         color: controller.isFlashOn.value
  //                             ? Colors.amber.withValues(alpha: 0.3)
  //                             : Colors.white.withValues(alpha: 0.12),
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: Icon(
  //                         controller.isFlashOn.value
  //                             ? Icons.flash_on_rounded
  //                             : Icons.flash_off_rounded,
  //                         color: controller.isFlashOn.value
  //                             ? Colors.amber
  //                             : Colors.white,
  //                         size: 20.r,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),

  //             SizedBox(height: 24.h),

  //             // Viewfinder Square Box with Corner Brackets & Moving Laser Line
  //             Center(
  //               child: SizedBox(
  //                 width: 220.r,
  //                 height: 220.r,
  //                 child: Stack(
  //                   children: [
  //                     // Viewfinder Frame Background
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.black.withValues(alpha: 0.4),
  //                         borderRadius: BorderRadius.circular(16.r),
  //                         border: Border.all(
  //                           color: Colors.white.withValues(alpha: 0.1),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: Center(
  //                         child: Icon(
  //                           Icons.qr_code_2_rounded,
  //                           color: Colors.white.withValues(alpha: 0.15),
  //                           size: 110.r,
  //                         ),
  //                       ),
  //                     ),

  //                     // Corner Brackets
  //                     CustomPaint(
  //                       size: Size(220.r, 220.r),
  //                       painter: QRScannerCornerPainter(
  //                         color: buttonRedBg,
  //                         cornerLength: 26.r,
  //                         strokeWidth: 3.5.r,
  //                       ),
  //                     ),

  //                     // Animated Laser Scan Beam
  //                     AnimatedBuilder(
  //                       animation: controller.scanAnimation,
  //                       builder: (context, child) {
  //                         final topOffset =
  //                             controller.scanAnimation.value * (220.r - 4.h);
  //                         return Positioned(
  //                           top: topOffset,
  //                           left: 12.w,
  //                           right: 12.w,
  //                           child: Container(
  //                             height: 3.5.h,
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(2.r),
  //                               gradient: const LinearGradient(
  //                                 colors: [
  //                                   Colors.transparent,
  //                                   Color(0xFFFF5252),
  //                                   Colors.white,
  //                                   Color(0xFFFF5252),
  //                                   Colors.transparent,
  //                                 ],
  //                               ),
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: const Color(
  //                                     0xFFFF5252,
  //                                   ).withValues(alpha: 0.8),
  //                                   blurRadius: 10.r,
  //                                   spreadRadius: 2.r,
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),

  //             SizedBox(height: 24.h),

  //             // Viewfinder Helper Instruction
  //             WidgetManager.customText(
  //               text: "Align Customer's QR code within frame",
  //               fontSize: 13.sp,
  //               fontWeight: FontWeight.w400,
  //               color: Colors.white.withValues(alpha: 0.7),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),

  //       SizedBox(height: 24.h),

  //       // 3. Scan QR Code Primary Action Button
  //       Container(
  //         width: double.infinity,
  //         height: 52.h,
  //         decoration: BoxDecoration(
  //           color: buttonRedBg,
  //           borderRadius: BorderRadius.circular(26.r),
  //           boxShadow: [
  //             BoxShadow(
  //               color: buttonRedBg.withValues(alpha: 0.3),
  //               blurRadius: 14.r,
  //               offset: Offset(0, 5.h),
  //             ),
  //           ],
  //         ),
  //         child: Material(
  //           color: Colors.transparent,
  //           child: InkWell(
  //             onTap: controller.isVerifying.value
  //                 ? null
  //                 : controller.onScanQrCode,
  //             borderRadius: BorderRadius.circular(26.r),
  //             child: Center(
  //               child: controller.isVerifying.value
  //                   ? SizedBox(
  //                       width: 22.r,
  //                       height: 22.r,
  //                       child: const CircularProgressIndicator(
  //                         strokeWidth: 2.5,
  //                         color: Colors.white,
  //                       ),
  //                     )
  //                   : Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.qr_code_scanner_rounded,
  //                           color: Colors.white,
  //                           size: 20.r,
  //                         ),
  //                         SizedBox(width: 8.w),
  //                         WidgetManager.customText(
  //                           text: "Scan QR Code",
  //                           fontSize: 16.sp,
  //                           fontWeight: FontWeight.w800,
  //                           color: Colors.white,
  //                         ),
  //                       ],
  //                     ),
  //             ),
  //           ),
  //         ),
  //       ),

  //       SizedBox(height: 16.h),

  //       // 4. Secondary Option: Enter OTP manually
  //       GestureDetector(
  //         onTap: controller.toggleOtpFallback,
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(vertical: 8.h),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.pin_outlined, color: textSecondary, size: 16.r),
  //               SizedBox(width: 6.w),
  //               WidgetManager.customText(
  //                 text: "Can't scan? Enter 6-digit OTP instead",
  //                 fontSize: 13.sp,
  //                 fontWeight: FontWeight.w600,
  //                 color: textSecondary,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),

  //       SizedBox(height: 20.h),
  //     ],
  //   );
  // }

  /// Build OTP Fallback Content
  Widget _buildOtpFallbackContent({
    required Color textPrimary,
    required Color textSecondary,
    required Color buttonRedBg,
    required Color buttonGreyBg,
    required Color iconCircleBg,
    required Color boxBorderColor,
    required Color activeBoxBorderColor,
  }) {
    return Column(
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Phone Icon Circle Badge
              Container(
                width: 58.r,
                height: 58.r,
                decoration: BoxDecoration(
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
                text: "Enter the delivery code sent to the customer",
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
                          controller.otpControllers[index].text.isNotEmpty;
                      return Container(
                        width: 44.w,
                        height: 54.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
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
                            controller: controller.otpControllers[index],
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
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) =>
                                controller.onOtpChanged(value, index),
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
                        text: "Code Expires In ${controller.formattedTimer}",
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

      ],
    );
  }

  /// Pinned Bottom Action Button (Verify / Resend Delivery Code)
  Widget _buildBottomVerifyButton({
    required Color buttonRedBg,
  }) {
    return Obx(() {
      final isTimerActive = controller.timerSeconds.value > 0;
      return Container(
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
            onTap: isTimerActive
                ? (controller.isVerifying.value
                    ? null
                    : controller.onVerifyAndContinue)
                : controller.onResendOtp,
            borderRadius: BorderRadius.circular(26.r),
            child: Center(
              child: isTimerActive
                  ? (controller.isVerifying.value
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : WidgetManager.customText(
                          text: "Verify",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ))
                  : WidgetManager.customText(
                      text: "Resend Delivery Code",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      );
    });
  }
}

/// Custom Painter for Viewfinder Corner Brackets
class QRScannerCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  QRScannerCornerPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(w - cornerLength, 0)
        ..lineTo(w, 0)
        ..lineTo(w, cornerLength),
      paint,
    );

    // Bottom-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(0, h - cornerLength)
        ..lineTo(0, h)
        ..lineTo(cornerLength, h),
      paint,
    );

    // Bottom-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(w - cornerLength, h)
        ..lineTo(w, h)
        ..lineTo(w, h - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
