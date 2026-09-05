import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../controllers/delivery_failed_summary_controller.dart';

class DeliveryFailedSummaryView
    extends GetView<DeliveryFailedSummaryController> {
  const DeliveryFailedSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color buttonRedBg = Color(0xFFD84338);
    const Color redCircleBg = Color(0xFFFDE8E8);
    const Color redIconColor = Color(0xFFD84338);
    const Color dividerColor = Color(0xFFF0F0F3);

    final Widget mainContent = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              SizedBox(height: 28.h),

              // 1. Red Cross Circle Badge
              Container(
                width: 80.r,
                height: 80.r,
                decoration: const BoxDecoration(
                  color: redCircleBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: redIconColor,
                    size: 42.r,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // 2. Main Title
              WidgetManager.customText(
                text: "Delivery not completed",
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.5,
              ),

              SizedBox(height: 8.h),

              // 3. Subtitle Description
              Obx(
                () => WidgetManager.customText(
                  text:
                      "Order from ${controller.storeName.value} could not be delivered. It\nhas been logged and reported to support.",
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 28.h),

              // 4. Delivery Failure Details Card
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
                  horizontal: 20.w,
                  vertical: 20.h,
                ),
                child: Column(
                  children: [
                    // Row 1: Order value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WidgetManager.customText(
                          text: "Order value",
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                        Obx(
                          () => WidgetManager.customText(
                            text:
                                "₹${controller.orderValue.value.toStringAsFixed(2)}",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      color: dividerColor,
                      height: 28.h,
                      thickness: 1.h,
                    ),

                    // Row 2: Reason
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WidgetManager.customText(
                          text: "Reason",
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Obx(
                            () => WidgetManager.customText(
                              text: controller.reason.value,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      color: dividerColor,
                      height: 28.h,
                      thickness: 1.h,
                    ),

                    // Row 3: Logged at
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WidgetManager.customText(
                          text: "Logged at",
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                        Obx(
                          () => WidgetManager.customText(
                            text: controller.loggedAtTime.value,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // 5. Back to Home Button (Red Pill with Home Icon)
              Container(
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
                    onTap: controller.onBackToHome,
                    borderRadius: BorderRadius.circular(26.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 20.r,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        WidgetManager.customText(
                          text: "Back to Home",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
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
