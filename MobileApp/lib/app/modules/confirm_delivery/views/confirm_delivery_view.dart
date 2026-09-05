import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/confirm_delivery/controllers/confirm_delivery_controller.dart';

class ConfirmDeliveryView extends GetView<ConfirmDeliveryController> {
  const ConfirmDeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color textCaption = Color(0xFFA0A0B0);
    const Color greenCircleBg = Color(0xFF10B981);
    const Color buttonRedBg = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    SizedBox(height: 32.h),

                    // 1. Success Green Circle Check Icon
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: const BoxDecoration(
                        color: greenCircleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 54.r,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // 2. Payment Successful Title
                    WidgetManager.customText(
                      text: "Payment Successful",
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),

                    SizedBox(height: 10.h),

                    // 3. Subtitles (Order #, Payment ID #, UTR #)
                    Obx(
                      () => Column(
                        children: [
                          WidgetManager.customText(
                            text: "Order #${controller.orderId.value}",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          SizedBox(height: 4.h),
                          WidgetManager.customText(
                            text: "Payment ID #${controller.paymentId.value}",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          SizedBox(height: 4.h),
                          WidgetManager.customText(
                            text: "UTR #${controller.utr.value}",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // 4. Big Green Amount Text
                    Obx(
                      () => WidgetManager.customText(
                        text:
                            "₹${controller.orderValue.value.toStringAsFixed(2)}",
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: ColorManager.simpleGreen,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // 5. Thank you! Caption
                    WidgetManager.customText(
                      text: "Thank you!",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textCaption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 6. Send Delivery Code Red Button pinned at the bottom
        Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            bottom: 24.h,
            top: 12.h,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Obx(
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
                    onTap: controller.isSubmitting.value
                        ? null
                        : controller.onSendDeliveryCode,
                    borderRadius: BorderRadius.circular(26.r),
                    child: Center(
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : WidgetManager.customText(
                              text: "Send Delivery Code",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                    ),
                  ),
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
